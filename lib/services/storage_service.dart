import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';
import '../models/recipe.dart';

/// Service to handle local storage operations
class StorageService {
  // Private constructor for singleton pattern
  StorageService._();

  // Singleton instance
  static final StorageService _instance = StorageService._();

  // Factory constructor to return the singleton instance
  factory StorageService() => _instance;

  // Keys for shared preferences
  static const String _favoriteRecipesKey = 'favorite_recipes';
  static const String _recipeMealTypesKey = 'recipe_meal_types';
  static const String _activeGoalKey = 'active_goal';
  static const String _userGoalsKey = 'user_goals';

  /// Initialize the storage service
  Future<void> init() async {
    // Nothing to initialize at the moment
    // This method can be used for any future initialization needs
  }

  /// Save favorite recipes to local storage
  Future<void> saveFavoriteRecipes(List<String> favoriteRecipeIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteRecipesKey, favoriteRecipeIds);
  }

  /// Load favorite recipe IDs from local storage
  Future<List<String>> loadFavoriteRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteRecipesKey) ?? [];
  }

  /// Save a recipe's meal type to local storage
  Future<void> saveRecipeMealType(String recipeId, MealType mealType) async {
    final prefs = await SharedPreferences.getInstance();
    final mealTypesJson = prefs.getString(_recipeMealTypesKey) ?? '{}';
    final Map<String, dynamic> mealTypes =
        json.decode(mealTypesJson) as Map<String, dynamic>;

    // Update the map with the new meal type
    mealTypes[recipeId] = mealType.name;

    // Save the updated map back to shared preferences
    await prefs.setString(_recipeMealTypesKey, json.encode(mealTypes));
  }

  /// Load meal types for all recipes from local storage
  Future<Map<String, MealType>> loadRecipeMealTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final mealTypesJson = prefs.getString(_recipeMealTypesKey) ?? '{}';
    final Map<String, dynamic> mealTypes =
        json.decode(mealTypesJson) as Map<String, dynamic>;

    // Convert the string values to MealType enum values
    final Map<String, MealType> result = {};
    mealTypes.forEach((key, value) {
      result[key] = MealTypeExtension.fromString(value as String);
    });

    return result;
  }

  /// Save the active goal to local storage
  Future<void> saveActiveGoal(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = json.encode(goal.toJson());
    await prefs.setString(_activeGoalKey, goalJson);
  }

  /// Load the active goal from local storage
  Future<Goal?> loadActiveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = prefs.getString(_activeGoalKey);

    if (goalJson == null || goalJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> goalMap =
          json.decode(goalJson) as Map<String, dynamic>;
      return Goal.fromJson(goalMap);
    } catch (e) {
      print('[loadActiveGoal] Error parsing goal: $e'); // Add function name
      return null;
    }
  }

  /// Save all user goals to local storage
  Future<void> saveUserGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = json.encode(goals.map((goal) => goal.toJson()).toList());
    await prefs.setString(_userGoalsKey, goalsJson);
  }

  /// Load all user goals from local storage
  Future<List<Goal>> loadUserGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_userGoalsKey);

    if (goalsJson == null || goalsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> goalsList = json.decode(goalsJson) as List<dynamic>;
      return goalsList
          .map((goalMap) => Goal.fromJson(goalMap as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[loadUserGoals] Error parsing goals: $e'); // Add function name
      return [];
    }
  }

  /// Clear all stored data (for testing or user logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
