const express = require('express');
const router = express.Router();
const userMealPlanController = require('../controllers/userMealPlanController');

router.post('/generate', userMealPlanController.generateUserMealPlan);
router.get('/:uid', userMealPlanController.getUserMealPlan);
module.exports = router;
