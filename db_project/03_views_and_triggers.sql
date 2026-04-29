-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 3: Views and Triggers
-- Execute AFTER 02_sample_data.sql
-- ============================================================


-- ============================================================
-- SECTION 1: VIEWS
-- ============================================================

-- ------------------------------------------------------------
-- VIEW 1: VW_ACTIVE_SUBSCRIPTIONS
-- Purpose : Shows every currently active user subscription with
--           tier details, user name, days remaining (derived).
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW VW_ACTIVE_SUBSCRIPTIONS AS
SELECT
    us.user_sub_id,
    u.user_id,
    u.first_name || ' ' || u.last_name               AS full_name,
    a.email,
    s.plan_name                                       AS subscription_name,
    s.subscription_type,
    s.price                                           AS tier_price,
    us.amount_paid,
    us.start_date,
    us.end_date,
    (us.end_date - SYSDATE)                           AS days_remaining,
    us.payment_method,
    us.status
FROM USER_SUBSCRIPTION us
JOIN APP_USER          u  ON us.user_id         = u.user_id
JOIN ACCOUNT           a  ON u.account_id       = a.account_id
JOIN SUBSCRIPTION      s  ON us.subscription_id = s.subscription_id
WHERE us.status = 'ACTIVE';

COMMENT ON TABLE VW_ACTIVE_SUBSCRIPTIONS IS
    'Shows all currently ACTIVE user subscriptions with days_remaining derived from end_date - SYSDATE.';


-- ------------------------------------------------------------
-- VIEW 2: VW_USER_WELLNESS_OVERVIEW
-- Purpose : One-row-per-user wellness summary: latest weight,
--           body fat, active plans, subscription tier.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW VW_USER_WELLNESS_OVERVIEW AS
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name               AS full_name,
    u.gender,
    u.fitness_goal,
    -- Latest progress log entry (most recent by log_date)
    pl.weight_kg                                      AS latest_weight_kg,
    pl.body_fat_pct                                   AS latest_body_fat_pct,
    pl.bmi                                            AS latest_bmi,
    pl.log_date                                       AS last_checkin_date,
    -- Active workout plan name
    wp.plan_name                                      AS active_workout_plan,
    uwp.completion_pct                                AS workout_completion_pct,
    -- Active meal plan name
    mp.plan_name                                      AS active_meal_plan,
    -- Active subscription
    s.subscription_type                               AS subscription_tier
FROM APP_USER u
-- Latest progress log via correlated subquery approach (scalar)
LEFT JOIN PROGRESS_LOG pl ON pl.log_id = (
    SELECT pl2.log_id
    FROM   PROGRESS_LOG pl2
    WHERE  pl2.user_id = u.user_id
    ORDER  BY pl2.log_date DESC
    FETCH  FIRST 1 ROWS ONLY
)
-- Active workout plan
LEFT JOIN USER_WORKOUT_PLAN uwp ON uwp.user_id = u.user_id
                                AND uwp.status  = 'IN_PROGRESS'
LEFT JOIN WORKOUT_PLAN      wp  ON uwp.workout_plan_id = wp.workout_plan_id
-- Active meal plan
LEFT JOIN USER_MEAL_PLAN    ump ON ump.user_id = u.user_id
                                AND ump.status  = 'ACTIVE'
LEFT JOIN MEAL_PLAN         mp  ON ump.meal_plan_id = mp.meal_plan_id
-- Active subscription
LEFT JOIN USER_SUBSCRIPTION us  ON us.user_id = u.user_id
                                AND us.status  = 'ACTIVE'
LEFT JOIN SUBSCRIPTION       s  ON us.subscription_id = s.subscription_id;

COMMENT ON TABLE VW_USER_WELLNESS_OVERVIEW IS
    'Consolidated wellness dashboard view per user: latest progress, active plans, and subscription tier.';


-- ------------------------------------------------------------
-- VIEW 3: VW_TRAINER_PLAN_SUMMARY
-- Purpose : Trainer-wise count of workout and meal plans created.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW VW_TRAINER_PLAN_SUMMARY AS
SELECT
    t.trainer_id,
    t.first_name || ' ' || t.last_name  AS trainer_name,
    t.specialization,
    t.experience_years,
    t.hourly_rate,
    COUNT(DISTINCT wp.workout_plan_id)   AS total_workout_plans,
    COUNT(DISTINCT mp.meal_plan_id)      AS total_meal_plans,
    COUNT(DISTINCT wp.workout_plan_id)
    + COUNT(DISTINCT mp.meal_plan_id)    AS total_plans
FROM TRAINER     t
LEFT JOIN WORKOUT_PLAN wp ON wp.trainer_id = t.trainer_id
LEFT JOIN MEAL_PLAN    mp ON mp.trainer_id = t.trainer_id
GROUP BY
    t.trainer_id, t.first_name, t.last_name,
    t.specialization, t.experience_years, t.hourly_rate;

COMMENT ON TABLE VW_TRAINER_PLAN_SUMMARY IS
    'Trainer-level aggregation: how many workout and meal plans each trainer has authored.';


