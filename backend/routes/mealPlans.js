const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT mp.meal_plan_id, mp.plan_name, mp.goal, mp.calories_per_day,
              mp.protein_g, mp.carbs_g, mp.fats_g, mp.description, mp.created_date,
              t.first_name||' '||t.last_name AS trainer_name
       FROM MEAL_PLAN mp LEFT JOIN TRAINER t ON t.trainer_id=mp.trainer_id
       ORDER BY mp.meal_plan_id`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT mp.*, t.first_name||' '||t.last_name AS trainer_name
       FROM MEAL_PLAN mp LEFT JOIN TRAINER t ON t.trainer_id=mp.trainer_id
       WHERE mp.meal_plan_id=:id`, [req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
