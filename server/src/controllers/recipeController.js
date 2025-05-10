// src/controllers/recipeController.js
const recipeService = require("../services/recipe.service");

// Basic CRUD Operations
exports.getAllRecipes = async (req, res) => {
  try {
    const recipes = await recipeService.getAllRecipes();
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecipeById = async (req, res) => {
  try {
    const recipe = await recipeService.getRecipeById(req.params.id);
    if (!recipe) return res.status(404).json({ message: "Recipe not found" });
    res.json(recipe);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createRecipe = async (req, res) => {
  try {
    const newRecipe = await recipeService.createRecipe(req.body);
    res.status(201).json(newRecipe);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.deleteRecipe = async (req, res) => {
  try {
    const result = await recipeService.deleteRecipe(req.params.id);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Search and Filter Operations
exports.searchRecipesByTitle = async (req, res) => {
  try {
    const { title } = req.query;
    if (!title) {
      return res.status(400).json({ error: 'Title parameter is required' });
    }
    const recipes = await recipeService.searchRecipesByTitle(title);
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecipesByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const recipes = await recipeService.getRecipesByCategory(category);
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Nutritional Queries
exports.getLowCalorieRecipes = async (req, res) => {
  try {
    const { maxCalories } = req.query;
    const recipes = await recipeService.getLowCalorieRecipes(parseInt(maxCalories));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getHighProteinRecipes = async (req, res) => {
  try {
    const { minProtein } = req.query;
    const recipes = await recipeService.getHighProteinRecipes(parseInt(minProtein));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getLowCarbRecipes = async (req, res) => {
  try {
    const { maxCarbs } = req.query;
    const recipes = await recipeService.getLowCarbRecipes(parseInt(maxCarbs));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Time-based Queries
exports.getQuickRecipes = async (req, res) => {
  try {
    const { maxPrepTime } = req.query;
    const recipes = await recipeService.getQuickRecipes(parseInt(maxPrepTime));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecipesByTotalTime = async (req, res) => {
  try {
    const { maxTotalTime } = req.query;
    const recipes = await recipeService.getRecipesByTotalTime(parseInt(maxTotalTime));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Complex Nutritional Queries
exports.getBalancedMeals = async (req, res) => {
  try {
    const { minProtein, maxCarbs, maxFat } = req.query;
    const recipes = await recipeService.getBalancedMeals(
      parseInt(minProtein),
      parseInt(maxCarbs),
      parseInt(maxFat)
    );
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getHighFiberRecipes = async (req, res) => {
  try {
    const { minFiber } = req.query;
    const recipes = await recipeService.getHighFiberRecipes(parseInt(minFiber));
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Pagination and Sorting
exports.getPaginatedRecipes = async (req, res) => {
  try {
    const { page, limit, sortBy, order } = req.query;
    const recipes = await recipeService.getPaginatedRecipes(
      parseInt(page),
      parseInt(limit),
      sortBy,
      order
    );
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Advanced Filtering
exports.getRecipesByMultipleCategories = async (req, res) => {
  try {
    const { categories } = req.body;
    if (!Array.isArray(categories)) {
      return res.status(400).json({ error: 'Categories must be an array' });
    }
    const recipes = await recipeService.getRecipesByMultipleCategories(categories);
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecipesByNutritionalRange = async (req, res) => {
  try {
    const { minCalories, maxCalories, minProtein, maxProtein } = req.query;
    const recipes = await recipeService.getRecipesByNutritionalRange(
      parseInt(minCalories),
      parseInt(maxCalories),
      parseInt(minProtein),
      parseInt(maxProtein)
    );
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Statistical Queries
exports.getAverageNutritionalValues = async (req, res) => {
  try {
    const averages = await recipeService.getAverageNutritionalValues();
    res.json(averages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecipeCountByCategory = async (req, res) => {
  try {
    const categoryCounts = await recipeService.getRecipeCountByCategory();
    res.json(categoryCounts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Search by Ingredients
exports.searchRecipesByIngredient = async (req, res) => {
  try {
    const { ingredient } = req.query;
    if (!ingredient) {
      return res.status(400).json({ error: 'Ingredient parameter is required' });
    }
    const recipes = await recipeService.searchRecipesByIngredient(ingredient);
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
