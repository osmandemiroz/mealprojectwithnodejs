import 'package:json_annotation/json_annotation.dart';

part 'goal.g.dart';

@JsonSerializable()
class Goal {
  final String id;
  final String goalType;
  final DateTime startDate;
  final DateTime endDate;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final String userId;
  final double? desiredWeight;
  final double? startWeight;
  final int? numberOfMealsPerDay;
  final String? activityStatusPerDay;

  Goal({
    required this.id,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.userId,
    this.desiredWeight,
    this.startWeight,
    this.numberOfMealsPerDay,
    this.activityStatusPerDay,
  });

  /// Connect the generated [_$GoalFromJson] function to the `fromJson` factory.
  factory Goal.fromJson(Map<String, dynamic> json) {
    // Convert database field names to our model properties
    Map<String, dynamic> normalizedJson = {
      'id': json['GID']?.toString() ?? '',
      'goalType': json['Goal_Type'] ?? '',
      'startDate': json['Start_Date'],
      'endDate': json['End_Date'],
      'targetCalories': json['Target_Calories'],
      'targetProtein': json['Target_Protein'],
      'targetCarbs': json['Target_Carbs'],
      'targetFat': json['Target_Fat'],
      'userId': json['UID']?.toString() ?? '',
      'desiredWeight': json['desired_Weight'],
      'startWeight': json['start_weight'],
      'numberOfMealsPerDay': json['number_of_meals_per_day'],
      'activityStatusPerDay': json['activity_status_per_day'],
    };

    return _$GoalFromJson(normalizedJson);
  }

  /// Connect the generated [_$GoalToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
