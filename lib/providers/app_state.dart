import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';
import '../models/grocery_list.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService;

  List<Recipe> _recipes = [];
  List<MealPlan> _mealPlans = [];
  List<GroceryList> _groceryLists = [];
  bool _isLoading = false;
  String? _error;

  // Search states
  String _searchQuery = '';
  String _selectedCategory = 'All';

  AppState({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // Getters
  List<Recipe> get recipes => _recipes;
  List<MealPlan> get mealPlans => _mealPlans;
  List<GroceryList> get groceryLists => _groceryLists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Get filtered recipes based on search query and selected category
  List<Recipe> get filteredRecipes {
    if (_searchQuery.isEmpty && _selectedCategory == 'All') {
      return _recipes;
    }

    return _recipes.where((recipe) {
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

  // Recipe methods
  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _recipes = await _apiService.getRecipes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load recipes: $e';
    } finally {
      _setLoading(false);
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
