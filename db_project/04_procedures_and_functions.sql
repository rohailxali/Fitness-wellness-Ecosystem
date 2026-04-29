-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 4: Stored Procedures and Functions
-- Execute AFTER 03_views_and_triggers.sql
-- ============================================================


-- ============================================================
-- PROCEDURE 1: SP_REGISTER_USER
-- Registers a new user by inserting into ACCOUNT and APP_USER
-- atomically.  Raises an application error on duplicate email.
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_REGISTER_USER (
    p_email         IN  ACCOUNT.email%TYPE,
    p_password_hash IN  ACCOUNT.password_hash%TYPE,
    p_phone         IN  ACCOUNT.phone%TYPE,
    p_first_name    IN  APP_USER.first_name%TYPE,
    p_last_name     IN  APP_USER.last_name%TYPE,
    p_dob           IN  APP_USER.dob%TYPE,
    p_gender        IN  APP_USER.gender%TYPE,
    p_height_cm     IN  APP_USER.height_cm%TYPE,
    p_weight_kg     IN  APP_USER.weight_kg%TYPE,
    p_fitness_goal  IN  APP_USER.fitness_goal%TYPE,
    p_new_user_id   OUT APP_USER.user_id%TYPE
) AS
    v_account_id    ACCOUNT.account_id%TYPE;
    v_count         NUMBER;
BEGIN
    -- Guard: duplicate e-mail check
    SELECT COUNT(*) INTO v_count
    FROM   ACCOUNT
    WHERE  email = p_email;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'E-mail already registered: ' || p_email);
    END IF;

    -- Create account record
    v_account_id := seq_account.NEXTVAL;
    INSERT INTO ACCOUNT (account_id, email, password_hash, phone, account_type, account_status, created_date)
    VALUES (v_account_id, p_email, p_password_hash, p_phone, 'USER', 'ACTIVE', SYSDATE);

    -- Create user profile
    p_new_user_id := seq_user.NEXTVAL;
    INSERT INTO APP_USER (user_id, account_id, first_name, last_name, dob, gender, height_cm, weight_kg, fitness_goal)
    VALUES (p_new_user_id, v_account_id, p_first_name, p_last_name, p_dob, p_gender, p_height_cm, p_weight_kg, p_fitness_goal);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('User registered successfully. User ID: ' || p_new_user_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_REGISTER_USER;
/


-- ============================================================
-- PROCEDURE 2: SP_ENROLL_SUBSCRIPTION
-- Enrolls a user in a subscription tier.
-- Prevents double-enrollment in the same tier while still active.
-- end_date is auto-calculated by TRG_SUBSCRIPTION_END_DATE.
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_ENROLL_SUBSCRIPTION (
    p_user_id           IN  USER_SUBSCRIPTION.user_id%TYPE,
    p_subscription_id   IN  USER_SUBSCRIPTION.subscription_id%TYPE,
    p_start_date        IN  USER_SUBSCRIPTION.start_date%TYPE,
    p_payment_method    IN  USER_SUBSCRIPTION.payment_method%TYPE,
    p_amount_paid       IN  USER_SUBSCRIPTION.amount_paid%TYPE,
    p_user_sub_id       OUT USER_SUBSCRIPTION.user_sub_id%TYPE
) AS
    v_active_count  NUMBER;
    v_end_date      DATE := SYSDATE;    -- placeholder; trigger will overwrite
BEGIN
    -- Guard: check for existing active subscription of same tier
    SELECT COUNT(*) INTO v_active_count
    FROM   USER_SUBSCRIPTION
    WHERE  user_id         = p_user_id
    AND    subscription_id = p_subscription_id
    AND    status          = 'ACTIVE';

    IF v_active_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'User ' || p_user_id || ' already has an active subscription for tier ' || p_subscription_id);
    END IF;

    p_user_sub_id := seq_user_subscription.NEXTVAL;

    -- end_date placeholder — trigger TRG_SUBSCRIPTION_END_DATE recalculates it
    INSERT INTO USER_SUBSCRIPTION
        (user_sub_id, user_id, subscription_id, start_date, end_date, status, payment_method, amount_paid)
    VALUES
        (p_user_sub_id, p_user_id, p_subscription_id, p_start_date, v_end_date, 'ACTIVE', p_payment_method, p_amount_paid);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Subscription enrolled. Record ID: ' || p_user_sub_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_ENROLL_SUBSCRIPTION;
/


-- ============================================================
-- PROCEDURE 3: SP_ASSIGN_WORKOUT_PLAN
-- Assigns a workout plan to a user (by a trainer).
-- Pauses any currently IN_PROGRESS plan for the same user first.
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_ASSIGN_WORKOUT_PLAN (
    p_user_id           IN  USER_WORKOUT_PLAN.user_id%TYPE,
    p_workout_plan_id   IN  USER_WORKOUT_PLAN.workout_plan_id%TYPE,
    p_trainer_id        IN  USER_WORKOUT_PLAN.trainer_id%TYPE,
    p_new_uwp_id        OUT USER_WORKOUT_PLAN.uwp_id%TYPE
) AS
BEGIN
    -- Pause any plan currently IN_PROGRESS for this user
    UPDATE USER_WORKOUT_PLAN
    SET    status = 'PAUSED'
    WHERE  user_id = p_user_id
    AND    status  = 'IN_PROGRESS';

    -- Assign new plan
    p_new_uwp_id := seq_user_workout_plan.NEXTVAL;
    INSERT INTO USER_WORKOUT_PLAN (uwp_id, user_id, workout_plan_id, trainer_id, assigned_date, completion_pct, status)
    VALUES (p_new_uwp_id, p_user_id, p_workout_plan_id, p_trainer_id, SYSDATE, 0, 'IN_PROGRESS');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Workout plan ' || p_workout_plan_id || ' assigned to user ' || p_user_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_ASSIGN_WORKOUT_PLAN;
