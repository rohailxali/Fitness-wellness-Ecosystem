const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/dashboard — summary counts + recent subscriptions
router.get('/', async (req, res) => {
  try {
    const users   = await db.execute('SELECT COUNT(*) AS CNT FROM APP_USER');
    const trainers= await db.execute('SELECT COUNT(*) AS CNT FROM TRAINER');
    const exercises=await db.execute('SELECT COUNT(*) AS CNT FROM EXERCISE');
    const plans   = await db.execute('SELECT COUNT(*) AS CNT FROM WORKOUT_PLAN');
    const activeSubs = await db.execute(
      `SELECT COUNT(*) AS CNT FROM USER_SUBSCRIPTION WHERE status='ACTIVE'`
    );
    const recentSubs = await db.execute(
      `SELECT * FROM (
         SELECT us.user_sub_id, u.first_name||' '||u.last_name AS full_name,
                s.plan_name, us.start_date, us.end_date, us.status, us.amount_paid
         FROM USER_SUBSCRIPTION us
         JOIN APP_USER u ON u.user_id=us.user_id
         JOIN SUBSCRIPTION s ON s.subscription_id=us.subscription_id
         ORDER BY us.start_date DESC
       ) WHERE ROWNUM <= 5`
    );
    res.json({
      counts: {
        users:    users.rows[0].CNT,
        trainers: trainers.rows[0].CNT,
        exercises:exercises.rows[0].CNT,
        plans:    plans.rows[0].CNT,
        activeSubs: activeSubs.rows[0].CNT,
      },
      recentSubscriptions: recentSubs.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
