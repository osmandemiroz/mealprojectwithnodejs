// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';

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
                            await Future.delayed(
                                const Duration(milliseconds: 300));

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
          // TODO: Add to meal plan
        },
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Add to Meal Plan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /// Creates a meal type selector for favorited recipes
  Widget _buildMealTypeSelector(
      BuildContext context, Recipe currentRecipe, AppState appState) {
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
          width: 1,
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
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
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
}
