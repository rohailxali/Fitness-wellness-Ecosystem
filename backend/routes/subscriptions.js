const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all tiers
router.get('/tiers', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT subscription_id, plan_name, subscription_type, price,
              duration_days, max_plans, trainer_access, features
       FROM SUBSCRIPTION ORDER BY price`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET all user subscriptions
router.get('/', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT us.user_sub_id, u.first_name||' '||u.last_name AS full_name,
              s.plan_name, s.subscription_type, us.start_date, us.end_date,
              us.status, us.amount_paid, us.payment_method,
              (us.end_date - SYSDATE) AS days_remaining
       FROM USER_SUBSCRIPTION us
       JOIN APP_USER u ON u.user_id=us.user_id
       JOIN SUBSCRIPTION s ON s.subscription_id=us.subscription_id
       ORDER BY us.start_date DESC`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET active subscriptions (from view)
router.get('/active', async (req, res) => {
  try {
    const result = await db.execute(
      `SELECT * FROM VW_ACTIVE_SUBSCRIPTIONS ORDER BY days_remaining`
    );
    res.json(result.rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
