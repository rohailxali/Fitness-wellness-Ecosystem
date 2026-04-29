const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all users with account info
router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.user_id, u.first_name, u.last_name, a.email, a.phone,
              u.gender, u.height_cm, u.weight_kg, u.fitness_goal,
              a.account_status, a.created_date
       FROM APP_USER u JOIN ACCOUNT a ON a.account_id=u.account_id
       ORDER BY u.user_id`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET single user
router.get('/:id', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT u.*, a.email, a.phone, a.account_status, a.created_date
       FROM APP_USER u JOIN ACCOUNT a ON a.account_id=u.account_id
       WHERE u.user_id=:id`, [req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET user's workout plans
router.get('/:id/workout-plans', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT uwp.uwp_id, wp.plan_name, wp.goal, wp.difficulty, wp.duration_weeks,
              uwp.completion_pct, uwp.status, uwp.assigned_date,
              t.first_name||' '||t.last_name AS trainer_name
       FROM USER_WORKOUT_PLAN uwp
       JOIN WORKOUT_PLAN wp ON wp.workout_plan_id=uwp.workout_plan_id
       LEFT JOIN TRAINER t ON t.trainer_id=uwp.trainer_id
       WHERE uwp.user_id=:id`, [req.params.id]
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET user's meal plans
router.get('/:id/meal-plans', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT ump.ump_id, mp.plan_name, mp.goal, mp.calories_per_day,
              mp.protein_g, mp.carbs_g, mp.fats_g, ump.status, ump.assigned_date
       FROM USER_MEAL_PLAN ump
       JOIN MEAL_PLAN mp ON mp.meal_plan_id=ump.meal_plan_id
       WHERE ump.user_id=:id`, [req.params.id]
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET user's progress logs
router.get('/:id/progress', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT log_id, log_date, weight_kg, body_fat_pct, bmi, notes
       FROM PROGRESS_LOG WHERE user_id=:id ORDER BY log_date`, [req.params.id]
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
