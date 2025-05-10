import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'recipe.dart';

part 'meal_plan.g.dart';

@immutable
@JsonSerializable()
class MealPlan {
  /// Default constructor for MealPlan
  const MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalNutrients,
  });

  /// Creates a MealPlan from JSON data
  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);

  final String id;
  final DateTime date;
  final Map<String, Recipe>
      meals; // meal type (breakfast, lunch, dinner) -> Recipe
  final int totalCalories;
  final Map<String, double> totalNutrients;

  /// Converts MealPlan to JSON
  Map<String, dynamic> toJson() => _$MealPlanToJson(this);

  /// Creates a copy of MealPlan with optional parameter overrides
  MealPlan copyWith({
    String? id,
    DateTime? date,
    Map<String, Recipe>? meals,
    int? totalCalories,
    Map<String, double>? totalNutrients,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? Map.from(this.meals),
      totalCalories: totalCalories ?? this.totalCalories,
      totalNutrients: totalNutrients ?? Map.from(this.totalNutrients),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          meals == other.meals &&
          totalCalories == other.totalCalories &&
          totalNutrients == other.totalNutrients;

  @override
  int get hashCode =>
      id.hashCode ^
      date.hashCode ^
      meals.hashCode ^
      totalCalories.hashCode ^
      totalNutrients.hashCode;
}
