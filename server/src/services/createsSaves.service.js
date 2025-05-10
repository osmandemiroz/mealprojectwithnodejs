const CreatesSaves = require('../models/createsSaves.model');
const Recipe = require('../models/recipe.model');
const User = require('../models/user.model');

class CreatesSavesService {
    static async createRecipeSave(uid, rid, creationDate, saveDate = null, isFavorite = false) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.getById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        // Validate dates
        if (saveDate && new Date(saveDate) < new Date(creationDate)) {
            throw new Error('Save date cannot be earlier than creation date');
        }

        return await CreatesSaves.create(uid, rid, creationDate, saveDate, isFavorite);
    }

    static async getUserRecipes(uid) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await CreatesSaves.getByUserId(uid);
    }

    static async getUserFavorites(uid) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        return await CreatesSaves.getFavorites(uid);
    }

    static async updateRecipeSaveDate(uid, rid, saveDate) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.getById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        // Validate save date
        if (!saveDate || isNaN(new Date(saveDate).getTime())) {
            throw new Error('Invalid save date');
        }

        return await CreatesSaves.updateSaveDate(uid, rid, saveDate);
    }

    static async toggleRecipeFavorite(uid, rid) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.getById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        return await CreatesSaves.toggleFavorite(uid, rid);
    }

    static async deleteRecipeSave(uid, rid) {
        // Validate user exists
        const user = await User.getById(uid);
        if (!user) {
            throw new Error('User not found');
        }

        // Validate recipe exists
        const recipe = await Recipe.getById(rid);
        if (!recipe) {
            throw new Error('Recipe not found');
        }

        return await CreatesSaves.delete(uid, rid);
    }
}

module.exports = CreatesSavesService; 