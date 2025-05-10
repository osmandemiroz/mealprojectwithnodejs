// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Recipe.fromJson(e as Map<String, dynamic>)),
      ),
      totalCalories: (json['totalCalories'] as num).toInt(),
      totalNutrients: (json['totalNutrients'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'meals': instance.meals,
      'totalCalories': instance.totalCalories,
      'totalNutrients': instance.totalNutrients,
    };
