import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  /// Clear all stored data (for testing or user logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
