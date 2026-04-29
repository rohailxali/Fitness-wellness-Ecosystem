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
    day_number          NUMBER(3)       NOT NULL,   -- which day in the plan (1â€“7 cycle)
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
-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 2: Sample Data (INSERT Statements)
-- Execute AFTER 01_schema_and_sequences.sql
-- ============================================================

-- ============================================================
-- 2.1  ACCOUNT rows  (5 Users + 3 Trainers = 8 accounts)
-- ============================================================
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'sara.khan@email.com',    'hashed_pw_001', '0300-1234567', 'USER',    'ACTIVE',   DATE '2024-01-10');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'ali.raza@email.com',     'hashed_pw_002', '0301-2345678', 'USER',    'ACTIVE',   DATE '2024-02-15');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'maryam.noor@email.com',  'hashed_pw_003', '0302-3456789', 'USER',    'ACTIVE',   DATE '2024-03-01');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'hamza.tariq@email.com',  'hashed_pw_004', '0303-4567890', 'USER',    'INACTIVE', DATE '2024-03-20');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'zara.sheikh@email.com',  'hashed_pw_005', '0304-5678901', 'USER',    'ACTIVE',   DATE '2024-04-05');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'coach.arif@fit.com',     'hashed_pw_006', '0311-1112222', 'TRAINER', 'ACTIVE',   DATE '2023-06-01');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'trainer.hina@fit.com',   'hashed_pw_007', '0312-2223333', 'TRAINER', 'ACTIVE',   DATE '2023-07-15');
INSERT INTO ACCOUNT VALUES (seq_account.NEXTVAL, 'coach.bilal@fit.com',    'hashed_pw_008', '0313-3334444', 'TRAINER', 'ACTIVE',   DATE '2023-09-01');


-- ============================================================
-- 2.2  APP_USER rows
-- account_id values are 1001..1005 (first 5 accounts above)
-- ============================================================
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1001, 'Sara',   'Khan',   DATE '1995-04-12', 'Female', 162.0, 65.0, 'Weight Loss');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1002, 'Ali',    'Raza',   DATE '1990-09-25', 'Male',   175.0, 82.0, 'Muscle Gain');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1003, 'Maryam', 'Noor',   DATE '1998-01-30', 'Female', 158.0, 58.0, 'Maintenance');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1004, 'Hamza',  'Tariq',  DATE '1993-07-14', 'Male',   180.0, 90.0, 'Muscle Gain');
INSERT INTO APP_USER VALUES (seq_user.NEXTVAL, 1005, 'Zara',   'Sheikh', DATE '2000-11-05', 'Female', 165.0, 60.0, 'Endurance');


-- ============================================================
-- 2.3  TRAINER rows
-- account_id values are 1006..1008
-- ============================================================
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1006, 'Arif',  'Mehmood', 'Strength & Conditioning', 'NASM-CPT',     8,  75.00,
    'Certified strength coach with 8 years of experience helping clients build lean muscle and improve athletic performance.');
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1007, 'Hina',  'Baig',    'Nutrition & Weight Loss', 'ACE-CPT',      5,  60.00,
    'Specialist in sustainable weight management through clean nutrition and low-impact cardio programs.');
INSERT INTO TRAINER VALUES (seq_trainer.NEXTVAL, 1008, 'Bilal', 'Shahid',  'HIIT & Functional Fitness', 'ISSA-CSCS', 10, 90.00,
    'Elite functional fitness trainer. Focuses on metabolic conditioning and sport-specific performance gains.');


