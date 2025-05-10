const express = require('express');
const router = express.Router();
const ProgressController = require('../controllers/progressController');

// Create progress tracking for a user's goal
router.post('/users/:uid/goals/:gid/progress', ProgressController.createProgress);

// Update progress tracking
router.put('/users/:uid/goals/:gid/progress', ProgressController.updateProgress);

// Delete progress tracking
router.delete('/users/:uid/goals/:gid/progress', ProgressController.deleteProgress);

// Get specific progress tracking
router.get('/users/:uid/goals/:gid/progress', ProgressController.getProgress);

// Get all progress tracking for a user
router.get('/users/:uid/progress', ProgressController.getUserProgress);

// Get all progress tracking for a goal
router.get('/goals/:gid/progress', ProgressController.getGoalProgress);

// Get latest progress for a user
router.get('/users/:uid/progress/latest', ProgressController.getLatestProgress);

// Get progress history for a user's goal
router.get('/users/:uid/goals/:gid/progress/history', ProgressController.getProgressHistory);

module.exports = router; 