/


-- ============================================================
-- PROCEDURE 4: SP_LOG_PROGRESS
-- Records a progress check-in for a user.
-- BMI is auto-calculated by TRG_PROGRESS_LOG_BMI trigger.
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_LOG_PROGRESS (
    p_user_id       IN  PROGRESS_LOG.user_id%TYPE,
    p_weight_kg     IN  PROGRESS_LOG.weight_kg%TYPE,
    p_body_fat_pct  IN  PROGRESS_LOG.body_fat_pct%TYPE,
    p_notes         IN  PROGRESS_LOG.notes%TYPE,
    p_log_id        OUT PROGRESS_LOG.log_id%TYPE
) AS
BEGIN
    p_log_id := seq_progress_log.NEXTVAL;
    INSERT INTO PROGRESS_LOG (log_id, user_id, log_date, weight_kg, body_fat_pct, bmi, notes)
    VALUES (p_log_id, p_user_id, SYSDATE, p_weight_kg, p_body_fat_pct, NULL, p_notes);
    -- bmi = NULL here; TRG_PROGRESS_LOG_BMI auto-fills it before insert

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Progress logged. Log ID: ' || p_log_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_LOG_PROGRESS;
/


-- ============================================================
-- PROCEDURE 5: SP_EXPIRE_SUBSCRIPTIONS
-- Batch maintenance procedure: marks all USER_SUBSCRIPTION rows
-- as EXPIRED where end_date < SYSDATE and status = 'ACTIVE'.
-- Intended to be scheduled daily via DBMS_SCHEDULER.
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_EXPIRE_SUBSCRIPTIONS AS
    v_rows_updated NUMBER;
BEGIN
    UPDATE USER_SUBSCRIPTION
    SET    status = 'EXPIRED'
    WHERE  end_date < SYSDATE
    AND    status   = 'ACTIVE';

    v_rows_updated := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SP_EXPIRE_SUBSCRIPTIONS: ' || v_rows_updated || ' subscriptions marked EXPIRED.');
END SP_EXPIRE_SUBSCRIPTIONS;
/


-- ============================================================
-- FUNCTION 1: FN_DAYS_REMAINING
-- Returns the number of calendar days remaining on a user's
-- most recent ACTIVE subscription. Returns -1 if none found.
-- ============================================================
CREATE OR REPLACE FUNCTION FN_DAYS_REMAINING (
    p_user_id IN APP_USER.user_id%TYPE
) RETURN NUMBER AS
    v_days NUMBER;
BEGIN
    SELECT TRUNC(end_date - SYSDATE)
    INTO   v_days
    FROM   USER_SUBSCRIPTION
    WHERE  user_id = p_user_id
    AND    status  = 'ACTIVE'
    ORDER  BY end_date DESC
    FETCH  FIRST 1 ROWS ONLY;

    RETURN v_days;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
END FN_DAYS_REMAINING;
/


-- ============================================================
-- FUNCTION 2: FN_USER_ACTIVE_PLAN_COUNT
-- Returns count of IN_PROGRESS workout plans + ACTIVE meal plans
-- for a given user. Useful for checking subscription plan limits.
-- ============================================================
CREATE OR REPLACE FUNCTION FN_USER_ACTIVE_PLAN_COUNT (
    p_user_id IN APP_USER.user_id%TYPE
) RETURN NUMBER AS
    v_wp_count NUMBER;
    v_mp_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_wp_count
    FROM   USER_WORKOUT_PLAN
    WHERE  user_id = p_user_id AND status = 'IN_PROGRESS';

    SELECT COUNT(*) INTO v_mp_count
    FROM   USER_MEAL_PLAN
    WHERE  user_id = p_user_id AND status = 'ACTIVE';

    RETURN v_wp_count + v_mp_count;
END FN_USER_ACTIVE_PLAN_COUNT;
/

-- ============================================================
-- DEMO: Test the procedures
-- ============================================================
SET SERVEROUTPUT ON;

-- Test SP_LOG_PROGRESS for Sara (user_id=2001)
DECLARE
    v_lid NUMBER;
BEGIN
    SP_LOG_PROGRESS(2001, 59.8, 24.2, 'Mid-month check-in. Feeling strong.', v_lid);
    DBMS_OUTPUT.PUT_LINE('New log ID = ' || v_lid);
END;
/

-- Test FN_DAYS_REMAINING for Ali (user_id=2002)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Days remaining for Ali: ' || FN_DAYS_REMAINING(2002));
END;
/

-- Test FN_USER_ACTIVE_PLAN_COUNT for Zara (user_id=2005)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Active plans for Zara: ' || FN_USER_ACTIVE_PLAN_COUNT(2005));
END;
/

-- End of File 4
