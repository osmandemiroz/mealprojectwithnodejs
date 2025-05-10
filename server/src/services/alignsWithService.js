const AlignsWith = require('../models/alignsWithModel');
const Goal = require('../models/goalModel');
const Recipe = require('../models/recipeModel');

class AlignsWithService {
    static async createAlignment(alignmentData) {
        const { gid, rid, compatibilityScore } = alignmentData;

        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.findById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        // Validate compatibility score
        if (!this.isValidCompatibilityScore(compatibilityScore)) {
            throw new Error('Invalid compatibility score. Must be between 1 and 5');
        }

        // Check if alignment already exists
        const existingAlignment = await AlignsWith.findByGoalAndRecipe(gid, rid);
        if (existingAlignment) {
            throw new Error('Alignment already exists for this goal and recipe');
        }

        return await AlignsWith.create(alignmentData);
    }

    static async updateAlignment(gid, rid, compatibilityScore) {
        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.findById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        // Validate compatibility score
        if (!this.isValidCompatibilityScore(compatibilityScore)) {
            throw new Error('Invalid compatibility score. Must be between 1 and 5');
        }

        // Check if alignment exists
        const existingAlignment = await AlignsWith.findByGoalAndRecipe(gid, rid);
        if (!existingAlignment) {
            throw new Error('Alignment not found for this goal and recipe');
        }

        const success = await AlignsWith.update(gid, rid, compatibilityScore);
        if (!success) {
            throw new Error('Failed to update alignment');
        }

        return true;
    }

    static async deleteAlignment(gid, rid) {
        // Check if alignment exists
        const existingAlignment = await AlignsWith.findByGoalAndRecipe(gid, rid);
        if (!existingAlignment) {
            throw new Error('Alignment not found for this goal and recipe');
        }

        const success = await AlignsWith.delete(gid, rid);
        if (!success) {
            throw new Error('Failed to delete alignment');
        }

        return true;
    }

    static async getAlignment(gid, rid) {
        const alignment = await AlignsWith.findByGoalAndRecipe(gid, rid);
        if (!alignment) {
            throw new Error('Alignment not found for this goal and recipe');
        }
        return alignment;
    }

    static async getGoalAlignments(gid) {
        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        return await AlignsWith.findByGoal(gid);
    }

    static async getRecipeAlignments(rid) {
        // Validate recipe exists
        const recipe = await Recipe.findById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        return await AlignsWith.findByRecipe(rid);
    }

    static async getTopCompatibleRecipes(gid, limit = 5) {
        // Validate goal exists
        const goal = await Goal.findById(gid);
        if (!goal) {
            throw new Error('Goal not found');
        }

        return await AlignsWith.getTopCompatibleRecipes(gid, limit);
    }

    static async getCompatibleGoals(rid, minScore = 3) {
        // Validate recipe exists
        const recipe = await Recipe.findById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        return await AlignsWith.getCompatibleGoals(rid, minScore);
    }

    static isValidCompatibilityScore(score) {
        return typeof score === 'number' && score >= 1 && score <= 5;
    }
}

module.exports = AlignsWithService; 