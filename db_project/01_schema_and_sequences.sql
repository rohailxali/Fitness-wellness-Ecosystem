-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM - DATABASE SEMESTER PROJECT
-- Oracle 11g Compatible SQL/PLSQL
-- File 1: Schema, Sequences, Tables, Constraints
-- ============================================================

-- ============================================================
-- SECTION 1: CLEANUP (run only when resetting)
-- ============================================================
-- DROP TABLE PROGRESS_LOG       CASCADE CONSTRAINTS PURGE;
-- DROP TABLE USER_MEAL_PLAN     CASCADE CONSTRAINTS PURGE;
-- DROP TABLE USER_WORKOUT_PLAN  CASCADE CONSTRAINTS PURGE;
-- DROP TABLE USER_SUBSCRIPTION  CASCADE CONSTRAINTS PURGE;
-- DROP TABLE WORKOUT_PLAN_EXERCISE CASCADE CONSTRAINTS PURGE;
-- DROP TABLE MEAL_PLAN          CASCADE CONSTRAINTS PURGE;
-- DROP TABLE WORKOUT_PLAN       CASCADE CONSTRAINTS PURGE;
-- DROP TABLE EXERCISE           CASCADE CONSTRAINTS PURGE;
-- DROP TABLE SUBSCRIPTION       CASCADE CONSTRAINTS PURGE;
-- DROP TABLE TRAINER            CASCADE CONSTRAINTS PURGE;
-- DROP TABLE APP_USER           CASCADE CONSTRAINTS PURGE;
-- DROP TABLE ACCOUNT            CASCADE CONSTRAINTS PURGE;
-- DROP SEQUENCE seq_account;
-- DROP SEQUENCE seq_user;
-- DROP SEQUENCE seq_trainer;
-- DROP SEQUENCE seq_exercise;
-- DROP SEQUENCE seq_workout_plan;
-- DROP SEQUENCE seq_meal_plan;
-- DROP SEQUENCE seq_subscription;
-- DROP SEQUENCE seq_user_subscription;
-- DROP SEQUENCE seq_user_workout_plan;
-- DROP SEQUENCE seq_user_meal_plan;
-- DROP SEQUENCE seq_workout_plan_exercise;
-- DROP SEQUENCE seq_progress_log;

-- ============================================================
-- SECTION 2: SEQUENCES
-- ============================================================

CREATE SEQUENCE seq_account             START WITH 1001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_user                START WITH 2001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_trainer             START WITH 3001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_exercise            START WITH 4001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_workout_plan        START WITH 5001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_meal_plan           START WITH 6001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_subscription        START WITH 7001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_user_subscription   START WITH 8001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_user_workout_plan   START WITH 9001 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_user_meal_plan      START WITH 9501 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_wpe                 START WITH 1     INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_progress_log        START WITH 1     INCREMENT BY 1 NOCACHE NOCYCLE;


