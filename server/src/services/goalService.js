const Goal = require('../models/goalModel');
const User = require('../models/userModel');

class GoalService {
    static async createGoal(goalData) {
        // Validate user exists
        const user = await User.findById(goalData.uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate goal data
        const validationErrors = this.validateGoalData(goalData);
        if (validationErrors.length > 0) {
            throw new Error(`Validation failed: ${validationErrors.join(', ')}`);
        }

        // Create goal
        const goalId = await Goal.create(goalData);
        return goalId;
    }

    static async getGoalById(gid) {
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }
        return goal;
    }

    static async updateGoal(gid, goalData) {
        // Check if goal exists
        const existingGoal = await Goal.findById(gid);
        if (!existingGoal) {
            throw new Error('Goal not found');
        }

        // Validate goal data
        const validationErrors = this.validateGoalData(goalData);
        if (validationErrors.length > 0) {
            throw new Error(`Validation failed: ${validationErrors.join(', ')}`);
        }

        // Update goal
        const success = await Goal.update(gid, goalData);
        if (!success) {
            throw new Error('Failed to update goal');
        }

        return true;
    }

    static async deleteGoal(gid) {
        // Check if goal exists
        const existingGoal = await Goal.findById(gid);
        if (!existingGoal) {
            throw new Error('Goal not found');
        }

        // Delete goal
        const success = await Goal.delete(gid);
        if (!success) {
            throw new Error('Failed to delete goal');
        }

        return true;
    }

    static async getUserGoals(uid) {
        // Check if user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Goal.findByUserId(uid);
    }

    static async getActiveGoals(uid) {
        // Check if user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Goal.getActiveGoals(uid);
    }

    static async getCompletedGoals(uid) {
        // Check if user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Goal.getCompletedGoals(uid);
    }

    static validateGoalData(goalData) {
        const errors = [];

        if (!goalData.goalType) {
            errors.push('Goal type is required');
        }

        if (!goalData.startDate) {
            errors.push('Start date is required');
        } else if (!this.isValidDate(goalData.startDate)) {
            errors.push('Invalid start date format');
        }

        if (!goalData.endDate) {
            errors.push('End date is required');
        } else if (!this.isValidDate(goalData.endDate)) {
            errors.push('Invalid end date format');
        }

        if (goalData.startDate && goalData.endDate && 
            new Date(goalData.startDate) >= new Date(goalData.endDate)) {
            errors.push('End date must be after start date');
        }

        
        return errors;
    }

    static isValidDate(dateString) {
        const date = new Date(dateString);
        return date instanceof Date && !isNaN(date);
    }
}

module.exports = GoalService; 