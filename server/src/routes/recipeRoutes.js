// src/routes/recipeRoutes.js
const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipeController");

// Basic CRUD Routes
router.get("/", recipeController.getAllRecipes);
router.get("/:id", recipeController.getRecipeById);
router.post("/", recipeController.createRecipe);
router.delete("/:id", recipeController.deleteRecipe);

// Search and Filter Routes
router.get("/search/title", recipeController.searchRecipesByTitle);
router.get("/search/ingredient", recipeController.searchRecipesByIngredient);
router.get("/category/:category", recipeController.getRecipesByCategory);

// Nutritional Query Routes
router.get("/nutrition/low-calorie", recipeController.getLowCalorieRecipes);
router.get("/nutrition/high-protein", recipeController.getHighProteinRecipes);
router.get("/nutrition/low-carb", recipeController.getLowCarbRecipes);

// Time-based Query Routes
router.get("/time/quick", recipeController.getQuickRecipes);
router.get("/time/total", recipeController.getRecipesByTotalTime);

// Complex Nutritional Query Routes
router.get("/nutrition/balanced", recipeController.getBalancedMeals);
router.get("/nutrition/high-fiber", recipeController.getHighFiberRecipes);

// Pagination and Sorting Route
router.get("/paginated", recipeController.getPaginatedRecipes);

// Advanced Filtering Routes
router.post("/filter/categories", recipeController.getRecipesByMultipleCategories);
router.get("/filter/nutritional-range", recipeController.getRecipesByNutritionalRange);

// Statistical Query Routes
router.get("/stats/averages", recipeController.getAverageNutritionalValues);
router.get("/stats/category-counts", recipeController.getRecipeCountByCategory);

module.exports = router;
