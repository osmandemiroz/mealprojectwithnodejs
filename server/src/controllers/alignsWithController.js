const AlignsWithService = require('../services/alignsWithService');

class AlignsWithController {
    static async createAlignment(req, res) {
        try {
            const { gid, rid } = req.params;
            const { compatibilityScore } = req.body;

            const alignmentData = {
                gid,
                rid,
                compatibilityScore
            };

            const alignmentId = await AlignsWithService.createAlignment(alignmentData);
            res.status(201).json({
                message: 'Alignment created successfully',
                alignmentId
            });
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            if (error.message.includes('already exists')) {
                return res.status(409).json({ message: error.message });
            }
            if (error.message.includes('Invalid compatibility score')) {
                return res.status(400).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error creating alignment', error: error.message });
        }
    }

    static async updateAlignment(req, res) {
        try {
            const { gid, rid } = req.params;
            const { compatibilityScore } = req.body;

            await AlignsWithService.updateAlignment(gid, rid, compatibilityScore);
            res.json({ message: 'Alignment updated successfully' });
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            if (error.message.includes('Invalid compatibility score')) {
                return res.status(400).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error updating alignment', error: error.message });
        }
    }

    static async deleteAlignment(req, res) {
        try {
            const { gid, rid } = req.params;
            await AlignsWithService.deleteAlignment(gid, rid);
            res.json({ message: 'Alignment deleted successfully' });
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error deleting alignment', error: error.message });
        }
    }

    static async getAlignment(req, res) {
        try {
            const { gid, rid } = req.params;
            const alignment = await AlignsWithService.getAlignment(gid, rid);
            res.json(alignment);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching alignment', error: error.message });
        }
    }

    static async getGoalAlignments(req, res) {
        try {
            const { gid } = req.params;
            const alignments = await AlignsWithService.getGoalAlignments(gid);
            res.json(alignments);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching goal alignments', error: error.message });
        }
    }

    static async getRecipeAlignments(req, res) {
        try {
            const { rid } = req.params;
            const alignments = await AlignsWithService.getRecipeAlignments(rid);
            res.json(alignments);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching recipe alignments', error: error.message });
        }
    }

    static async getTopCompatibleRecipes(req, res) {
        try {
            const { gid } = req.params;
            const { limit } = req.query;
            const recipes = await AlignsWithService.getTopCompatibleRecipes(gid, limit ? parseInt(limit) : 5);
            res.json(recipes);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching compatible recipes', error: error.message });
        }
    }

    static async getCompatibleGoals(req, res) {
        try {
            const { rid } = req.params;
            const { minScore } = req.query;
            const goals = await AlignsWithService.getCompatibleGoals(rid, minScore ? parseInt(minScore) : 3);
            res.json(goals);
        } catch (error) {
            if (error.message.includes('not found')) {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching compatible goals', error: error.message });
        }
    }
}

module.exports = AlignsWithController; 