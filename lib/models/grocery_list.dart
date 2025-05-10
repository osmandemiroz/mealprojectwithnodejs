import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grocery_list.g.dart';

@immutable
@JsonSerializable()
class GroceryItem {
  /// Default constructor for GroceryItem
  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
  });

  /// Creates a GroceryItem from JSON data
  factory GroceryItem.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemFromJson(json);

  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool isChecked;

  /// Converts GroceryItem to JSON
  Map<String, dynamic> toJson() => _$GroceryItemToJson(this);

  /// Creates a copy of GroceryItem with optional parameter overrides
  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

@immutable
@JsonSerializable()
class GroceryList {
  /// Default constructor for GroceryList
  const GroceryList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a GroceryList from JSON data
  factory GroceryList.fromJson(Map<String, dynamic> json) =>
      _$GroceryListFromJson(json);

  final String id;
  final String name;
  final List<GroceryItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Converts GroceryList to JSON
  Map<String, dynamic> toJson() => _$GroceryListToJson(this);

  /// Creates a copy of GroceryList with optional parameter overrides
  GroceryList copyWith({
    String? id,
    String? name,
    List<GroceryItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroceryList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get items grouped by category
  Map<String, List<GroceryItem>> get itemsByCategory {
    return items.fold<Map<String, List<GroceryItem>>>(
      {},
      (map, item) {
        if (!map.containsKey(item.category)) {
          map[item.category] = [];
        }
        map[item.category]!.add(item);
        return map;
      },
    );
  }

  /// Get the count of checked items
  int get checkedItemsCount => items.where((item) => item.isChecked).length;

  /// Get the total number of items
  int get totalItemsCount => items.length;

  /// Get the completion percentage
  double get completionPercentage =>
      items.isEmpty ? 0 : (checkedItemsCount / totalItemsCount) * 100;
}
