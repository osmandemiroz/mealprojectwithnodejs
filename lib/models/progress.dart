import 'package:json_annotation/json_annotation.dart';

part 'progress.g.dart';

@JsonSerializable()
class Progress {
  final String userId;
  final String goalId;
  final double currentWeight;
  final double progressPercentage;
  final DateTime lastUpdatedDate;

  Progress({
    required this.userId,
    required this.goalId,
    required this.currentWeight,
    required this.progressPercentage,
    required this.lastUpdatedDate,
  });

  /// Connect the generated [_$ProgressFromJson] function to the `fromJson` factory.
  factory Progress.fromJson(Map<String, dynamic> json) {
    // Convert database field names to our model properties
    Map<String, dynamic> normalizedJson = {
      'userId': json['UID']?.toString() ?? '',
      'goalId': json['GID']?.toString() ?? '',
      'currentWeight': json['Current_Weight'] ?? 0.0,
      'progressPercentage': json['Progress_Percentage'] ?? 0.0,
      'lastUpdatedDate': json['Last_Updated_Date'],
    };

    return _$ProgressFromJson(normalizedJson);
  }

  /// Connect the generated [_$ProgressToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