-- ============================================================
-- SECTION 3: BASE TABLE - ACCOUNT
-- Holds authentication credentials shared by Users and Trainers
-- ============================================================
CREATE TABLE ACCOUNT (
    account_id      NUMBER(10)      NOT NULL,
    email           VARCHAR2(100)   NOT NULL,
    password_hash   VARCHAR2(255)   NOT NULL,
    phone           VARCHAR2(20),
    account_type    VARCHAR2(10)    NOT NULL,   -- 'USER' or 'TRAINER'
    account_status  VARCHAR2(10)    DEFAULT 'ACTIVE' NOT NULL,
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_account        PRIMARY KEY (account_id),
    CONSTRAINT uq_account_email  UNIQUE (email),
    CONSTRAINT ck_account_type   CHECK (account_type   IN ('USER', 'TRAINER')),
    CONSTRAINT ck_account_status CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

COMMENT ON TABLE  ACCOUNT             IS 'Central authentication table shared by all system actors.';
COMMENT ON COLUMN ACCOUNT.account_id  IS 'Surrogate primary key from seq_account.';
COMMENT ON COLUMN ACCOUNT.email       IS 'Login identifier, globally unique.';
COMMENT ON COLUMN ACCOUNT.phone       IS 'Optional contact phone number.';


-- ============================================================
-- SECTION 4: APP_USER
-- Profile of a registered fitness member
-- (Named APP_USER because USER is a reserved word in Oracle)
-- ============================================================
CREATE TABLE APP_USER (
    user_id         NUMBER(10)      NOT NULL,
    account_id      NUMBER(10)      NOT NULL,
    first_name      VARCHAR2(50)    NOT NULL,
    last_name       VARCHAR2(50)    NOT NULL,
    dob             DATE,
    gender          VARCHAR2(10),
    height_cm       NUMBER(5,2),
    weight_kg       NUMBER(5,2),
    fitness_goal    VARCHAR2(100),  -- e.g. 'Weight Loss', 'Muscle Gain'
    -- ---- Constraints ----
    CONSTRAINT pk_app_user          PRIMARY KEY (user_id),
    CONSTRAINT fk_user_account      FOREIGN KEY (account_id) REFERENCES ACCOUNT(account_id) ON DELETE CASCADE,
    CONSTRAINT uq_user_account      UNIQUE (account_id),
    CONSTRAINT ck_user_gender       CHECK (gender IN ('Male', 'Female', 'Other', NULL)),
    CONSTRAINT ck_user_height       CHECK (height_cm > 0),
    CONSTRAINT ck_user_weight       CHECK (weight_kg > 0)
);

COMMENT ON TABLE  APP_USER           IS 'Fitness member profile; references ACCOUNT for credentials.';
COMMENT ON COLUMN APP_USER.fitness_goal IS 'Self-reported wellness objective of the member.';


-- ============================================================
-- SECTION 5: TRAINER
-- Certified fitness professional who creates plans
-- ============================================================
CREATE TABLE TRAINER (
    trainer_id          NUMBER(10)      NOT NULL,
    account_id          NUMBER(10)      NOT NULL,
    first_name          VARCHAR2(50)    NOT NULL,
    last_name           VARCHAR2(50)    NOT NULL,
    specialization      VARCHAR2(100),  -- e.g. 'Strength Training', 'Yoga'
    certification       VARCHAR2(100),  -- e.g. 'NASM-CPT'
    experience_years    NUMBER(3)       DEFAULT 0,
    hourly_rate         NUMBER(8,2),
    bio                 VARCHAR2(500),
    -- ---- Constraints ----
    CONSTRAINT pk_trainer           PRIMARY KEY (trainer_id),
    CONSTRAINT fk_trainer_account   FOREIGN KEY (account_id) REFERENCES ACCOUNT(account_id) ON DELETE CASCADE,
    CONSTRAINT uq_trainer_account   UNIQUE (account_id),
    CONSTRAINT ck_trainer_exp       CHECK (experience_years >= 0),
    CONSTRAINT ck_trainer_rate      CHECK (hourly_rate >= 0)
);

COMMENT ON TABLE TRAINER IS 'Certified trainer who designs workout and meal plans.';


-- ============================================================
-- SECTION 6: EXERCISE
-- Master catalog of fitness exercises
-- ============================================================
CREATE TABLE EXERCISE (
    exercise_id         NUMBER(10)      NOT NULL,
    exercise_name       VARCHAR2(100)   NOT NULL,
    category            VARCHAR2(50)    NOT NULL,   -- 'Cardio', 'Strength', 'Flexibility', 'HIIT'
    muscle_group        VARCHAR2(50),               -- 'Chest', 'Back', 'Legs', etc.
    difficulty          VARCHAR2(10)    DEFAULT 'Beginner' NOT NULL,
    description         VARCHAR2(500),
    duration_minutes    NUMBER(5,2),
    calories_per_set    NUMBER(6,2),
    equipment_needed    VARCHAR2(100),
    -- ---- Constraints ----
    CONSTRAINT pk_exercise          PRIMARY KEY (exercise_id),
    CONSTRAINT uq_exercise_name     UNIQUE (exercise_name),
    CONSTRAINT ck_exercise_category CHECK (category   IN ('Cardio', 'Strength', 'Flexibility', 'HIIT', 'Balance', 'Sport')),
    CONSTRAINT ck_exercise_diff     CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    CONSTRAINT ck_exercise_dur      CHECK (duration_minutes > 0)
);

COMMENT ON TABLE EXERCISE IS 'Master catalog of all supported exercises on the platform.';


-- ============================================================
-- SECTION 7: SUBSCRIPTION
-- Subscription tier definitions (not per-user; these are plans)
-- ============================================================
CREATE TABLE SUBSCRIPTION (
    subscription_id     NUMBER(10)      NOT NULL,
    plan_name           VARCHAR2(100)   NOT NULL,
    subscription_type   VARCHAR2(20)    NOT NULL,   -- 'Basic', 'Standard', 'Premium'
    price               NUMBER(8,2)     NOT NULL,
    duration_days       NUMBER(5)       NOT NULL,   -- e.g. 30, 90, 365
    max_plans           NUMBER(3)       DEFAULT 2,  -- max workout+meal plans
    trainer_access      VARCHAR2(3)     DEFAULT 'NO',
    features            VARCHAR2(500),
    -- ---- Constraints ----
    CONSTRAINT pk_subscription      PRIMARY KEY (subscription_id),
    CONSTRAINT uq_sub_plan_name     UNIQUE (plan_name),
    CONSTRAINT ck_sub_type          CHECK (subscription_type IN ('Basic', 'Standard', 'Premium')),
    CONSTRAINT ck_sub_price         CHECK (price >= 0),
    CONSTRAINT ck_sub_duration      CHECK (duration_days > 0),
    CONSTRAINT ck_sub_trainer       CHECK (trainer_access IN ('YES', 'NO'))
);

COMMENT ON TABLE SUBSCRIPTION IS 'Subscription tier catalog; describes what each tier offers.';


-- ============================================================
-- SECTION 8: WORKOUT_PLAN
-- A structured multi-week workout program created by a trainer
-- ============================================================
CREATE TABLE WORKOUT_PLAN (
    workout_plan_id     NUMBER(10)      NOT NULL,
    trainer_id          NUMBER(10),                 -- NULL if system-generated
    plan_name           VARCHAR2(100)   NOT NULL,
    goal                VARCHAR2(100),              -- 'Fat Loss', 'Hypertrophy', 'Endurance'
    difficulty          VARCHAR2(10)    NOT NULL,
    duration_weeks      NUMBER(3)       NOT NULL,
    description         VARCHAR2(500),
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_workout_plan      PRIMARY KEY (workout_plan_id),
    CONSTRAINT fk_wp_trainer        FOREIGN KEY (trainer_id) REFERENCES TRAINER(trainer_id) ON DELETE SET NULL,
    CONSTRAINT ck_wp_difficulty     CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    CONSTRAINT ck_wp_duration       CHECK (duration_weeks > 0)
);

COMMENT ON TABLE WORKOUT_PLAN IS 'A structured workout program optionally authored by a trainer.';


-- ============================================================
-- SECTION 9: WORKOUT_PLAN_EXERCISE  (Junction / Bridge Table)
-- Resolves the M:N relationship between WORKOUT_PLAN and EXERCISE
-- ============================================================
CREATE TABLE WORKOUT_PLAN_EXERCISE (
    wpe_id              NUMBER(10)      NOT NULL,
    workout_plan_id     NUMBER(10)      NOT NULL,
    exercise_id         NUMBER(10)      NOT NULL,
    day_number          NUMBER(3)       NOT NULL,   -- which day in the plan (1–7 cycle)
    sets                NUMBER(3),
    reps                NUMBER(3),
    rest_seconds        NUMBER(5),
    notes               VARCHAR2(200),
    -- ---- Constraints ----
    CONSTRAINT pk_wpe               PRIMARY KEY (wpe_id),
    CONSTRAINT fk_wpe_workout_plan  FOREIGN KEY (workout_plan_id) REFERENCES WORKOUT_PLAN(workout_plan_id) ON DELETE CASCADE,
    CONSTRAINT fk_wpe_exercise      FOREIGN KEY (exercise_id)     REFERENCES EXERCISE(exercise_id)     ON DELETE CASCADE,
    CONSTRAINT uq_wpe               UNIQUE (workout_plan_id, exercise_id, day_number),
    CONSTRAINT ck_wpe_day           CHECK (day_number BETWEEN 1 AND 7),
    CONSTRAINT ck_wpe_sets          CHECK (sets > 0),
    CONSTRAINT ck_wpe_reps          CHECK (reps > 0)
);

COMMENT ON TABLE WORKOUT_PLAN_EXERCISE IS 'Bridge table: which exercises appear in which plan, on which day.';


-- ============================================================
-- SECTION 10: MEAL_PLAN
-- Nutritional plan authored by a trainer
-- ============================================================
CREATE TABLE MEAL_PLAN (
    meal_plan_id        NUMBER(10)      NOT NULL,
    trainer_id          NUMBER(10),
    plan_name           VARCHAR2(100)   NOT NULL,
    goal                VARCHAR2(100),              -- 'Weight Loss', 'Muscle Gain', 'Maintenance'
    calories_per_day    NUMBER(6),
    protein_g           NUMBER(6,2),
    carbs_g             NUMBER(6,2),
    fats_g              NUMBER(6,2),
    description         VARCHAR2(500),
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_meal_plan         PRIMARY KEY (meal_plan_id),
    CONSTRAINT fk_mp_trainer        FOREIGN KEY (trainer_id) REFERENCES TRAINER(trainer_id) ON DELETE SET NULL,
    CONSTRAINT ck_mp_calories       CHECK (calories_per_day > 0),
    CONSTRAINT ck_mp_protein        CHECK (protein_g >= 0),
    CONSTRAINT ck_mp_carbs          CHECK (carbs_g >= 0),
    CONSTRAINT ck_mp_fats           CHECK (fats_g >= 0)
);

COMMENT ON TABLE MEAL_PLAN IS 'Nutritional meal plan optionally designed by a trainer.';


-- ============================================================
-- SECTION 11: USER_SUBSCRIPTION
-- Records which user enrolled in which subscription tier and when
-- ============================================================
CREATE TABLE USER_SUBSCRIPTION (
    user_sub_id         NUMBER(10)      NOT NULL,
    user_id             NUMBER(10)      NOT NULL,
    subscription_id     NUMBER(10)      NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,   -- derived from start_date + duration_days
    status              VARCHAR2(10)    DEFAULT 'ACTIVE' NOT NULL,
    payment_method      VARCHAR2(30),
    amount_paid         NUMBER(8,2)     NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_user_subscription PRIMARY KEY (user_sub_id),
    CONSTRAINT fk_us_user           FOREIGN KEY (user_id)         REFERENCES APP_USER(user_id)     ON DELETE CASCADE,
    CONSTRAINT fk_us_subscription   FOREIGN KEY (subscription_id) REFERENCES SUBSCRIPTION(subscription_id),
    CONSTRAINT ck_us_status         CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED')),
    CONSTRAINT ck_us_dates          CHECK (end_date > start_date),
    CONSTRAINT ck_us_amount         CHECK (amount_paid >= 0)
);

COMMENT ON TABLE USER_SUBSCRIPTION IS 'Enrollment record linking a user to a subscription tier with dates.';


-- ============================================================
-- SECTION 12: USER_WORKOUT_PLAN
-- Tracks which workout plan a user is following
-- ============================================================
CREATE TABLE USER_WORKOUT_PLAN (
    uwp_id              NUMBER(10)      NOT NULL,
    user_id             NUMBER(10)      NOT NULL,
    workout_plan_id     NUMBER(10)      NOT NULL,
    trainer_id          NUMBER(10),                 -- trainer who assigned it
    assigned_date       DATE            DEFAULT SYSDATE NOT NULL,
    completion_pct      NUMBER(5,2)     DEFAULT 0,
    status              VARCHAR2(15)    DEFAULT 'IN_PROGRESS' NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_user_workout_plan PRIMARY KEY (uwp_id),
    CONSTRAINT fk_uwp_user          FOREIGN KEY (user_id)         REFERENCES APP_USER(user_id)     ON DELETE CASCADE,
    CONSTRAINT fk_uwp_workout_plan  FOREIGN KEY (workout_plan_id) REFERENCES WORKOUT_PLAN(workout_plan_id),
    CONSTRAINT fk_uwp_trainer       FOREIGN KEY (trainer_id)      REFERENCES TRAINER(trainer_id)   ON DELETE SET NULL,
    CONSTRAINT ck_uwp_status        CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'PAUSED', 'DROPPED')),
    CONSTRAINT ck_uwp_completion    CHECK (completion_pct BETWEEN 0 AND 100)
);