-- ------------------------------------------------------------
-- VIEW 4: VW_WORKOUT_PLAN_DETAILS
-- Purpose : Flat view of each workout plan with exercises per day.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW VW_WORKOUT_PLAN_DETAILS AS
SELECT
    wp.workout_plan_id,
    wp.plan_name                                      AS workout_plan_name,
    wp.goal,
    wp.difficulty,
    wp.duration_weeks,
    t.first_name || ' ' || t.last_name               AS trainer_name,
    wpe.day_number,
    e.exercise_name,
    e.category                                        AS exercise_category,
    e.muscle_group,
    wpe.sets,
    wpe.reps,
    wpe.rest_seconds,
    wpe.notes                                         AS exercise_notes
FROM WORKOUT_PLAN          wp
JOIN WORKOUT_PLAN_EXERCISE wpe ON wpe.workout_plan_id = wp.workout_plan_id
JOIN EXERCISE              e   ON wpe.exercise_id     = e.exercise_id
LEFT JOIN TRAINER          t   ON wp.trainer_id       = t.trainer_id
ORDER BY wp.workout_plan_id, wpe.day_number, e.exercise_name;

COMMENT ON TABLE VW_WORKOUT_PLAN_DETAILS IS
    'Flattened view of workout plans with all exercise details per day.';


-- ============================================================
-- SECTION 2: TRIGGERS
-- ============================================================

-- ------------------------------------------------------------
-- TRIGGER 1: TRG_ACCOUNT_TYPE_SYNC
-- Fired BEFORE INSERT on ACCOUNT.
-- Ensures account_type is stored in UPPER CASE consistently.
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_ACCOUNT_TYPE_SYNC
BEFORE INSERT OR UPDATE OF account_type ON ACCOUNT
FOR EACH ROW
BEGIN
    :NEW.account_type   := UPPER(TRIM(:NEW.account_type));
    :NEW.account_status := UPPER(TRIM(:NEW.account_status));
END;
/

-- ------------------------------------------------------------
-- TRIGGER 2: TRG_SUBSCRIPTION_END_DATE
-- Fired BEFORE INSERT on USER_SUBSCRIPTION.
-- Automatically calculates end_date = start_date + duration_days
-- from the referenced SUBSCRIPTION tier, preventing manual errors.
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_SUBSCRIPTION_END_DATE
BEFORE INSERT ON USER_SUBSCRIPTION
FOR EACH ROW
DECLARE
    v_duration NUMBER;
BEGIN
    -- Fetch duration from the chosen subscription tier
    SELECT duration_days
    INTO   v_duration
    FROM   SUBSCRIPTION
    WHERE  subscription_id = :NEW.subscription_id;

    -- Override whatever was supplied — end_date is always derived
    :NEW.end_date := :NEW.start_date + v_duration;
END;
/

-- ------------------------------------------------------------
-- TRIGGER 3: TRG_PROGRESS_LOG_BMI
-- Fired BEFORE INSERT OR UPDATE on PROGRESS_LOG.
-- Auto-calculates BMI from weight and user's height on record,
-- so the application never needs to send it explicitly.
-- BMI = weight_kg / (height_m ^ 2)
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_PROGRESS_LOG_BMI
BEFORE INSERT OR UPDATE OF weight_kg ON PROGRESS_LOG
FOR EACH ROW
DECLARE
    v_height_cm NUMBER;
BEGIN
    SELECT height_cm
    INTO   v_height_cm
    FROM   APP_USER
    WHERE  user_id = :NEW.user_id;

    IF v_height_cm IS NOT NULL AND v_height_cm > 0 THEN
        :NEW.bmi := ROUND(:NEW.weight_kg / POWER(v_height_cm / 100, 2), 2);
    END IF;
END;
/

-- ------------------------------------------------------------
-- TRIGGER 4: TRG_WORKOUT_PLAN_COMPLETE
-- Fired AFTER UPDATE on USER_WORKOUT_PLAN.
-- When completion_pct reaches 100, automatically sets
-- status = 'COMPLETED'. Enforces business rule consistency.
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_WORKOUT_PLAN_COMPLETE
BEFORE UPDATE OF completion_pct ON USER_WORKOUT_PLAN
FOR EACH ROW
BEGIN
    IF :NEW.completion_pct >= 100 THEN
        :NEW.completion_pct := 100;
        :NEW.status         := 'COMPLETED';
    END IF;
END;
/

-- ------------------------------------------------------------
-- TRIGGER 5: TRG_SUBSCRIPTION_STATUS_SYNC
-- Fired BEFORE UPDATE on USER_SUBSCRIPTION.
-- If end_date has passed, forces status to EXPIRED
-- so stale records are cleaned up automatically on any update.
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_SUBSCRIPTION_STATUS_SYNC
BEFORE UPDATE ON USER_SUBSCRIPTION
FOR EACH ROW
BEGIN
    IF :NEW.end_date < SYSDATE AND :NEW.status = 'ACTIVE' THEN
        :NEW.status := 'EXPIRED';
    END IF;
END;
/

-- End of File 3
