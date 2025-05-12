import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

/// Enum representing different meal types
enum MealType { breakfast, lunch, dinner, snack, any }

/// Extension to convert meal type to string
extension MealTypeExtension on MealType {
  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.any:
        return 'Any';
    }
  }

  static MealType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.any;
    }
  }
}

@immutable
@JsonSerializable()
class Recipe {
  /// Default constructor for Recipe
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.categories,
    required this.calories,
    required this.nutrients,
    this.rating = 0.0,
    this.isFavorite = false,
    this.mealType = MealType.any,
  });

  /// Creates a Recipe from JSON data
  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int preparationTime;
  final int cookingTime;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> categories;
  final double rating;
  final int calories;
  final Map<String, double> nutrients;
  final bool isFavorite;
  final MealType mealType;

  /// Total time in minutes (preparation + cooking)
  int get totalTime => preparationTime + cookingTime;

  /// Converts Recipe to JSON
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  /// Creates a copy of Recipe with optional parameter overrides
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? categories,
    double? rating,
    int? calories,
    Map<String, double>? nutrients,
    bool? isFavorite,
    MealType? mealType,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? List.from(this.ingredients),
      instructions: instructions ?? List.from(this.instructions),
      categories: categories ?? List.from(this.categories),
      rating: rating ?? this.rating,
      calories: calories ?? this.calories,
      nutrients: nutrients ?? Map.from(this.nutrients),
      isFavorite: isFavorite ?? this.isFavorite,
      mealType: mealType ?? this.mealType,
    );
  }

  /// Determines the most likely meal type based on categories and name
  MealType determineMealType() {
    // Check categories first
    for (final category in categories) {
      final lowerCategory = category.toLowerCase();
      if (lowerCategory.contains('breakfast') ||
          lowerCategory.contains('morning')) {
        return MealType.breakfast;
      } else if (lowerCategory.contains('lunch') ||
          lowerCategory.contains('salad') ||
          lowerCategory.contains('sandwich')) {
        return MealType.lunch;
      } else if (lowerCategory.contains('dinner') ||
          lowerCategory.contains('main dish') ||
          lowerCategory.contains('entrée')) {
        return MealType.dinner;
      } else if (lowerCategory.contains('snack') ||
          lowerCategory.contains('appetizer')) {
        return MealType.snack;
      }
    }

    // Check name if categories didn't give us a match
    final lowerName = name.toLowerCase();
    if (lowerName.contains('breakfast') ||
        lowerName.contains('pancake') ||
        lowerName.contains('cereal') ||
        lowerName.contains('eggs') ||
        lowerName.contains('toast') ||
        lowerName.contains('oatmeal') ||
        lowerName.contains('smoothie')) {
      return MealType.breakfast;
    } else if (lowerName.contains('lunch') ||
        lowerName.contains('salad') ||
        lowerName.contains('sandwich') ||
        lowerName.contains('soup') ||
        lowerName.contains('wrap')) {
      return MealType.lunch;
    } else if (lowerName.contains('dinner') ||
        lowerName.contains('steak') ||
        lowerName.contains('pasta') ||
        lowerName.contains('curry') ||
        lowerName.contains('roast')) {
      return MealType.dinner;
    } else if (lowerName.contains('snack') ||
        lowerName.contains('chips') ||
        lowerName.contains('nuts') ||
        lowerName.contains('fruit') ||
        lowerName.contains('yogurt')) {
      return MealType.snack;
    }

    return MealType.any;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          preparationTime == other.preparationTime &&
          cookingTime == other.cookingTime &&
          servings == other.servings &&
          ingredients == other.ingredients &&
          instructions == other.instructions &&
          categories == other.categories &&
          rating == other.rating &&
          calories == other.calories &&
          nutrients == other.nutrients &&
          isFavorite == other.isFavorite &&
          mealType == other.mealType;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      preparationTime.hashCode ^
      cookingTime.hashCode ^
      servings.hashCode ^
      ingredients.hashCode ^
      instructions.hashCode ^
      categories.hashCode ^
      rating.hashCode ^
      calories.hashCode ^
      nutrients.hashCode ^
      isFavorite.hashCode ^
      mealType.hashCode;
}