-- ============================================================
-- 2.4  EXERCISE catalog  (12 exercises across categories)
-- ============================================================
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Barbell Back Squat',    'Strength',    'Legs',         'Intermediate', 'Compound lower-body movement targeting quads, glutes, and hamstrings.',          8,   45.00, 'Barbell, Rack');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Flat Bench Press',      'Strength',    'Chest',        'Intermediate', 'Classic horizontal push targeting the pectoralis major and triceps.',            8,   40.00, 'Barbell, Bench');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Pull-Up',               'Strength',    'Back',         'Intermediate', 'Vertical pull using bodyweight; develops lats and biceps.',                       6,   30.00, 'Pull-up Bar');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Romanian Deadlift',     'Strength',    'Hamstrings',   'Intermediate', 'Hip-hinge movement focusing on the posterior chain.',                             8,   42.00, 'Barbell');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Treadmill Running',     'Cardio',      'Full Body',    'Beginner',     '30-minute steady-state cardio run at moderate pace.',                             30,  200.00,'Treadmill');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Cycling (Stationary)',  'Cardio',      'Legs',         'Beginner',     'Low-impact cardio on a stationary bike targeting aerobic capacity.',               25,  180.00,'Stationary Bike');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Kettlebell Swing',      'HIIT',        'Full Body',    'Intermediate', 'Explosive hip-hinge movement that elevates heart rate and strengthens posterior chain.', 5, 35.00, 'Kettlebell');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Battle Ropes',          'HIIT',        'Shoulders',    'Advanced',     'High-intensity upper-body cardio using heavy ropes.',                             4,   50.00, 'Battle Ropes');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Yoga Sun Salutation',   'Flexibility', 'Full Body',    'Beginner',     'Classical yoga sequence improving flexibility, breath control, and mindfulness.', 20,  80.00, 'Yoga Mat');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Foam Rolling (ITB)',    'Flexibility', 'Legs',         'Beginner',     'Self-myofascial release targeting the iliotibial band.',                          10,  20.00, 'Foam Roller');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Plank Hold',            'Strength',    'Core',         'Beginner',     'Isometric core stability exercise.',                                              5,   15.00, 'None');
INSERT INTO EXERCISE VALUES (seq_exercise.NEXTVAL, 'Box Jump',              'HIIT',        'Legs',         'Advanced',     'Explosive plyometric jump onto a raised platform.',                               6,   40.00, 'Plyo Box');


-- ============================================================
-- 2.5  SUBSCRIPTION tiers
-- ============================================================
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Basic Monthly',     'Basic',    999.00,  30,  2, 'NO',
    'Access to workout library, 2 plans, community forum');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Standard Quarterly','Standard', 2499.00, 90,  5, 'YES',
    'All Basic features + trainer messaging, 5 plans, progress tracking');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Premium Annual',    'Premium',  7999.00, 365, 99,'YES',
    'All Standard features + unlimited plans, live sessions, nutrition coaching, priority support');
INSERT INTO SUBSCRIPTION VALUES (seq_subscription.NEXTVAL, 'Basic Quarterly',   'Basic',    2499.00, 90,  2, 'NO',
    'Access to workout library, 2 plans, community forum - 3 month bundle');


-- ============================================================
-- 2.6  WORKOUT_PLAN  (4 plans authored by trainers)
-- trainer_id: 3001=Arif, 3002=Hina, 3003=Bilal
-- ============================================================
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3001, 'Power Builder 8-Week',        'Muscle Gain',  'Intermediate', 8,  'Progressive overload strength program. 4 days per week focusing on compound lifts.',            DATE '2024-01-15');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3002, 'Lean & Light 6-Week',         'Weight Loss',  'Beginner',     6,  'Combination of cardio and bodyweight resistance. 5 days per week with active rest days.',       DATE '2024-02-01');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3003, 'HIIT Shred 4-Week',           'Fat Loss',     'Advanced',     4,  'Intense metabolic conditioning using HIIT circuits. Not for beginners. 5 days per week.',       DATE '2024-02-20');
INSERT INTO WORKOUT_PLAN VALUES (seq_workout_plan.NEXTVAL, 3001, 'Functional Athlete 12-Week',  'Endurance',    'Intermediate', 12, 'Sport-specific conditioning plan blending strength and stamina work. 4 days per week.',        DATE '2024-03-10');


-- ============================================================
-- 2.7  WORKOUT_PLAN_EXERCISE (bridge rows)
-- workout_plan_id: 5001=Power Builder, 5002=Lean & Light
--                 5003=HIIT Shred,    5004=Functional Athlete
-- exercise_id:    4001..4012
-- ============================================================
-- Power Builder  (Day 1: Chest/Triceps, Day 2: Back/Biceps, Day 3: Legs)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4002, 1, 4, 8,  90, 'Primary chest movement. Increase weight each week.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4011, 1, 3, 60, 45, 'Superset with bench press as finisher.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4003, 2, 4, 6,  90, 'Weighted if possible. Full range of motion.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4001, 3, 5, 5,  120,'Heavy squat. Warm up thoroughly.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5001, 4004, 3, 3, 10, 90, 'Romanian deadlift as accessory lift.');

