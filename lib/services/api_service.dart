// ignore_for_file: avoid_catches_without_on_clauses, omit_local_variable_types, prefer_final_in_for_each

import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

import '../models/grocery_list.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  static const String baseUrl = 'http://localhost:3000/api';
  final http.Client _client;

  // Recipe endpoints
  Future<List<Recipe>> getRecipes() async {
    final response = await _client.get(Uri.parse('$baseUrl/recipes'));
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => _transformRecipeResponse(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Recipe> getRecipe(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/recipes/$id'));
    if (response.statusCode == 200) {
      return _transformRecipeResponse(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load recipe');
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_transformRecipeRequest(recipe)),
    );
    if (response.statusCode == 201) {
      return _transformRecipeResponse(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create recipe');
  }

  // Private helper methods
  Recipe _transformRecipeResponse(Map<String, dynamic> json) {
    // Transform the database response to match our Flutter model
    return Recipe(
      id: (json['RID'] ?? '')
          .toString(), // Convert INTEGER to String with null safety
      name: (json['title'] ?? '')
          .toString(), // Map 'title' to 'name' with null safety
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image'] ?? '').toString(), // Map 'image' to 'imageUrl'
      preparationTime: _extractPreparationMinutes(json['prep_time']),
      cookingTime: int.tryParse(json['cook_time']?.toString() ?? '') ?? 0,
      servings: int.tryParse(json['servings']?.toString() ?? '') ?? 0,
      ingredients: _parseStringList(
        json['ingredients'],
      ), // Parse comma-separated string to List
      instructions: _parseStringList(
        json['instructions_list'],
      ), // Parse comma-separated string to List
      categories: _parseStringList(json['category']), // Single category to List
      calories: _extractCalories(json['calories']),
      nutrients: {
        'protein': double.tryParse(json['protein_g']?.toString() ?? '') ?? 0.0,
        'carbohydrates':
            double.tryParse(json['carbohydrates_g']?.toString() ?? '') ?? 0.0,
        'fat': double.tryParse(json['fat_g']?.toString() ?? '') ?? 0.0,
        'fiber':
            double.tryParse(json['dietary_fiber_g']?.toString() ?? '') ?? 0.0,
        'sodium': double.tryParse(json['sodium_mg']?.toString() ?? '') ?? 0.0,
      },
    );
  }

  Map<String, dynamic> _transformRecipeRequest(Recipe recipe) {
    // Transform the Flutter model to match database schema
    return {
      'RID': int.tryParse(recipe.id) ?? 0,
      'title': recipe.name,
      'description': recipe.description,
      'image': recipe.imageUrl,
      'prep_time': recipe.preparationTime,
      'cook_time': recipe.cookingTime,
      'servings': recipe.servings,
      'ingredients': recipe.ingredients.join(','),
      'instructions_list': recipe.instructions.join(','),
      'category': recipe.categories.firstOrNull ?? '',
      'calories': recipe.calories,
      'protein_g': recipe.nutrients['protein'] ?? 0.0,
      'carbohydrates_g': recipe.nutrients['carbohydrates'] ?? 0.0,
      'fat_g': recipe.nutrients['fat'] ?? 0.0,
      'dietary_fiber_g': recipe.nutrients['fiber'] ?? 0.0,
      'sodium_mg': recipe.nutrients['sodium'] ?? 0.0,
    };
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      // Handle array-like string format from API: "['item1', 'item2', ...]"
      if (value.startsWith('[') && value.endsWith(']')) {
        try {
          // Remove the outer brackets
          final String strippedValue = value.substring(1, value.length - 1);

          // Split by the pattern ', ' but only when preceded by a single quote
          // This helps prevent splitting text that contains periods
          final List<String> items = [];
          final RegExp regex = RegExp(r"'(.*?)'(?:,\s*|$)");
          final Iterable<Match> matches = regex.allMatches(strippedValue);

          for (Match match in matches) {
            if (match.group(1) != null) {
              items.add(match.group(1)!);
            }
          }

          return items;
        } catch (e) {
          if (kDebugMode) {
            print('[_parseStringList] Error parsing array string: $e');
          }
          // Fall back to comma splitting if regex fails
          return value
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }

      // Regular comma-separated string
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  // Extract preparation time in minutes from string like "15 mins" or null
  int _extractPreparationMinutes(dynamic prepTimeValue) {
    if (prepTimeValue == null) return 0;

    final prepTimeStr = prepTimeValue.toString();
    if (prepTimeStr.isEmpty) return 0;

    // Try to extract numeric part from strings like "15 mins"
    final RegExp numericRegex = RegExp(r'(\d+)');
    final match = numericRegex.firstMatch(prepTimeStr);

    if (match != null && match.group(1) != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }

    // Fallback to direct parsing if it's just a number
    return int.tryParse(prepTimeStr) ?? 0;
  }

  // Extract calories value ensuring it's an integer
  int _extractCalories(dynamic caloriesValue) {
    if (caloriesValue == null) return 0;

    if (caloriesValue is int) return caloriesValue;
    if (caloriesValue is double) return caloriesValue.round();

    final caloriesStr = caloriesValue.toString();
    if (caloriesStr.isEmpty) return 0;

    // Try parsing as double first then convert to int
    final double? parsedDouble = double.tryParse(caloriesStr);
    if (parsedDouble != null) {
      return parsedDouble.round();
    }

    // Fallback to direct integer parsing
    return int.tryParse(caloriesStr) ?? 0;
  }

  // Meal Plan endpoints
  Future<List<MealPlan>> getMealPlans() async {
    final response = await _client.get(Uri.parse('$baseUrl/meal-plans'));
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => MealPlan.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load meal plans');
  }

  Future<MealPlan> getMealPlan(String id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/meal-plans/$id'),
    );
    if (response.statusCode == 200) {
      return MealPlan.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load meal plan');
  }

  Future<MealPlan> createMealPlan(MealPlan mealPlan) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/meal-plans'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mealPlan.toJson()),
    );
    if (response.statusCode == 201) {
      return MealPlan.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create meal plan');
  }

  // Grocery List endpoints
  Future<List<GroceryList>> getGroceryLists() async {
    final response = await _client.get(Uri.parse('$baseUrl/grocery-lists'));
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => GroceryList.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load grocery lists');
  }

  Future<GroceryList> getGroceryList(String id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/grocery-lists/$id'),
    );
    if (response.statusCode == 200) {
      return GroceryList.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load grocery list');
  }

  Future<GroceryList> createGroceryList(GroceryList groceryList) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/grocery-lists'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(groceryList.toJson()),
    );
    if (response.statusCode == 201) {
      return GroceryList.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create grocery list');
  }

  Future<GroceryList> updateGroceryList(GroceryList groceryList) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/grocery-lists/${groceryList.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(groceryList.toJson()),
    );
    if (response.statusCode == 200) {
      return GroceryList.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to update grocery list');
  }
}
