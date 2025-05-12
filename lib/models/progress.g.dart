// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progress _$ProgressFromJson(Map<String, dynamic> json) => Progress(
      userId: json['userId'] as String,
      goalId: json['goalId'] as String,
      currentWeight: (json['currentWeight'] as num).toDouble(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      lastUpdatedDate: DateTime.parse(json['lastUpdatedDate'] as String),
    );

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
      'userId': instance.userId,
      'goalId': instance.goalId,
      'currentWeight': instance.currentWeight,
      'progressPercentage': instance.progressPercentage,
      'lastUpdatedDate': instance.lastUpdatedDate.toIso8601String(),
    };