-- Lean & Light  (Day 1: Cardio, Day 2: Flexibility + Core)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4005, 1, 1, 1,  0,  '30-min moderate pace run. Keep HR 130-150 bpm.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4011, 2, 3, 30, 30, 'Plank hold for 30 seconds per set.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4009, 2, 2, 1,  0,  'Full sun salutation sequence (12 poses).');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5002, 4006, 3, 1, 1,  0,  '25-minute cycling interval session.');

-- HIIT Shred  (Day 1: Battle circuits, Day 2: Plyometrics)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4007, 1, 4, 20, 30, 'Kettlebell swings in 20-rep bursts. Short rest.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4008, 1, 3, 30, 45, 'Battle ropes 30-sec all-out effort.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5003, 4012, 2, 4, 10, 60, 'Box jumps with controlled landing.');

-- Functional Athlete  (Day 1: Lower, Day 2: Upper, Day 3: Conditioning)
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4001, 1, 4, 6,  120,'Squat with pause at bottom.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4004, 1, 3, 8,  90, 'Hip hinge focus.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4002, 2, 4, 8,  90, 'Bench press moderate load.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4003, 2, 4, 6,  90, 'Weighted pull-ups if possible.');
INSERT INTO WORKOUT_PLAN_EXERCISE VALUES (seq_wpe.NEXTVAL, 5004, 4005, 3, 1, 1,  0,  'Endurance run 30 min.');


-- ============================================================
-- 2.8  MEAL_PLAN
-- ============================================================
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3001, 'Muscle Builder Nutrition',   'Muscle Gain',  3200, 200.0, 350.0, 80.0,
    'High-protein, high-calorie plan supporting hypertrophy. Emphasizes lean meats, complex carbs, healthy fats.',        DATE '2024-01-15');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3002, 'Caloric Deficit Clean Eat',  'Weight Loss',  1600, 130.0, 150.0, 45.0,
    'Moderate deficit plan using whole foods. Low sugar, high fibre, lean protein priority.',                              DATE '2024-02-01');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3002, 'Maintenance Balance Plan',   'Maintenance',  2000, 150.0, 220.0, 55.0,
    'Balanced macros for maintaining current weight while supporting moderate activity.',                                  DATE '2024-03-05');
INSERT INTO MEAL_PLAN VALUES (seq_meal_plan.NEXTVAL, 3003, 'Performance Fuel Plan',      'Endurance',    2800, 170.0, 360.0, 65.0,
    'Carb-focused plan designed for athletes with high training volume. Supports glycogen replenishment.',                 DATE '2024-03-10');


-- ============================================================
-- 2.9  USER_SUBSCRIPTION
-- user_id: 2001=Sara, 2002=Ali, 2003=Maryam, 2004=Hamza, 2005=Zara
-- subscription_id: 7001=Basic Monthly, 7002=Standard Quarterly,
--                  7003=Premium Annual, 7004=Basic Quarterly
-- ============================================================
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2001, 7003, DATE '2024-01-10', DATE '2025-01-09', 'ACTIVE',   'Credit Card', 7999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2002, 7002, DATE '2024-02-15', DATE '2024-05-14', 'EXPIRED',  'Debit Card',  2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2002, 7003, DATE '2024-05-15', DATE '2025-05-14', 'ACTIVE',   'Credit Card', 7999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2003, 7001, DATE '2024-03-01', DATE '2024-03-31', 'EXPIRED',  'JazzCash',    999.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2003, 7002, DATE '2024-04-01', DATE '2024-06-30', 'ACTIVE',   'JazzCash',    2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2004, 7004, DATE '2024-03-20', DATE '2024-06-17', 'CANCELLED','EasyPaisa',   2499.00);
INSERT INTO USER_SUBSCRIPTION VALUES (seq_user_subscription.NEXTVAL, 2005, 7002, DATE '2024-04-05', DATE '2024-07-04', 'ACTIVE',   'Credit Card', 2499.00);