COMMENT ON TABLE USER_WORKOUT_PLAN IS 'Tracks the active workout plan assigned to each user.';


-- ============================================================
-- SECTION 13: USER_MEAL_PLAN
-- Tracks which meal plan a user is following
-- ============================================================
CREATE TABLE USER_MEAL_PLAN (
    ump_id              NUMBER(10)      NOT NULL,
    user_id             NUMBER(10)      NOT NULL,
    meal_plan_id        NUMBER(10)      NOT NULL,
    trainer_id          NUMBER(10),
    assigned_date       DATE            DEFAULT SYSDATE NOT NULL,
    status              VARCHAR2(15)    DEFAULT 'ACTIVE' NOT NULL,
    -- ---- Constraints ----
    CONSTRAINT pk_user_meal_plan    PRIMARY KEY (ump_id),
    CONSTRAINT fk_ump_user          FOREIGN KEY (user_id)      REFERENCES APP_USER(user_id)  ON DELETE CASCADE,
    CONSTRAINT fk_ump_meal_plan     FOREIGN KEY (meal_plan_id) REFERENCES MEAL_PLAN(meal_plan_id),
    CONSTRAINT fk_ump_trainer       FOREIGN KEY (trainer_id)   REFERENCES TRAINER(trainer_id) ON DELETE SET NULL,
    CONSTRAINT ck_ump_status        CHECK (status IN ('ACTIVE', 'COMPLETED', 'PAUSED'))
);

