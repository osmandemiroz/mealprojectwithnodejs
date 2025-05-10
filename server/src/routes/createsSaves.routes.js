const express = require('express');
const router = express.Router();
const CreatesSavesController = require('../controllers/createsSaves.controller');

// Create a new recipe save
router.post('/', CreatesSavesController.createRecipeSave);

// Get all recipes for a user
router.get('/user/:uid', CreatesSavesController.getUserRecipes);

// Get favorite recipes for a user
router.get('/user/:uid/favorites', CreatesSavesController.getUserFavorites);

// Update recipe save date
router.patch('/:uid/:rid/save-date', CreatesSavesController.updateRecipeSaveDate);

// Toggle recipe favorite status
router.patch('/:uid/:rid/favorite', CreatesSavesController.toggleRecipeFavorite);

// Delete a recipe save
router.delete('/:uid/:rid', CreatesSavesController.deleteRecipeSave);

module.exports = router; 