-- ============================================================
-- 2.10  USER_WORKOUT_PLAN
-- ============================================================
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2001, 5002, 3002, DATE '2024-01-12', 100.00, 'COMPLETED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2001, 5001, 3001, DATE '2024-02-20', 62.50,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2002, 5001, 3001, DATE '2024-02-18', 87.50,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2002, 5004, 3001, DATE '2024-03-01', 33.33,  'PAUSED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2003, 5002, 3002, DATE '2024-04-05', 50.00,  'IN_PROGRESS');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2004, 5003, 3003, DATE '2024-03-22', 25.00,  'DROPPED');
INSERT INTO USER_WORKOUT_PLAN VALUES (seq_user_workout_plan.NEXTVAL, 2005, 5004, 3001, DATE '2024-04-10', 41.67,  'IN_PROGRESS');


-- ============================================================
-- 2.11  USER_MEAL_PLAN
-- ============================================================
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2001, 6002, 3002, DATE '2024-01-12', 'COMPLETED');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2001, 6001, 3001, DATE '2024-02-20', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2002, 6001, 3001, DATE '2024-02-18', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2003, 6003, 3002, DATE '2024-04-05', 'ACTIVE');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2004, 6002, 3002, DATE '2024-03-22', 'PAUSED');
INSERT INTO USER_MEAL_PLAN VALUES (seq_user_meal_plan.NEXTVAL, 2005, 6004, 3003, DATE '2024-04-10', 'ACTIVE');


-- ============================================================
-- 2.12  PROGRESS_LOG  (wellness check-ins for active users)
-- ============================================================
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-01-15', 65.0, 28.5, 24.8, 'Starting measurement. Feeling motivated.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-02-15', 63.2, 27.1, 24.1, 'Lost 1.8 kg. Energy levels improving. Sleep better.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-03-15', 61.5, 25.9, 23.4, 'Consistent progress. Reduced body fat by 2.6% since start.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2001, DATE '2024-04-15', 60.1, 24.8, 22.9, 'On track for goal. Considering switching to maintenance plan.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-02-20', 82.0, 18.0, 26.8, 'Baseline. Ready to bulk up. Diet in check.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-03-20', 83.4, 17.5, 27.2, 'Gained 1.4 kg lean mass. Strength PRs on bench and squat.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2002, DATE '2024-04-20', 84.8, 17.1, 27.7, 'Excellent progress. Bench press up by 10 kg in 2 months.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2003, DATE '2024-04-07', 58.0, 22.0, 23.3, 'Initial check-in. Maintenance goal. No major changes expected.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2005, DATE '2024-04-12', 60.0, 20.5, 22.0, 'Starting endurance program. 5k run time: 32 minutes.');
INSERT INTO PROGRESS_LOG VALUES (seq_progress_log.NEXTVAL, 2005, DATE '2024-04-26', 59.5, 20.0, 21.8, 'Feeling fitter. 5k run time improved to 29 minutes.');

COMMIT;

-- End of File 2
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

    -- Override whatever was supplied â€” end_date is always derived
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

    -- end_date placeholder â€” trigger TRG_SUBSCRIPTION_END_DATE recalculates it
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
-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 5: Demo Queries â€” Joins, Subqueries, View Reads
-- Execute AFTER 04_procedures_and_functions.sql
-- ============================================================

-- ============================================================
-- PART A: JOIN QUERIES (5+ joins demonstrated)
-- ============================================================

-- ----------------------------------------------------------------
-- JOIN 1: One-to-Many â€” User â†’ User_Subscription â†’ Subscription
-- Shows every user and their subscription history with tier name.
-- Relationship: one USER has many USER_SUBSCRIPTION records.
-- ----------------------------------------------------------------
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name  AS full_name,
    s.plan_name                          AS tier,
    s.subscription_type,
    us.start_date,
    us.end_date,
    us.status,
    us.amount_paid
