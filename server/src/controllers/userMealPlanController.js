const userMealPlanService = require('../services/userMealPlanService');

const generateUserMealPlan = async (req, res) => {
    try {
        const { uid, gid } = req.body;

        if (!uid || !gid) {
            return res.status(400).json({ error: 'uid and gid are required' });
        }

        const result = await userMealPlanService.generateMealPlanForUser(uid, gid);
        res.status(200).json(result);
    } catch (err) {
        console.error('Error generating meal plan:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

module.exports = {
    generateUserMealPlan
};
