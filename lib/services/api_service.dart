import 'dart:convert';

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
      preparationTime: int.tryParse(json['prep_time']?.toString() ?? '') ?? 0,
      cookingTime: int.tryParse(json['cook_time']?.toString() ?? '') ?? 0,
      servings: int.tryParse(json['servings']?.toString() ?? '') ?? 0,
      ingredients: _parseStringList(
        json['ingredients'],
      ), // Parse comma-separated string to List
      instructions: _parseStringList(
        json['instructions_list'],
      ), // Parse comma-separated string to List
      categories: _parseStringList(json['category']), // Single category to List
      calories: int.tryParse(json['calories']?.toString() ?? '') ?? 0,
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
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
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
