const CreatesSavesService = require('../services/createsSaves.service');

class CreatesSavesController {
    static async createRecipeSave(req, res) {
        try {
            const { uid, rid, creationDate, saveDate, isFavorite } = req.body;

            if (!uid || !rid || !creationDate) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await CreatesSavesService.createRecipeSave(
                uid,
                rid,
                creationDate,
                saveDate,
                isFavorite
            );

            res.status(201).json({ message: 'Recipe save created successfully', id: result });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async getUserRecipes(req, res) {
        try {
            const { uid } = req.params;

            if (!uid) {
                return res.status(400).json({ error: 'User ID is required' });
            }

            const recipes = await CreatesSavesService.getUserRecipes(uid);
            res.json(recipes);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async getUserFavorites(req, res) {
        try {
            const { uid } = req.params;

            if (!uid) {
                return res.status(400).json({ error: 'User ID is required' });
            }

            const favorites = await CreatesSavesService.getUserFavorites(uid);
            res.json(favorites);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async updateRecipeSaveDate(req, res) {
        try {
            const { uid, rid } = req.params;
            const { saveDate } = req.body;

            if (!uid || !rid || !saveDate) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await CreatesSavesService.updateRecipeSaveDate(uid, rid, saveDate);
            
            if (result) {
                res.json({ message: 'Save date updated successfully' });
            } else {
                res.status(404).json({ error: 'Recipe save not found' });
            }
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async toggleRecipeFavorite(req, res) {
        try {
            const { uid, rid } = req.params;

            if (!uid || !rid) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await CreatesSavesService.toggleRecipeFavorite(uid, rid);
            
            if (result) {
                res.json({ message: 'Favorite status toggled successfully' });
            } else {
                res.status(404).json({ error: 'Recipe save not found' });
            }
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async deleteRecipeSave(req, res) {
        try {
            const { uid, rid } = req.params;

            if (!uid || !rid) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await CreatesSavesService.deleteRecipeSave(uid, rid);
            
            if (result) {
                res.json({ message: 'Recipe save deleted successfully' });
            } else {
                res.status(404).json({ error: 'Recipe save not found' });
            }
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }
}

module.exports = CreatesSavesController; 