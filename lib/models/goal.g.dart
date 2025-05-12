// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
      id: json['id'] as String,
      goalType: json['goalType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      targetCalories: (json['targetCalories'] as num).toInt(),
      targetProtein: (json['targetProtein'] as num).toInt(),
      targetCarbs: (json['targetCarbs'] as num).toInt(),
      targetFat: (json['targetFat'] as num).toInt(),
      userId: json['userId'] as String,
      desiredWeight: (json['desiredWeight'] as num?)?.toDouble(),
      startWeight: (json['startWeight'] as num?)?.toDouble(),
      numberOfMealsPerDay: (json['numberOfMealsPerDay'] as num?)?.toInt(),
      activityStatusPerDay: json['activityStatusPerDay'] as String?,
    );

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
      'id': instance.id,
      'goalType': instance.goalType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'targetCalories': instance.targetCalories,
      'targetProtein': instance.targetProtein,
      'targetCarbs': instance.targetCarbs,
      'targetFat': instance.targetFat,
      'userId': instance.userId,
      'desiredWeight': instance.desiredWeight,
      'startWeight': instance.startWeight,
      'numberOfMealsPerDay': instance.numberOfMealsPerDay,
      'activityStatusPerDay': instance.activityStatusPerDay,
    };
