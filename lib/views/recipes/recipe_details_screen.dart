// ignore_for_file: deprecated_member_use, avoid_positional_boolean_parameters, avoid_catches_without_on_clauses

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({
    required this.recipe,
    super.key,
  });

  final Recipe recipe;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _isSavingFavorite = false;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appState = Provider.of<AppState>(context);

    // Get the current version of the recipe from app state (for favorite status)
    final currentRecipe = appState.recipes.firstWhere(
      (r) => r.id == widget.recipe.id,
      orElse: () => widget.recipe,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image - extend to full edge-to-edge
          SliverAppBar(
            expandedHeight:
                300 + statusBarHeight, // Account for status bar height
            pinned: true,
            backgroundColor: AppTheme.surfaceColor,
            // Remove default padding to get edge-to-edge look
            leadingWidth: 60,
            leading: Padding(
              padding: EdgeInsets.only(left: 16, top: statusBarHeight - 4),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              // Favorite button
              Padding(
                padding: EdgeInsets.only(right: 16, top: statusBarHeight - 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: _isSavingFavorite
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            currentRecipe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: currentRecipe.isFavorite
                                ? Colors.red
                                : Colors.white,
                            size: 22,
                          ),
                    onPressed: _isSavingFavorite
                        ? null
                        : () async {
                            // Show saving indicator
                            setState(() => _isSavingFavorite = true);

                            // Toggle favorite
                            await appState.toggleFavorite(widget.recipe.id);

                            // Hide indicator after a short delay
                            // ignore: inference_failure_on_instance_creation
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

                            if (mounted) {
                              setState(() => _isSavingFavorite = false);
                            }
                          },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              // Remove any default padding
              titlePadding: EdgeInsets.zero,
              // Make the image take the full width and height including status bar
              background: Hero(
                tag: 'recipe_image_${widget.recipe.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.recipe.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ),

          // Recipe Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name
                  Text(
                    widget.recipe.name,
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing8),

                  // Recipe Description
                  Text(
                    widget.recipe.description,
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  // Meal type selection (only shown if recipe is favorited)
                  if (currentRecipe.isFavorite) ...[
                    const SizedBox(height: AppTheme.spacing16),
                    _buildMealTypeSelector(context, currentRecipe, appState),
                  ],

                  const SizedBox(height: AppTheme.spacing16),

                  // Recipe Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.timer_outlined,
                          label: 'Prep Time',
                          value: widget.recipe.preparationTime > 0
                              ? '${widget.recipe.preparationTime} min'
                              : '0 min',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Calories',
                          value: widget.recipe.calories > 0
                              ? '${widget.recipe.calories} kcal'
                              : '0 kcal',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.people_outline,
                          label: 'Servings',
                          value: '${widget.recipe.servings}',
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(),

                  const SizedBox(height: AppTheme.spacing24),

                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing12),

                  ...widget.recipe.ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: AppTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideX();
                  }),

                  const SizedBox(height: AppTheme.spacing24),

                  // Instructions Section
                  Text(
                    'Instructions',
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing12),

                  // Process all instructions and split into individual sentences
                  ..._getAllInstructionSentences(widget.recipe.instructions)
                      .asMap()
                      .entries
                      .map((entry) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideX();
                  }),

                  const SizedBox(height: AppTheme.spacing24),

                  // Nutrition Section
                  Text(
                    'Nutrition Facts',
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing12),

                  ...widget.recipe.nutrients.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatNutrientName(entry.key),
                            style: AppTheme.bodyLarge,
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(1)}g',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideX();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddToMealPlanDialog(context, widget.recipe);
        },
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Add to Meal Plan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /// Creates a meal type selector for favorited recipes
  Widget _buildMealTypeSelector(
    BuildContext context,
    Recipe currentRecipe,
    AppState appState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Type',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMealTypeChip(
                context: context,
                type: MealType.breakfast,
                currentType: currentRecipe.mealType,
                onSelected: (selected) {
                  if (selected) {
                    appState.updateRecipeMealType(
                      currentRecipe.id,
                      MealType.breakfast,
                    );
                  }
                },
              ),
              _buildMealTypeChip(
                context: context,
                type: MealType.lunch,
                currentType: currentRecipe.mealType,
                onSelected: (selected) {
                  if (selected) {
                    appState.updateRecipeMealType(
                      currentRecipe.id,
                      MealType.lunch,
                    );
                  }
                },
              ),
              _buildMealTypeChip(
                context: context,
                type: MealType.dinner,
                currentType: currentRecipe.mealType,
                onSelected: (selected) {
                  if (selected) {
                    appState.updateRecipeMealType(
                      currentRecipe.id,
                      MealType.dinner,
                    );
                  }
                },
              ),
              _buildMealTypeChip(
                context: context,
                type: MealType.snack,
                currentType: currentRecipe.mealType,
                onSelected: (selected) {
                  if (selected) {
                    appState.updateRecipeMealType(
                      currentRecipe.id,
                      MealType.snack,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  /// Creates a selectable chip for meal type selection
  Widget _buildMealTypeChip({
    required BuildContext context,
    required MealType type,
    required MealType currentType,
    // ignore: inference_failure_on_function_return_type
    required Function(bool) onSelected,
  }) {
    final isSelected = type == currentType;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMealTypeIcon(type),
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              type.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAllInstructionSentences(List<String> instructions) {
    final sentences = <String>[];
    for (final instruction in instructions) {
      // Some APIs provide instructions as single sentences, others as paragraphs
      if (instruction.contains('.') &&
          !instruction.trim().endsWith('.') &&
          instruction.length > 100) {
        // It's a paragraph with multiple sentences
        final splits = instruction.split('.');
        for (final split in splits) {
          if (split.trim().isNotEmpty) {
            sentences.add('${split.trim()}.');
          }
        }
      } else {
        // It's a single instruction
        sentences.add(instruction);
      }
    }
    return sentences;
  }

  String _formatNutrientName(String name) {
    // Capitalize first letter of each word
    return name
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  // Helper to get appropriate icon for each meal type
  IconData _getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.wb_cloudy;
      case MealType.dinner:
        return Icons.nights_stay;
      case MealType.snack:
        return Icons.cookie;
      case MealType.any:
        return Icons.restaurant;
    }
  }

  void _showAddToMealPlanDialog(BuildContext context, Recipe recipe) {
    // List of meal types to choose from
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    var isAdding = false;

    // Default selected meal type based on recipe's meal type
    var selectedMealType = 'Lunch';
    if (recipe.mealType == MealType.breakfast) {
      selectedMealType = 'Breakfast';
    } else if (recipe.mealType == MealType.dinner) {
      selectedMealType = 'Dinner';
    } else if (recipe.mealType == MealType.snack) {
      selectedMealType = 'Snacks';
    }

    // Show the dialog to select meal type
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                topRight: Radius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacing8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing16,
                  ),
                  child: Text(
                    'Add to Meal Plan',
                    style: AppTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                  ),
                  child: Text(
                    'Choose a meal type for "${recipe.name}"',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppTheme.spacing24),

                // Meal type chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: mealTypes.map((type) {
                      final isSelected = selectedMealType == type;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMealType = type;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing12,
                            horizontal: AppTheme.spacing16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.borderColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getMealTypeIconForType(type),
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Spacer(),

                // Add to meal plan button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacing16,
                    AppTheme.spacing16,
                    AppTheme.spacing16,
                    AppTheme.spacing16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: FilledButton(
                    onPressed: isAdding
                        ? null
                        : () async {
                            setState(() {
                              isAdding = true;
                            });

                            try {
                              // Get the current date
                              final now = DateTime.now();
                              final today =
                                  DateTime(now.year, now.month, now.day);

                              // Get the storage service
                              final storageService = StorageService();

                              // DON'T try to update app state directly as it causes the error
                              // Just use the storage service directly

                              // Load existing meal plan for today
                              final mealPlanData =
                                  await storageService.loadDailyMealPlan(today);

                              // Initialize with empty map if no data found
                              final mealsByType = mealPlanData ??
                                  <String, Map<String, dynamic>>{};

                              // Add this recipe to the selected meal type
                              mealsByType[selectedMealType] = {
                                'recipeId': recipe.id,
                                'name': recipe.name,
                                'calories': recipe.calories,
                                'imageUrl': recipe.imageUrl,
                                'timestamp':
                                    DateTime.now().millisecondsSinceEpoch,
                              };

                              // Save the updated meal plan
                              await storageService.saveDailyMealPlan(
                                today,
                                mealsByType,
                              );

                              if (mounted) {
                                // Close the dialog
                                Navigator.pop(context);

                                // Store the successfully added recipe and meal type for navigation
                                final addedRecipe = recipe;
                                final addedMealType = selectedMealType;

                                // Show a success message without VIEW button
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${addedRecipe.name} added to ${addedMealType.toLowerCase()}',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (error) {
                              if (kDebugMode) {
                                print(
                                  '[_showAddToMealPlanDialog] Error adding to meal plan: $error',
                                );
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to add recipe to meal plan',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                // Close the dialog even if there was an error
                                Navigator.pop(context);
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isAdding = false;
                                });
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      // Add disabled style for when button is in loading state
                      disabledBackgroundColor:
                          AppTheme.primaryColor.withOpacity(0.6),
                    ),
                    child: isAdding
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add to Today's Meal Plan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper to get appropriate icon for each meal type string
  IconData _getMealTypeIconForType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_cloudy;
      case 'dinner':
        return Icons.nights_stay;
      case 'snacks':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}