FROM APP_USER           u
JOIN USER_SUBSCRIPTION  us ON us.user_id         = u.user_id
JOIN SUBSCRIPTION       s  ON us.subscription_id = s.subscription_id
ORDER BY u.user_id, us.start_date;


-- ----------------------------------------------------------------
-- JOIN 2: One-to-Many â€” Trainer â†’ Workout_Plan
-- Lists trainers alongside every plan they created.
-- Relationship: one TRAINER authors many WORKOUT_PLANs.
-- ----------------------------------------------------------------
SELECT
    t.trainer_id,
    t.first_name || ' ' || t.last_name  AS trainer_name,
    t.specialization,
    wp.workout_plan_id,
    wp.plan_name                         AS workout_plan,
    wp.goal,
    wp.difficulty,
    wp.duration_weeks
FROM TRAINER        t
JOIN WORKOUT_PLAN   wp ON wp.trainer_id = t.trainer_id
ORDER BY t.trainer_id, wp.workout_plan_id;


-- ----------------------------------------------------------------
-- JOIN 3: Many-to-Many â€” Workout_Plan â†” Exercise (via bridge)
-- Shows every exercise in every workout plan with sets/reps.
-- Relationship: WORKOUT_PLAN_EXERCISE resolves the M:N.
-- ----------------------------------------------------------------
SELECT
    wp.plan_name                         AS workout_plan,
    wp.goal,
    wpe.day_number,
    e.exercise_name,
    e.category,
    e.muscle_group,
    wpe.sets,
    wpe.reps,
    wpe.rest_seconds || 's'             AS rest
FROM WORKOUT_PLAN           wp
JOIN WORKOUT_PLAN_EXERCISE  wpe ON wpe.workout_plan_id = wp.workout_plan_id
JOIN EXERCISE               e   ON wpe.exercise_id     = e.exercise_id
ORDER BY wp.workout_plan_id, wpe.day_number;


-- ----------------------------------------------------------------
-- JOIN 4: Multi-table â€” User + Account + Active Workout + Meal Plans
-- Full picture of each active user's current plans via 5-table join.
-- ----------------------------------------------------------------
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name  AS member_name,
    a.email,
    u.fitness_goal,
    wp.plan_name                         AS workout_plan,
    uwp.completion_pct                  || '%' AS wp_progress,
    mp.plan_name                         AS meal_plan,
    s.subscription_type                  AS sub_tier
FROM APP_USER           u
JOIN ACCOUNT            a   ON a.account_id      = u.account_id
LEFT JOIN USER_WORKOUT_PLAN uwp ON uwp.user_id   = u.user_id AND uwp.status = 'IN_PROGRESS'
LEFT JOIN WORKOUT_PLAN      wp  ON wp.workout_plan_id = uwp.workout_plan_id
LEFT JOIN USER_MEAL_PLAN    ump ON ump.user_id   = u.user_id AND ump.status = 'ACTIVE'
LEFT JOIN MEAL_PLAN         mp  ON mp.meal_plan_id    = ump.meal_plan_id
LEFT JOIN USER_SUBSCRIPTION us  ON us.user_id    = u.user_id AND us.status  = 'ACTIVE'
LEFT JOIN SUBSCRIPTION      s   ON s.subscription_id = us.subscription_id
ORDER BY u.user_id;


-- ----------------------------------------------------------------
-- JOIN 5: Trainer â†’ Meal Plans â†’ Users following those plans
-- Trainer-wise: who is following which meal plan.
-- ----------------------------------------------------------------
SELECT
    t.first_name || ' ' || t.last_name  AS trainer_name,
    mp.plan_name                         AS meal_plan,
    mp.goal                              AS plan_goal,
    mp.calories_per_day,
    u.first_name || ' ' || u.last_name  AS user_name,
    ump.status                           AS plan_status
FROM TRAINER        t
JOIN MEAL_PLAN      mp  ON mp.trainer_id   = t.trainer_id
JOIN USER_MEAL_PLAN ump ON ump.meal_plan_id = mp.meal_plan_id
JOIN APP_USER       u   ON ump.user_id      = u.user_id
ORDER BY t.trainer_id, mp.meal_plan_id;


