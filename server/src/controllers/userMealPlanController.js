const userMealPlanService = require('../services/userMealPlanService');

const generateUserMealPlan = async(req, res) => {
    try {
        const { uid, gid } = req.body;

        if (!uid || !gid) {
            return res.status(400).json({ error: 'uid and gid are required' });
        }

        const result = await userMealPlanService.generateMealPlanForUser(uid, gid);
        res.status(200).json(result);
    } catch (err) {
        console.error('[generateUserMealPlan] Error generating meal plan:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

const getUserMealPlan = async(req, res) => {
    try {
        const { uid } = req.params;

        if (!uid) {
            return res.status(400).json({ error: 'User ID is required' });
        }

        const mealPlan = await userMealPlanService.getMealPlanForUser(uid);

        if (!mealPlan) {
            return res.status(404).json({ error: 'Meal plan not found for this user' });
        }

        res.status(200).json(mealPlan);
    } catch (err) {
        console.error('[getUserMealPlan] Error fetching meal plan:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

module.exports = {
    generateUserMealPlan,
    getUserMealPlan
};