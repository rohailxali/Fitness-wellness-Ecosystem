const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Routes
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/users',     require('./routes/users'));
app.use('/api/trainers',  require('./routes/trainers'));
app.use('/api/exercises', require('./routes/exercises'));
app.use('/api/workout-plans',   require('./routes/workoutPlans'));
app.use('/api/meal-plans',      require('./routes/mealPlans'));
app.use('/api/subscriptions',   require('./routes/subscriptions'));
app.use('/api/queries',         require('./routes/queries'));

app.get('/', (req, res) => res.json({ message: 'Fitness & Wellness API running' }));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
