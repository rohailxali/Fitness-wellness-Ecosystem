const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT t.trainer_id, t.first_name, t.last_name, a.email, a.phone,
              t.specialization, t.certification, t.experience_years, t.hourly_rate, t.bio,
              a.account_status
       FROM TRAINER t JOIN ACCOUNT a ON a.account_id=t.account_id
       ORDER BY t.trainer_id`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT t.*, a.email, a.phone, a.account_status
       FROM TRAINER t JOIN ACCOUNT a ON a.account_id=t.account_id
       WHERE t.trainer_id=:id`, [req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:id/plans', async (req, res) => {
  try {
    const wp = await db.execute(
      `SELECT workout_plan_id AS id, plan_name, goal, difficulty, duration_weeks, 'Workout' AS type
       FROM WORKOUT_PLAN WHERE trainer_id=:id`, [req.params.id]
    );
    const mp = await db.execute(
      `SELECT meal_plan_id AS id, plan_name, goal, calories_per_day, 'Meal' AS type
       FROM MEAL_PLAN WHERE trainer_id=:id`, [req.params.id]
    );
    res.json({ workoutPlans: wp.rows, mealPlans: mp.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