COMMENT ON TABLE USER_MEAL_PLAN IS 'Tracks the meal plan currently assigned to each user.';


-- ============================================================
-- SECTION 14: PROGRESS_LOG
-- Periodic wellness check-ins recorded by the user
-- ============================================================
CREATE TABLE PROGRESS_LOG (
    log_id              NUMBER(10)      NOT NULL,
    user_id             NUMBER(10)      NOT NULL,
    log_date            DATE            DEFAULT SYSDATE NOT NULL,
    weight_kg           NUMBER(5,2),
    body_fat_pct        NUMBER(5,2),
    bmi                 NUMBER(5,2),
    notes               VARCHAR2(500),
    -- ---- Constraints ----
    CONSTRAINT pk_progress_log      PRIMARY KEY (log_id),
    CONSTRAINT fk_pl_user           FOREIGN KEY (user_id) REFERENCES APP_USER(user_id) ON DELETE CASCADE,
    CONSTRAINT ck_pl_weight         CHECK (weight_kg > 0),
    CONSTRAINT ck_pl_bf             CHECK (body_fat_pct BETWEEN 0 AND 70),
    CONSTRAINT ck_pl_bmi            CHECK (bmi > 0)
);

COMMENT ON TABLE PROGRESS_LOG IS 'Periodic wellness check-in records submitted by the user.';

-- End of File 1
