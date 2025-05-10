const Progress = require('../models/progressModel');
const User = require('../models/userModel');
const Goal = require('../models/goalModel');

class ProgressService {
    static async createProgress(progressData) {
        // Validate user exists
        const user = await User.findById(progressData.uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate goal exists
        const goal = await Goal.findById(progressData.gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        // Validate progress data
        const validationErrors = this.validateProgressData(progressData);
        if (validationErrors.length > 0) {
            throw new Error(`Validation failed: ${validationErrors.join(', ')}`);
        }

        // Check if progress already exists
        const existingProgress = await Progress.findByUserAndGoal(progressData.uid, progressData.gid);
        if (existingProgress) {
            throw new Error('Progress tracking already exists for this user and goal');
        }

        // Create progress
        const progressId = await Progress.create(progressData);
        return progressId;
    }

    static async updateProgress(uid, gid, progressData) {
        // Validate user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        // Validate progress data
        const validationErrors = this.validateProgressData(progressData);
        if (validationErrors.length > 0) {
            throw new Error(`Validation failed: ${validationErrors.join(', ')}`);
        }

        // Check if progress exists
        const existingProgress = await Progress.findByUserAndGoal(uid, gid);
        if (!existingProgress) {
            throw new Error('Progress tracking not found');
        }

        // Update progress
        const success = await Progress.update(uid, gid, progressData);
        if (!success) {
            throw new Error('Failed to update progress');
        }

        return true;
    }

    static async deleteProgress(uid, gid) {
        // Check if progress exists
        const existingProgress = await Progress.findByUserAndGoal(uid, gid);
        if (!existingProgress) {
            throw new Error('Progress tracking not found');
        }

        // Delete progress
        const success = await Progress.delete(uid, gid);
        if (!success) {
            throw new Error('Failed to delete progress');
        }

        return true;
    }

    static async getProgress(uid, gid) {
        const progress = await Progress.findByUserAndGoal(uid, gid);
        if (!progress) {
            throw new Error('Progress tracking not found');
        }
        return progress;
    }

    static async getUserProgress(uid) {
        // Validate user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Progress.findByUserId(uid);
    }

    static async getGoalProgress(gid) {
        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        return await Progress.findByGoalId(gid);
    }

    static async getLatestProgress(uid) {
        // Validate user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Progress.getLatestProgress(uid);
    }

    static async getProgressHistory(uid, gid) {
        // Validate user exists
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        return await Progress.getProgressHistory(uid, gid);
    }

    static validateProgressData(progressData) {
        const errors = [];

        if (!progressData.currentWeight || progressData.currentWeight <= 0) {
            errors.push('Current weight must be a positive number');
        }

        if (progressData.progressPercentage === undefined || progressData.progressPercentage === null) {
            errors.push('Progress percentage is required');
        } else if (progressData.progressPercentage < 0 || progressData.progressPercentage > 100) {
            errors.push('Progress percentage must be between 0 and 100');
        }

        if (!progressData.lastUpdatedDate) {
            errors.push('Last updated date is required');
        } else if (!this.isValidDate(progressData.lastUpdatedDate)) {
            errors.push('Invalid date format');
        }

        return errors;
    }

    static isValidDate(dateString) {
        const date = new Date(dateString);
        return date instanceof Date && !isNaN(date);
    }
}

module.exports = ProgressService; 