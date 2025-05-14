// ignore_for_file: deprecated_member_use, inference_failure_on_instance_creation

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/recipe.dart';
import '../providers/app_state.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({
    required this.recipe,
    this.onTap,
    this.animate = true,
    this.showFavoriteButton = true,
    super.key,
  });

  final Recipe recipe;
  final VoidCallback? onTap;
  final bool animate;
  final bool showFavoriteButton;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: false);

    final card = Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section with meal type badge and favorite button
              Stack(
                children: [
                  // Recipe image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                      topRight: Radius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: widget.recipe.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline,
                          size: 32,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ),

                  // Meal type badge (if favorited)
                  if (widget.recipe.isFavorite &&
                      widget.recipe.mealType != MealType.any)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMealTypeIcon(widget.recipe.mealType),
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.recipe.mealType.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorite button
                  if (widget.showFavoriteButton)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: Consumer<AppState>(
                          builder: (context, appState, _) {
                            // Use consumer here to listen for changes to this specific recipe
                            final currentRecipe = appState.recipes.firstWhere(
                              (r) => r.id == widget.recipe.id,
                              orElse: () => widget.recipe,
                            );

                            return InkWell(
                              onTap: _isSaving
                                  ? null
                                  : () async {
                                      // Show saving indicator
                                      setState(() => _isSaving = true);

                                      // Toggle favorite status
                                      await appState
                                          .toggleFavorite(widget.recipe.id);

                                      // Hide saving indicator after a short delay
                                      // to show feedback to the user
                                      await Future.delayed(
                                        const Duration(milliseconds: 300),
                                      );

                                      if (mounted) {
                                        setState(() => _isSaving = false);
                                      }
                                    },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
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
                                        size: 20,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),

              // Recipe details
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: AppTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      widget.recipe.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${widget.recipe.preparationTime + widget.recipe.cookingTime} min',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${widget.recipe.calories} kcal',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.animate) {
      return card;
    }

    return card
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(
          begin: 0.2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
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
