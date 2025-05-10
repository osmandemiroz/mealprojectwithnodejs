// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      preparationTime: (json['preparationTime'] as num).toInt(),
      cookingTime: (json['cookingTime'] as num).toInt(),
      servings: (json['servings'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      calories: (json['calories'] as num).toInt(),
      nutrients: (json['nutrients'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'preparationTime': instance.preparationTime,
      'cookingTime': instance.cookingTime,
      'servings': instance.servings,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'categories': instance.categories,
      'rating': instance.rating,
      'calories': instance.calories,
      'nutrients': instance.nutrients,
    };