-- ----------------------------------------------------------------
-- JOIN 6: Progress trend â€” multi-row join showing weight changes
-- Join APP_USER with PROGRESS_LOG and compute delta from first log.
-- ----------------------------------------------------------------
SELECT
    u.first_name || ' ' || u.last_name  AS member,
    pl.log_date,
    pl.weight_kg,
    pl.body_fat_pct,
    pl.bmi,
    pl.weight_kg - FIRST_VALUE(pl.weight_kg)
        OVER (PARTITION BY u.user_id ORDER BY pl.log_date)  AS weight_change_kg
FROM APP_USER       u
JOIN PROGRESS_LOG   pl ON pl.user_id = u.user_id
ORDER BY u.user_id, pl.log_date;


-- ============================================================
-- PART B: SUBQUERY DEMOS (5+ subqueries)
-- ============================================================

-- ----------------------------------------------------------------
-- SUBQUERY 1: Users with ACTIVE subscriptions (IN clause)
-- Demonstrates: filtering parent rows based on existence in child.
-- ----------------------------------------------------------------
SELECT
    user_id,
    first_name || ' ' || last_name  AS full_name,
    fitness_goal
FROM APP_USER
WHERE user_id IN (
    SELECT user_id
    FROM   USER_SUBSCRIPTION
    WHERE  status = 'ACTIVE'
)
ORDER BY user_id;


-- ----------------------------------------------------------------
-- SUBQUERY 2: Users whose subscription cost is ABOVE average
-- Demonstrates: scalar subquery in WHERE clause.
-- ----------------------------------------------------------------
SELECT
    u.first_name || ' ' || u.last_name  AS member_name,
    us.amount_paid,
    s.plan_name
FROM USER_SUBSCRIPTION  us
JOIN APP_USER           u  ON u.user_id         = us.user_id
JOIN SUBSCRIPTION       s  ON s.subscription_id = us.subscription_id
WHERE us.amount_paid > (
    SELECT AVG(amount_paid)
    FROM   USER_SUBSCRIPTION
    WHERE  status = 'ACTIVE'
)
ORDER BY us.amount_paid DESC;


-- ----------------------------------------------------------------
-- SUBQUERY 3: Trainers who have authored BOTH a workout AND meal plan
-- Demonstrates: correlated EXISTS subquery pair.
-- ----------------------------------------------------------------
SELECT
    t.trainer_id,
    t.first_name || ' ' || t.last_name  AS trainer_name,
    t.specialization
FROM TRAINER t
WHERE EXISTS (
    SELECT 1 FROM WORKOUT_PLAN wp WHERE wp.trainer_id = t.trainer_id
)
AND EXISTS (
    SELECT 1 FROM MEAL_PLAN mp WHERE mp.trainer_id = t.trainer_id
);


-- ----------------------------------------------------------------
-- SUBQUERY 4: Workout plans with MORE exercises than the average
-- Demonstrates: aggregate subquery compared to grouped result.
-- ----------------------------------------------------------------
SELECT
    wp.workout_plan_id,
    wp.plan_name,
    COUNT(wpe.exercise_id) AS exercise_count
FROM WORKOUT_PLAN           wp
JOIN WORKOUT_PLAN_EXERCISE  wpe ON wpe.workout_plan_id = wp.workout_plan_id
GROUP BY wp.workout_plan_id, wp.plan_name
HAVING COUNT(wpe.exercise_id) > (
    SELECT AVG(ex_count)
    FROM (
        SELECT COUNT(exercise_id) AS ex_count
        FROM   WORKOUT_PLAN_EXERCISE
        GROUP  BY workout_plan_id
    )
)
ORDER BY exercise_count DESC;


-- ----------------------------------------------------------------
-- SUBQUERY 5: Users who have NEVER logged any progress
-- Demonstrates: NOT EXISTS correlated subquery.
-- ----------------------------------------------------------------
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name  AS member_name,
    u.fitness_goal
FROM APP_USER u
WHERE NOT EXISTS (
    SELECT 1
    FROM   PROGRESS_LOG pl
    WHERE  pl.user_id = u.user_id
);


