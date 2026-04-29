-- ============================================================
-- FITNESS & WELLNESS ECOSYSTEM
-- File 5: Demo Queries — Joins, Subqueries, View Reads
-- Execute AFTER 04_procedures_and_functions.sql
-- ============================================================

-- ============================================================
-- PART A: JOIN QUERIES (5+ joins demonstrated)
-- ============================================================

-- ----------------------------------------------------------------
-- JOIN 1: One-to-Many — User → User_Subscription → Subscription
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
-- JOIN 2: One-to-Many — Trainer → Workout_Plan
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
-- JOIN 3: Many-to-Many — Workout_Plan ↔ Exercise (via bridge)
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
-- JOIN 4: Multi-table — User + Account + Active Workout + Meal Plans
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
-- JOIN 5: Trainer → Meal Plans → Users following those plans
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
-- JOIN 6: Progress trend — multi-row join showing weight changes
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
-- PART C: VIEW READS — prove views work
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

-- D1: One-to-Many — One user, multiple subscription records
SELECT u.first_name, us.status, us.start_date, us.end_date, s.plan_name
FROM APP_USER u
JOIN USER_SUBSCRIPTION us ON us.user_id = u.user_id
JOIN SUBSCRIPTION s ON s.subscription_id = us.subscription_id
WHERE u.user_id = 2002   -- Ali Raza has 2 subscriptions
ORDER BY us.start_date;

-- D2: Many-to-Many — Which users are following which workout plans
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

-- D3: Active subscriptions — who is currently subscribed
SELECT full_name, subscription_name, subscription_type, days_remaining
FROM   VW_ACTIVE_SUBSCRIPTIONS
ORDER  BY days_remaining DESC;

-- D4: Trainer-wise plan allocation (workout + meal)
SELECT trainer_name, specialization, total_workout_plans, total_meal_plans, total_plans
FROM   VW_TRAINER_PLAN_SUMMARY;

-- D5: Workout plan details — exercises, sets, reps per plan
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
