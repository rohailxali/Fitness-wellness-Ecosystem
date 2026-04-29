const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT exercise_id, exercise_name, category, muscle_group,
              difficulty, description, duration_minutes, calories_per_set, equipment_needed
       FROM EXERCISE ORDER BY category, exercise_name`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT * FROM EXERCISE WHERE exercise_id=:id`, [req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
