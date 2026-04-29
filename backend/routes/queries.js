const express = require('express');
const router = express.Router();
const db = require('../config/db');

// JOIN 1: Users with their subscription history
router.get('/join/user-subscriptions', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.user_id, u.first_name||' '||u.last_name AS full_name,
              u.fitness_goal, s.plan_name, s.subscription_type,
              us.start_date, us.end_date, us.status, us.amount_paid
       FROM APP_USER u
       JOIN USER_SUBSCRIPTION us ON us.user_id=u.user_id
       JOIN SUBSCRIPTION s ON s.subscription_id=us.subscription_id
       ORDER BY u.user_id, us.start_date`
    );
    res.json({ title: 'JOIN 1: Users with Subscription History', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// JOIN 2: Trainer -> Workout Plans
router.get('/join/trainer-plans', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT t.trainer_id, t.first_name||' '||t.last_name AS trainer_name,
              t.specialization, wp.plan_name, wp.goal, wp.difficulty, wp.duration_weeks
       FROM TRAINER t JOIN WORKOUT_PLAN wp ON wp.trainer_id=t.trainer_id
       ORDER BY t.trainer_id`
    );
    res.json({ title: 'JOIN 2: Trainers with Their Workout Plans', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// JOIN 3: Many-to-Many Workout Plan <-> Exercise
router.get('/join/plan-exercises', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT wp.plan_name, wpe.day_number, e.exercise_name,
              e.category, e.muscle_group, wpe.sets, wpe.reps, wpe.rest_seconds
       FROM WORKOUT_PLAN wp
       JOIN WORKOUT_PLAN_EXERCISE wpe ON wpe.workout_plan_id=wp.workout_plan_id
       JOIN EXERCISE e ON e.exercise_id=wpe.exercise_id
       ORDER BY wp.workout_plan_id, wpe.day_number`
    );
    res.json({ title: 'JOIN 3: Many-to-Many — Plans with Exercises', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// JOIN 4: Full user profile with active plans
router.get('/join/user-active-plans', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.first_name||' '||u.last_name AS member, a.email,
              u.fitness_goal, wp.plan_name AS workout_plan,
              uwp.completion_pct||'%' AS progress,
              mp.plan_name AS meal_plan, s.subscription_type
       FROM APP_USER u
       JOIN ACCOUNT a ON a.account_id=u.account_id
       LEFT JOIN USER_WORKOUT_PLAN uwp ON uwp.user_id=u.user_id AND uwp.status='IN_PROGRESS'
       LEFT JOIN WORKOUT_PLAN wp ON wp.workout_plan_id=uwp.workout_plan_id
       LEFT JOIN USER_MEAL_PLAN ump ON ump.user_id=u.user_id AND ump.status='ACTIVE'
       LEFT JOIN MEAL_PLAN mp ON mp.meal_plan_id=ump.meal_plan_id
       LEFT JOIN USER_SUBSCRIPTION us ON us.user_id=u.user_id AND us.status='ACTIVE'
       LEFT JOIN SUBSCRIPTION s ON s.subscription_id=us.subscription_id
       ORDER BY u.user_id`
    );
    res.json({ title: 'JOIN 4: User Full Profile with Active Plans', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// JOIN 5: Trainer -> Meal Plans -> Users
router.get('/join/trainer-meal-users', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT t.first_name||' '||t.last_name AS trainer, mp.plan_name AS meal_plan,
              mp.goal, mp.calories_per_day,
              u.first_name||' '||u.last_name AS user_name, ump.status
       FROM TRAINER t
       JOIN MEAL_PLAN mp ON mp.trainer_id=t.trainer_id
       JOIN USER_MEAL_PLAN ump ON ump.meal_plan_id=mp.meal_plan_id
       JOIN APP_USER u ON u.user_id=ump.user_id
       ORDER BY t.trainer_id`
    );
    res.json({ title: 'JOIN 5: Trainers → Meal Plans → Users', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// SUBQUERY 1: Users with active subscriptions
router.get('/subquery/active-subscribers', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT user_id, first_name||' '||last_name AS full_name, fitness_goal
       FROM APP_USER
       WHERE user_id IN (SELECT user_id FROM USER_SUBSCRIPTION WHERE status='ACTIVE')
       ORDER BY user_id`
    );
    res.json({ title: 'SUBQUERY 1: Users with Active Subscriptions (IN)', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// SUBQUERY 2: Users paying above average
router.get('/subquery/above-avg-payers', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.first_name||' '||u.last_name AS member, us.amount_paid, s.plan_name
       FROM USER_SUBSCRIPTION us
       JOIN APP_USER u ON u.user_id=us.user_id
       JOIN SUBSCRIPTION s ON s.subscription_id=us.subscription_id
       WHERE us.amount_paid > (SELECT AVG(amount_paid) FROM USER_SUBSCRIPTION WHERE status='ACTIVE')
       ORDER BY us.amount_paid DESC`
    );
    res.json({ title: 'SUBQUERY 2: Users Paying Above Average (Scalar)', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// SUBQUERY 3: Trainers with both plan types (EXISTS)
router.get('/subquery/full-trainers', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT trainer_id, first_name||' '||last_name AS trainer_name, specialization
       FROM TRAINER t
       WHERE EXISTS (SELECT 1 FROM WORKOUT_PLAN wp WHERE wp.trainer_id=t.trainer_id)
       AND EXISTS (SELECT 1 FROM MEAL_PLAN mp WHERE mp.trainer_id=t.trainer_id)`
    );
    res.json({ title: 'SUBQUERY 3: Trainers with Both Plan Types (EXISTS)', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// SUBQUERY 4: Users who never logged progress (NOT EXISTS)
router.get('/subquery/no-progress', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT user_id, first_name||' '||last_name AS full_name, fitness_goal
       FROM APP_USER u
       WHERE NOT EXISTS (SELECT 1 FROM PROGRESS_LOG pl WHERE pl.user_id=u.user_id)`
    );
    res.json({ title: 'SUBQUERY 4: Users with No Progress Logs (NOT EXISTS)', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// SUBQUERY 5: Plans with above-average exercise count (HAVING + nested)
router.get('/subquery/plan-exercise-count', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT wp.plan_name, COUNT(wpe.exercise_id) AS exercise_count
       FROM WORKOUT_PLAN wp
       JOIN WORKOUT_PLAN_EXERCISE wpe ON wpe.workout_plan_id=wp.workout_plan_id
       GROUP BY wp.workout_plan_id, wp.plan_name
       HAVING COUNT(wpe.exercise_id) > (
         SELECT AVG(cnt) FROM (
           SELECT COUNT(exercise_id) AS cnt FROM WORKOUT_PLAN_EXERCISE GROUP BY workout_plan_id
         )
       )
       ORDER BY exercise_count DESC`
    );
    res.json({ title: 'SUBQUERY 5: Plans with Above-Average Exercise Count (HAVING)', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// VIEW: Wellness overview
router.get('/view/wellness-overview', async (req, res) => {
  try {
    const result = await db.execute(`SELECT * FROM VW_USER_WELLNESS_OVERVIEW ORDER BY USER_ID`);
    res.json({ title: 'VIEW: User Wellness Overview', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// VIEW: Active subscriptions
router.get('/view/active-subscriptions', async (req, res) => {
  try {
    const result = await db.execute(`SELECT * FROM VW_ACTIVE_SUBSCRIPTIONS ORDER BY DAYS_REMAINING`);
    res.json({ title: 'VIEW: Active Subscriptions', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// VIEW: Trainer plan summary
router.get('/view/trainer-summary', async (req, res) => {
  try {
    const result = await db.execute(`SELECT * FROM VW_TRAINER_PLAN_SUMMARY ORDER BY TOTAL_PLANS DESC`);
    res.json({ title: 'VIEW: Trainer Plan Summary', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// Progress trend report
router.get('/report/progress-trend', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.first_name||' '||u.last_name AS member, pl.log_date,
              pl.weight_kg, pl.body_fat_pct, pl.bmi,
              pl.weight_kg - FIRST_VALUE(pl.weight_kg)
                OVER (PARTITION BY u.user_id ORDER BY pl.log_date) AS weight_change
       FROM APP_USER u JOIN PROGRESS_LOG pl ON pl.user_id=u.user_id
       ORDER BY u.user_id, pl.log_date`
    );
    res.json({ title: 'REPORT: Member Progress Trend', rows: result.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
