// ignore_for_file: avoid_catches_without_on_clauses, document_ignores

import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../models/grocery_list.dart';
import '../models/meal_plan.dart';
import '../models/progress.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  final ApiService _apiService;
  final StorageService _storageService;

  List<Recipe> _recipes = [];
  List<MealPlan> _mealPlans = [];
  List<GroceryList> _groceryLists = [];
  List<Goal> _goals = [];
  List<Progress> _progressEntries = [];
  bool _isLoading = false;
  String? _error;

  // Search states
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Filter states
  bool _showOnlyFavorites = false;
  MealType _selectedMealTypeFilter = MealType.any;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<MealPlan> get mealPlans => _mealPlans;
  List<GroceryList> get groceryLists => _groceryLists;
  List<Goal> get goals => _goals;
  List<Progress> get progressEntries => _progressEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showOnlyFavorites => _showOnlyFavorites;
  MealType get selectedMealTypeFilter => _selectedMealTypeFilter;

  // Get all favorite recipes
  List<Recipe> get favoriteRecipes =>
      _recipes.where((recipe) => recipe.isFavorite).toList();

  // Get favorite recipes filtered by meal type
  List<Recipe> getFavoritesByMealType(MealType mealType) {
    if (mealType == MealType.any) {
      return favoriteRecipes;
    }
    return favoriteRecipes
        .where((recipe) => recipe.mealType == mealType)
        .toList();
  }

  // Get filtered recipes based on search query, category, favorites and meal type
  List<Recipe> get filteredRecipes {
    return _recipes.where((recipe) {
      // Filter by favorites if enabled
      if (_showOnlyFavorites && !recipe.isFavorite) {
        return false;
      }

      // Filter by meal type if not set to 'any'
      if (_selectedMealTypeFilter != MealType.any &&
          recipe.mealType != _selectedMealTypeFilter) {
        return false;
      }

      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by category
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.categories.contains(_selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Search methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filter methods
  void toggleFavoritesOnly() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  void setShowOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  void setMealTypeFilter(MealType mealType) {
    _selectedMealTypeFilter = mealType;
    notifyListeners();
  }

  // Toggle favorite status of a recipe
  Future<void> toggleFavorite(String recipeId) async {
    final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index >= 0) {
      final recipe = _recipes[index];
      final updatedRecipe = recipe.copyWith(isFavorite: !recipe.isFavorite);

      // Determine meal type if it's being favorited and not already set
      MealType mealType = recipe.mealType;
      if (!recipe.isFavorite && mealType == MealType.any) {
        mealType = recipe.determineMealType();
      }

      // Update the recipe with the meal type if necessary
      final finalRecipe = mealType != recipe.mealType
          ? updatedRecipe.copyWith(mealType: mealType)
          : updatedRecipe;

      _recipes[index] = finalRecipe;

      // Save the updated favorite status to persistence
      await _saveFavoriteStatus(finalRecipe);

      notifyListeners();
    }
  }

  // Update a recipe's meal type
  void updateRecipeMealType(String recipeId, MealType mealType) {
    final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index >= 0) {
      final recipe = _recipes[index];
      _recipes[index] = recipe.copyWith(mealType: mealType);

      // Save the updated meal type to persistence
      _saveRecipeMealType(recipeId, mealType);

      notifyListeners();
    }
  }

  // Save favorite status to persistence
  Future<void> _saveFavoriteStatus(Recipe recipe) async {
    try {
      if (kDebugMode) {
        print(
            '[_saveFavoriteStatus] Saving favorite status for ${recipe.name}: ${recipe.isFavorite}');
      }

      // Get current list of favorite recipe IDs
      final favoriteIds = await _storageService.loadFavoriteRecipes();

      // Add or remove the recipe ID based on favorite status
      if (recipe.isFavorite) {
        if (!favoriteIds.contains(recipe.id)) {
          favoriteIds.add(recipe.id);
        }
      } else {
        favoriteIds.remove(recipe.id);
      }

      // Save the updated list back to storage
      await _storageService.saveFavoriteRecipes(favoriteIds);

      // If the recipe is being favorited, also save its meal type
      if (recipe.isFavorite) {
        await _saveRecipeMealType(recipe.id, recipe.mealType);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[_saveFavoriteStatus] Error saving favorite status: $e');
      }
    }
  }

  // Save recipe meal type to persistence
  Future<void> _saveRecipeMealType(String recipeId, MealType mealType) async {
    try {
      if (kDebugMode) {
        print(
            '[_saveRecipeMealType] Saving meal type for recipe $recipeId: ${mealType.name}');
      }

      // Save the meal type to storage
      await _storageService.saveRecipeMealType(recipeId, mealType);
    } catch (e) {
      if (kDebugMode) {
        print('[_saveRecipeMealType] Error saving meal type: $e');
      }
    }
  }

  // Recipe methods
  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _recipes = await _apiService.getRecipes();

      // Load saved favorite statuses and meal types from storage
      await _loadLocalFavoriteData();

      _error = null;
    } catch (e) {
      _error = 'Failed to load recipes: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Load favorite statuses and meal types from local storage
  Future<void> _loadLocalFavoriteData() async {
    try {
      // Load favorite recipe IDs
      final favoriteIds = await _storageService.loadFavoriteRecipes();

      // Load meal types
      final mealTypes = await _storageService.loadRecipeMealTypes();

      // Update recipes with stored favorite status and meal type
      _recipes = _recipes.map((recipe) {
        // Check if this recipe is favorited
        final isFavorite = favoriteIds.contains(recipe.id);

        // Get the saved meal type if any
        final savedMealType = mealTypes[recipe.id];

        // Create a new recipe with the stored values
        return recipe.copyWith(
          isFavorite: isFavorite,
          mealType: savedMealType ?? recipe.mealType,
        );
      }).toList();

      if (kDebugMode) {
        print(
            '[_loadLocalFavoriteData] Loaded ${favoriteIds.length} favorites and ${mealTypes.length} meal types');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[_loadLocalFavoriteData] Error loading favorite data: $e');
      }
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _setLoading(true);
    try {
      final newRecipe = await _apiService.createRecipe(recipe);
      _recipes = [..._recipes, newRecipe];
      _error = null;
    } catch (e) {
      _error = 'Failed to add recipe: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Meal Plan methods
  Future<void> loadMealPlans() async {
    _setLoading(true);
    try {
      _mealPlans = await _apiService.getMealPlans();
      _error = null;
    } catch (e) {
      _error = 'Failed to load meal plans: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMealPlan(MealPlan mealPlan) async {
    _setLoading(true);
    try {
      final newMealPlan = await _apiService.createMealPlan(mealPlan);
      _mealPlans = [..._mealPlans, newMealPlan];
      _error = null;
    } catch (e) {
      _error = 'Failed to add meal plan: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Grocery List methods
  Future<void> loadGroceryLists() async {
    _setLoading(true);
    try {
      _groceryLists = await _apiService.getGroceryLists();
      _error = null;
    } catch (e) {
      _error = 'Failed to load grocery lists: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addGroceryList(GroceryList groceryList) async {
    _setLoading(true);
    try {
      final newGroceryList = await _apiService.createGroceryList(groceryList);
      _groceryLists = [..._groceryLists, newGroceryList];
      _error = null;
    } catch (e) {
      _error = 'Failed to add grocery list: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGroceryList(GroceryList groceryList) async {
    _setLoading(true);
    try {
      final updatedGroceryList =
          await _apiService.updateGroceryList(groceryList);
      _groceryLists = [
        for (final list in _groceryLists)
          if (list.id == updatedGroceryList.id) updatedGroceryList else list,
      ];
      _error = null;
    } catch (e) {
      _error = 'Failed to update grocery list: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Goal methods
  Future<void> loadGoals() async {
    _setLoading(true);
    try {
      _goals = await _apiService.getGoals();
      _error = null;
    } catch (e) {
      _error = 'Failed to load goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addGoal(Goal goal) async {
    _setLoading(true);
    try {
      final newGoal = await _apiService.createGoal(goal);
      _goals = [..._goals, newGoal];
      _error = null;
    } catch (e) {
      _error = 'Failed to add goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    _setLoading(true);
    try {
      final updatedGoal = await _apiService.updateGoal(goal);
      _goals = [
        for (final g in _goals)
          if (g.id == updatedGoal.id) updatedGoal else g,
      ];
      _error = null;
    } catch (e) {
      _error = 'Failed to update goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Progress methods
  Future<void> loadProgressEntries() async {
    _setLoading(true);
    try {
      _progressEntries = await _apiService.getProgressEntries();
      _error = null;
    } catch (e) {
      _error = 'Failed to load progress entries: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProgressEntry(Progress progress) async {
    _setLoading(true);
    try {
      final newProgress = await _apiService.createProgressEntry(progress);
      _progressEntries = [..._progressEntries, newProgress];
      _error = null;
    } catch (e) {
      _error = 'Failed to add progress entry: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
