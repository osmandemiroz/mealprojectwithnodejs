import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({
    required this.recipe,
    super.key,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surfaceColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe_image_${recipe.id}',
                child: CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
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
                    recipe.name,
                    style: AppTheme.displaySmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing8),

                  // Recipe Description
                  Text(
                    recipe.description,
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing16),

                  // Recipe Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.timer_outlined,
                          label: 'Prep Time',
                          value: '${recipe.preparationTime} min',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Calories',
                          value: '${recipe.calories} kcal',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.people_outline,
                          label: 'Servings',
                          value: '${recipe.servings}',
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

                  ...recipe.ingredients.map((ingredient) {
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

                  ...recipe.instructions.asMap().entries.map((entry) {
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

                  ...recipe.nutrients.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: AppTheme.bodyLarge,
                          ),
                          Text(
                            '${entry.value}g',
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
