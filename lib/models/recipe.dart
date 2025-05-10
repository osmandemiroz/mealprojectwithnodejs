import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

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
    );
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
          nutrients == other.nutrients;

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
      nutrients.hashCode;
}
