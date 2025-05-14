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
      'targetCalories': json['Target_Calories'] ?? json['targetCalories'] ?? 0,
      'targetProtein': json['Target_Protein'] ?? json['targetProtein'] ?? 0,
      'targetCarbs': json['Target_Carbs'] ?? json['targetCarbs'] ?? 0,
      'targetFat': json['Target_Fat'] ?? json['targetFat'] ?? 0,
      'userId': json['UID']?.toString() ?? '',
      'desiredWeight': json['desired_Weight'] ?? json['desiredWeight'],
      'startWeight': json['start_weight'] ?? json['startWeight'],
      'numberOfMealsPerDay':
          json['number_of_meals_per_day'] ?? json['numberOfMealsPerDay'],
      'activityStatusPerDay':
          json['activity_status_per_day'] ?? json['activityStatusPerDay'],
    };

    return _$GoalFromJson(normalizedJson);
  }

  /// Connect the generated [_$GoalToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() {
    // First get the standard JSON representation
    final Map<String, dynamic> json = _$GoalToJson(this);

    // Then convert to server field names
    return {
      // If ID is empty (new goal) or starts with 'local', don't include it in the server request
      if (id.isNotEmpty && !id.startsWith('local_')) 'GID': id,
      'Goal_Type': goalType,
      'Start_Date': startDate.toIso8601String(),
      'End_Date': endDate.toIso8601String(),
      'Target_Calories': targetCalories,
      'Target_Protein': targetProtein,
      'Target_Carbs': targetCarbs,
      'Target_Fat': targetFat,
      'UID': userId,
      if (desiredWeight != null) 'desired_Weight': desiredWeight,
      if (startWeight != null) 'start_weight': startWeight,
      if (numberOfMealsPerDay != null)
        'number_of_meals_per_day': numberOfMealsPerDay,
      if (activityStatusPerDay != null)
        'activity_status_per_day': activityStatusPerDay,
    };
  }
}
