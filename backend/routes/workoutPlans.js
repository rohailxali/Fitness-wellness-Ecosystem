const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT wp.workout_plan_id, wp.plan_name, wp.goal, wp.difficulty,
              wp.duration_weeks, wp.description, wp.created_date,
              t.first_name||' '||t.last_name AS trainer_name
       FROM WORKOUT_PLAN wp
       LEFT JOIN TRAINER t ON t.trainer_id=wp.trainer_id
       ORDER BY wp.workout_plan_id`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const plan = await db.execute(
      `SELECT wp.*, t.first_name||' '||t.last_name AS trainer_name
       FROM WORKOUT_PLAN wp LEFT JOIN TRAINER t ON t.trainer_id=wp.trainer_id
       WHERE wp.workout_plan_id=:id`, [req.params.id]
    );
    if (!plan.rows.length) return res.status(404).json({ error: 'Not found' });
    const exercises = await db.execute(
      `SELECT wpe.day_number, wpe.sets, wpe.reps, wpe.rest_seconds, wpe.notes,
              e.exercise_name, e.category, e.muscle_group, e.difficulty
       FROM WORKOUT_PLAN_EXERCISE wpe
       JOIN EXERCISE e ON e.exercise_id=wpe.exercise_id
       WHERE wpe.workout_plan_id=:id
       ORDER BY wpe.day_number`, [req.params.id]
    );
    res.json({ plan: plan.rows[0], exercises: exercises.rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
