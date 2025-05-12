const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const userRoutes = require('./routes/userRoutes');
const goalRoutes = require('./routes/goalRoutes');
const recipeRoutes = require('./routes/recipeRoutes');
const userMealPlanRoutes = require('./routes/userMealPlanRoutes');
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/users', userRoutes);
app.use('/api/goals', goalRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/userMealPlan', userMealPlanRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
}); 