-- ----------------------------------------------------------------
-- SUBQUERY 6: Most expensive subscription tier enrolled by any user
-- Demonstrates: scalar MAX subquery in SELECT list.
-- ----------------------------------------------------------------
SELECT
    u.first_name || ' ' || u.last_name  AS member_name,
    s.plan_name,
    us.amount_paid,
    (SELECT MAX(amount_paid) FROM USER_SUBSCRIPTION)  AS max_paid_on_platform
FROM USER_SUBSCRIPTION  us
JOIN APP_USER           u  ON u.user_id         = us.user_id
JOIN SUBSCRIPTION       s  ON s.subscription_id = us.subscription_id
WHERE us.amount_paid = (
    SELECT MAX(amount_paid) FROM USER_SUBSCRIPTION
);


-- ============================================================
-- PART C: VIEW READS â€” prove views work
-- ============================================================

-- Read View 1: All active subscriptions with days remaining
SELECT * FROM VW_ACTIVE_SUBSCRIPTIONS ORDER BY days_remaining;

-- Read View 2: Full wellness overview per user
SELECT
    full_name,
    fitness_goal,
    latest_weight_kg,
    latest_body_fat_pct,
    latest_bmi,
    last_checkin_date,
    active_workout_plan,
    workout_completion_pct,
    active_meal_plan,
    subscription_tier
FROM VW_USER_WELLNESS_OVERVIEW
ORDER BY user_id;

-- Read View 3: Trainer plan authorship summary
SELECT * FROM VW_TRAINER_PLAN_SUMMARY ORDER BY total_plans DESC;

-- Read View 4: Workout plan detail for 'Power Builder 8-Week'
SELECT *
FROM VW_WORKOUT_PLAN_DETAILS
WHERE workout_plan_name = 'Power Builder 8-Week'
ORDER BY day_number;


-- ============================================================
-- PART D: RELATIONSHIP PROOF QUERIES
-- ============================================================

-- D1: One-to-Many â€” One user, multiple subscription records
SELECT u.first_name, us.status, us.start_date, us.end_date, s.plan_name
FROM APP_USER u
JOIN USER_SUBSCRIPTION us ON us.user_id = u.user_id
JOIN SUBSCRIPTION s ON s.subscription_id = us.subscription_id
WHERE u.user_id = 2002   -- Ali Raza has 2 subscriptions
ORDER BY us.start_date;

-- D2: Many-to-Many â€” Which users are following which workout plans
SELECT
    u.first_name || ' ' || u.last_name  AS member,
    wp.plan_name                         AS workout_plan,
    t.first_name || ' ' || t.last_name  AS assigned_by,
    uwp.status,
    uwp.completion_pct
FROM USER_WORKOUT_PLAN  uwp
JOIN APP_USER           u   ON u.user_id         = uwp.user_id
JOIN WORKOUT_PLAN       wp  ON wp.workout_plan_id = uwp.workout_plan_id
LEFT JOIN TRAINER       t   ON t.trainer_id       = uwp.trainer_id
ORDER BY wp.plan_name, u.last_name;

-- D3: Active subscriptions â€” who is currently subscribed
SELECT full_name, subscription_name, subscription_type, days_remaining
FROM   VW_ACTIVE_SUBSCRIPTIONS
ORDER  BY days_remaining DESC;

-- D4: Trainer-wise plan allocation (workout + meal)
SELECT trainer_name, specialization, total_workout_plans, total_meal_plans, total_plans
FROM   VW_TRAINER_PLAN_SUMMARY;

-- D5: Workout plan details â€” exercises, sets, reps per plan
SELECT workout_plan_name, goal, day_number, exercise_name, muscle_group, sets, reps
FROM   VW_WORKOUT_PLAN_DETAILS
ORDER  BY workout_plan_name, day_number;

-- D6: User progress / wellness overview (full wellness check)
SELECT full_name, latest_weight_kg, latest_body_fat_pct, latest_bmi,
       active_workout_plan, workout_completion_pct, active_meal_plan, subscription_tier
FROM   VW_USER_WELLNESS_OVERVIEW
WHERE  subscription_tier IS NOT NULL
ORDER  BY full_name;

-- End of File 5
