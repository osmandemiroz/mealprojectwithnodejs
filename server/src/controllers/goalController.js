const GoalService = require('../services/goalService');

class GoalController {
    static async createGoal(req, res) {
        try {
            const goalData = {
                ...req.body,
                uid: req.params.uid
            };

            const goalId = await GoalService.createGoal(goalData);
            res.status(201).json({
                message: 'Goal created successfully',
                goalId
            });
        } catch (error) {
            if (error.message.includes('Validation failed')) {
                return res.status(400).json({ message: error.message });
            }
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error creating goal', error: error.message });
        }
    }

    static async getGoal(req, res) {
        try {
            const { gid } = req.params;
            const goal = await GoalService.getGoalById(gid);
            res.json(goal);
        } catch (error) {
            if (error.message === 'Goal not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching goal', error: error.message });
        }
    }

    static async updateGoal(req, res) {
        try {
            const { gid } = req.params;
            await GoalService.updateGoal(gid, req.body);
            res.json({ message: 'Goal updated successfully' });
        } catch (error) {
            if (error.message === 'Goal not found') {
                return res.status(404).json({ message: error.message });
            }
            if (error.message.includes('Validation failed')) {
                return res.status(400).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error updating goal', error: error.message });
        }
    }

    static async deleteGoal(req, res) {
        try {
            const { gid } = req.params;
            await GoalService.deleteGoal(gid);
            res.json({ message: 'Goal deleted successfully' });
        } catch (error) {
            if (error.message === 'Goal not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error deleting goal', error: error.message });
        }
    }

    static async getUserGoals(req, res) {
        try {
            const { uid } = req.params;
            const goals = await GoalService.getUserGoals(uid);
            res.json(goals);
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching user goals', error: error.message });
        }
    }

    static async getActiveGoals(req, res) {
        try {
            const { uid } = req.params;
            const goals = await GoalService.getActiveGoals(uid);
            res.json(goals);
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching active goals', error: error.message });
        }
    }

    static async getCompletedGoals(req, res) {
        try {
            const { uid } = req.params;
            const goals = await GoalService.getCompletedGoals(uid);
            res.json(goals);
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching completed goals', error: error.message });
        }
    }
}

module.exports = GoalController; 