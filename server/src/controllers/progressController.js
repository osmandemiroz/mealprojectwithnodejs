const ProgressService = require('../services/progressService');

class ProgressController {
    static async createProgress(req, res) {
        try {
            const { uid, gid } = req.params;
            const progressData = {
                ...req.body,
                uid,
                gid,
                lastUpdatedDate: new Date().toISOString()
            };

            const progressId = await ProgressService.createProgress(progressData);
            res.status(201).json({
                message: 'Progress tracking created successfully',
                progressId
            });
        } catch (error) {
            if (error.message.includes('Validation failed')) {
                return res.status(400).json({ message: error.message });
            }
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            if (error.message.includes('already exists')) {
                return res.status(409).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error creating progress tracking', error: error.message });
        }
    }

    static async updateProgress(req, res) {
        try {
            const { uid, gid } = req.params;
            const progressData = {
                ...req.body,
                lastUpdatedDate: new Date().toISOString()
            };

            await ProgressService.updateProgress(uid, gid, progressData);
            res.json({ message: 'Progress updated successfully' });
        } catch (error) {
            if (error.message.includes('Validation failed')) {
                return res.status(400).json({ message: error.message });
            }
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error updating progress', error: error.message });
        }
    }

    static async deleteProgress(req, res) {
        try {
            const { uid, gid } = req.params;
            await ProgressService.deleteProgress(uid, gid);
            res.json({ message: 'Progress tracking deleted successfully' });
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error deleting progress tracking', error: error.message });
        }
    }

    static async getProgress(req, res) {
        try {
            const { uid, gid } = req.params;
            const progress = await ProgressService.getProgress(uid, gid);
            res.json(progress);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching progress', error: error.message });
        }
    }

    static async getUserProgress(req, res) {
        try {
            const { uid } = req.params;
            const progress = await ProgressService.getUserProgress(uid);
            res.json(progress);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching user progress', error: error.message });
        }
    }

    static async getGoalProgress(req, res) {
        try {
            const { gid } = req.params;
            const progress = await ProgressService.getGoalProgress(gid);
            res.json(progress);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching goal progress', error: error.message });
        }
    }

    static async getLatestProgress(req, res) {
        try {
            const { uid } = req.params;
            const progress = await ProgressService.getLatestProgress(uid);
            res.json(progress);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching latest progress', error: error.message });
        }
    }

    static async getProgressHistory(req, res) {
        try {
            const { uid, gid } = req.params;
            const history = await ProgressService.getProgressHistory(uid, gid);
            res.json(history);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching progress history', error: error.message });
        }
    }
}

module.exports = ProgressController; 