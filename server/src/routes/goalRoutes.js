const express = require('express');
const router = express.Router();
const GoalController = require('../controllers/goalController');

// Create a new goal for a user
router.post('/users/:uid/goals', GoalController.createGoal);

// Get all goals for a user
router.get('/users/:uid/goals', GoalController.getUserGoals);

// Get active goals for a user
router.get('/users/:uid/goals/active', GoalController.getActiveGoals);

// Get completed goals for a user
router.get('/users/:uid/goals/completed', GoalController.getCompletedGoals);

// Get a specific goal
router.get('/goals/:gid', GoalController.getGoal);

// Update a goal
router.put('/goals/:gid', GoalController.updateGoal);

// Delete a goal
router.delete('/goals/:gid', GoalController.deleteGoal);

module.exports = router; 