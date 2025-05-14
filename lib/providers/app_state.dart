// ignore_for_file: avoid_catches_without_on_clauses, document_ignores

import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../models/grocery_list.dart';
import '../models/meal_plan.dart';
import '../models/progress.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Enum to define filter modes for numeric ranges
enum FilterMode {
  less,
  exactly,
  more,
}

/// Extension on FilterMode to get display text
extension FilterModeExtension on FilterMode {
  String get label {
    switch (this) {
      case FilterMode.less:
        return 'Less than';
      case FilterMode.exactly:
        return 'Exactly';
      case FilterMode.more:
        return 'More than';
    }
  }
}

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

  // Advanced filter states
  bool _advancedFiltersActive = false;

  // Calories filter
  bool _caloriesFilterActive = false;
  int _caloriesValue = 500;
  FilterMode _caloriesFilterMode = FilterMode.less;

  // Preparation time filter
  bool _prepTimeFilterActive = false;
  int _prepTimeValue = 30;
  FilterMode _prepTimeFilterMode = FilterMode.less;

  // Nutrients filters
  bool _proteinFilterActive = false;
  double _proteinValue = 20.0;
  FilterMode _proteinFilterMode = FilterMode.more;

  bool _carbsFilterActive = false;
  double _carbsValue = 30.0;
  FilterMode _carbsFilterMode = FilterMode.less;

  bool _fatFilterActive = false;
  double _fatValue = 10.0;
  FilterMode _fatFilterMode = FilterMode.less;

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

  // Advanced filters getters
  bool get advancedFiltersActive => _advancedFiltersActive;

  bool get caloriesFilterActive => _caloriesFilterActive;
  int get caloriesValue => _caloriesValue;
  FilterMode get caloriesFilterMode => _caloriesFilterMode;

  bool get prepTimeFilterActive => _prepTimeFilterActive;
  int get prepTimeValue => _prepTimeValue;
  FilterMode get prepTimeFilterMode => _prepTimeFilterMode;

  bool get proteinFilterActive => _proteinFilterActive;
  double get proteinValue => _proteinValue;
  FilterMode get proteinFilterMode => _proteinFilterMode;

  bool get carbsFilterActive => _carbsFilterActive;
  double get carbsValue => _carbsValue;
  FilterMode get carbsFilterMode => _carbsFilterMode;

  bool get fatFilterActive => _fatFilterActive;
  double get fatValue => _fatValue;
  FilterMode get fatFilterMode => _fatFilterMode;

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

  // Get filtered recipes based on search query, category, favorites, meal type and advanced filters
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

      // Apply advanced filters if active
      bool passesAdvancedFilters = true;

      if (_advancedFiltersActive) {
        // Apply calories filter
        if (_caloriesFilterActive) {
          switch (_caloriesFilterMode) {
            case FilterMode.less:
              if (recipe.calories >= _caloriesValue)
                passesAdvancedFilters = false;
              break;
            case FilterMode.exactly:
              if (recipe.calories != _caloriesValue)
                passesAdvancedFilters = false;
              break;
            case FilterMode.more:
              if (recipe.calories <= _caloriesValue)
                passesAdvancedFilters = false;
              break;
          }
        }

        // Apply prep time filter
        if (passesAdvancedFilters && _prepTimeFilterActive) {
          final totalPrepTime = recipe.preparationTime + recipe.cookingTime;
          switch (_prepTimeFilterMode) {
            case FilterMode.less:
              if (totalPrepTime >= _prepTimeValue)
                passesAdvancedFilters = false;
              break;
            case FilterMode.exactly:
              if (totalPrepTime != _prepTimeValue)
                passesAdvancedFilters = false;
              break;
            case FilterMode.more:
              if (totalPrepTime <= _prepTimeValue)
                passesAdvancedFilters = false;
              break;
          }
        }

        // Apply protein filter
        if (passesAdvancedFilters && _proteinFilterActive) {
          final protein = recipe.nutrients['protein'] ?? 0.0;
          switch (_proteinFilterMode) {
            case FilterMode.less:
              if (protein >= _proteinValue) passesAdvancedFilters = false;
              break;
            case FilterMode.exactly:
              if ((protein - _proteinValue).abs() > 0.1)
                passesAdvancedFilters = false;
              break;
            case FilterMode.more:
              if (protein <= _proteinValue) passesAdvancedFilters = false;
              break;
          }
        }

        // Apply carbs filter
        if (passesAdvancedFilters && _carbsFilterActive) {
          final carbs = recipe.nutrients['carbohydrates'] ?? 0.0;
          switch (_carbsFilterMode) {
            case FilterMode.less:
              if (carbs >= _carbsValue) passesAdvancedFilters = false;
              break;
            case FilterMode.exactly:
              if ((carbs - _carbsValue).abs() > 0.1)
                passesAdvancedFilters = false;
              break;
            case FilterMode.more:
              if (carbs <= _carbsValue) passesAdvancedFilters = false;
              break;
          }
        }

        // Apply fat filter
        if (passesAdvancedFilters && _fatFilterActive) {
          final fat = recipe.nutrients['fat'] ?? 0.0;
          switch (_fatFilterMode) {
            case FilterMode.less:
              if (fat >= _fatValue) passesAdvancedFilters = false;
              break;
            case FilterMode.exactly:
              if ((fat - _fatValue).abs() > 0.1) passesAdvancedFilters = false;
              break;
            case FilterMode.more:
              if (fat <= _fatValue) passesAdvancedFilters = false;
              break;
          }
        }
      }

      return matchesSearch && matchesCategory && passesAdvancedFilters;
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

  // Advanced filter methods
  void setAdvancedFiltersActive(bool active) {
    _advancedFiltersActive = active;
    notifyListeners();
  }

  void toggleAdvancedFilters() {
    _advancedFiltersActive = !_advancedFiltersActive;
    notifyListeners();
  }

  void resetAllFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _showOnlyFavorites = false;
    _selectedMealTypeFilter = MealType.any;
    _advancedFiltersActive = false;
    _caloriesFilterActive = false;
    _prepTimeFilterActive = false;
    _proteinFilterActive = false;
    _carbsFilterActive = false;
    _fatFilterActive = false;
    notifyListeners();
  }

  // Calories filter methods
  void setCaloriesFilter({
    required bool active,
    int? value,
    FilterMode? mode,
  }) {
    _caloriesFilterActive = active;
    if (value != null) _caloriesValue = value;
    if (mode != null) _caloriesFilterMode = mode;
    notifyListeners();
  }

  // Prep time filter methods
  void setPrepTimeFilter({
    required bool active,
    int? value,
    FilterMode? mode,
  }) {
    _prepTimeFilterActive = active;
    if (value != null) _prepTimeValue = value;
    if (mode != null) _prepTimeFilterMode = mode;
    notifyListeners();
  }

  // Protein filter methods
  void setProteinFilter({
    required bool active,
    double? value,
    FilterMode? mode,
  }) {
    _proteinFilterActive = active;
    if (value != null) _proteinValue = value;
    if (mode != null) _proteinFilterMode = mode;
    notifyListeners();
  }

  // Carbs filter methods
  void setCarbsFilter({
    required bool active,
    double? value,
    FilterMode? mode,
  }) {
    _carbsFilterActive = active;
    if (value != null) _carbsValue = value;
    if (mode != null) _carbsFilterMode = mode;
    notifyListeners();
  }

  // Fat filter methods
  void setFatFilter({
    required bool active,
    double? value,
    FilterMode? mode,
  }) {
    _fatFilterActive = active;
    if (value != null) _fatValue = value;
    if (mode != null) _fatFilterMode = mode;
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
      try {
        // Try to load goals from API first
        _goals = await _apiService.getGoals();
      } catch (e) {
        // If API fails, load from local storage
        print('[loadGoals] API error, falling back to local storage: $e');
        _goals = await _storageService.loadUserGoals();
      }

      // Also try to load the active goal
      final activeGoal = await _storageService.loadActiveGoal();
      if (activeGoal != null && !_goals.any((g) => g.id == activeGoal.id)) {
        _goals = [..._goals, activeGoal];
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActiveGoals() async {
    _setLoading(true);
    try {
      try {
        // Try to load active goals from API first
        final activeGoals = await _apiService.getActiveGoals();
        // Update the in-memory goals list with active goals
        _goals = _mergeGoals(_goals, activeGoals);
      } catch (e) {
        print('[loadActiveGoals] API error: $e');
        // In case of error, we continue with the goals we already have
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load active goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCompletedGoals() async {
    _setLoading(true);
    try {
      try {
        // Try to load completed goals from API first
        final completedGoals = await _apiService.getCompletedGoals();
        // Update the in-memory goals list with completed goals
        _goals = _mergeGoals(_goals, completedGoals);
      } catch (e) {
        print('[loadCompletedGoals] API error: $e');
        // In case of error, we continue with the goals we already have
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load completed goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Merge new goals with existing goals, avoiding duplicates
  List<Goal> _mergeGoals(List<Goal> existingGoals, List<Goal> newGoals) {
    final Map<String, Goal> goalMap = {
      for (final goal in existingGoals) goal.id: goal
    };

    // Add or update with new goals
    for (final newGoal in newGoals) {
      goalMap[newGoal.id] = newGoal;
    }

    return goalMap.values.toList();
  }

  Future<void> addGoal(Goal goal) async {
    _setLoading(true);
    try {
      // Check if there's already an active goal
      final hasActiveGoal = _goals.any((g) =>
          g.endDate.isAfter(DateTime.now()) &&
          g.startDate.isBefore(DateTime.now()));

      if (hasActiveGoal) {
        _error = 'You can only have one active goal at a time';
        return;
      }

      Goal newGoal;

      try {
        // Try to add goal via API first
        newGoal = await _apiService.createGoal(goal);
      } catch (e) {
        // If API fails, create a local ID and use the provided goal
        print('[addGoal] API error, using local storage only: $e');

        // Create a local ID if not provided
        if (goal.id.isEmpty) {
          final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
          newGoal = Goal(
            id: localId,
            goalType: goal.goalType,
            startDate: goal.startDate,
            endDate: goal.endDate,
            targetCalories: goal.targetCalories,
            targetProtein: goal.targetProtein,
            targetCarbs: goal.targetCarbs,
            targetFat: goal.targetFat,
            userId: goal.userId,
            desiredWeight: goal.desiredWeight,
            startWeight: goal.startWeight,
            numberOfMealsPerDay: goal.numberOfMealsPerDay,
            activityStatusPerDay: goal.activityStatusPerDay,
          );
        } else {
          newGoal = goal;
        }
      }

      // Update in-memory list of goals
      _goals = [..._goals, newGoal];

      // Save to local storage
      await _saveGoalsToLocalStorage();

      // Set this goal as active
      await _storageService.saveActiveGoal(newGoal);

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
      Goal updatedGoal;

      try {
        // Try to update goal via API first
        updatedGoal = await _apiService.updateGoal(goal);
      } catch (e) {
        // If API fails, just use the provided goal
        print('[updateGoal] API error, using local storage only: $e');
        updatedGoal = goal;
      }

      // Update in-memory list of goals
      _goals = [
        for (final g in _goals)
          if (g.id == updatedGoal.id) updatedGoal else g,
      ];

      // Save to local storage
      await _saveGoalsToLocalStorage();

      // Update active goal if this is the active one
      final activeGoal = await _storageService.loadActiveGoal();
      if (activeGoal != null && activeGoal.id == updatedGoal.id) {
        await _storageService.saveActiveGoal(updatedGoal);
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to update goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _setLoading(true);
    try {
      try {
        // Try to delete goal via API first
        await _apiService.deleteGoal(goalId);
      } catch (e) {
        // If API fails, just continue with local delete
        print('[deleteGoal] API error, using local storage only: $e');
      }

      // Update in-memory list of goals
      _goals = _goals.where((g) => g.id != goalId).toList();

      // Save to local storage
      await _saveGoalsToLocalStorage();

      // If this was the active goal, clear it
      final activeGoal = await _storageService.loadActiveGoal();
      if (activeGoal != null && activeGoal.id == goalId) {
        await _storageService.clearActiveGoal();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to delete goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Save all goals to local storage
  Future<void> _saveGoalsToLocalStorage() async {
    try {
      await _storageService.saveUserGoals(_goals);
    } catch (e) {
      print('[_saveGoalsToLocalStorage] Error saving goals: $e');
    }
  }

  /// Set goal as active goal
  Future<void> setActiveGoal(Goal goal) async {
    try {
      await _storageService.saveActiveGoal(goal);
      notifyListeners();
    } catch (e) {
      print('[setActiveGoal] Error setting active goal: $e');
    }
  }

  /// Get active goal
  Future<Goal?> getActiveGoal() async {
    try {
      return await _storageService.loadActiveGoal();
    } catch (e) {
      print('[getActiveGoal] Error getting active goal: $e');
      return null;
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
