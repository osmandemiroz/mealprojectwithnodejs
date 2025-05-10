// ignore_for_file: inference_failure_on_instance_creation, document_ignores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load recipes when the screen is first created
    Future.microtask(() {
      context.read<AppState>().loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToRecipeDetails(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const LoadingIndicator(
            message: 'Loading recipes...',
          );
        }

        if (appState.error != null) {
          return ErrorMessage(
            message: appState.error!,
            onRetry: () => appState.loadRecipes(),
          );
        }

        if (appState.recipes.isEmpty) {
          return const Center(
            child: Text(
              'No recipes found.\nTry adding some!',
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          );
        }

        // Use filteredRecipes instead of recipes directly
        final displayedRecipes = appState.filteredRecipes;
        final isEmptyResults =
            appState.recipes.isNotEmpty && displayedRecipes.isEmpty;

        return CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search recipes...',
                  leading: const Icon(Icons.search),
                  trailing: appState.searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              appState.setSearchQuery('');
                            },
                          ),
                        ]
                      : null,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                  ),
                  onChanged: (query) {
                    // Implement search functionality
                    appState.setSearchQuery(query);
                  },
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                  ),
                  children: [
                    _buildCategoryChip(
                      'All',
                      appState.selectedCategory == 'All',
                    ),
                    _buildCategoryChip(
                      'Breakfast',
                      appState.selectedCategory == 'Breakfast',
                    ),
                    _buildCategoryChip(
                      'Lunch',
                      appState.selectedCategory == 'Lunch',
                    ),
                    _buildCategoryChip(
                      'Dinner',
                      appState.selectedCategory == 'Dinner',
                    ),
                    _buildCategoryChip(
                      'Snacks',
                      appState.selectedCategory == 'Snacks',
                    ),
                    _buildCategoryChip(
                      'Desserts',
                      appState.selectedCategory == 'Desserts',
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.all(AppTheme.spacing8),
            ),

            // Show empty results message if needed
            if (isEmptyResults)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'No recipes found for "${appState.searchQuery}"',
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Recipe Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spacing16,
                    crossAxisSpacing: AppTheme.spacing16,
                    childAspectRatio: 0.73,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = displayedRecipes[index];
                      return Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: RecipeCard(
                          recipe: recipe,
                          onTap: () => _navigateToRecipeDetails(recipe),
                        ),
                      );
                    },
                    childCount: displayedRecipes.length,
                  ),
                ),
              ),

            const SliverPadding(
              padding: EdgeInsets.all(AppTheme.spacing16),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Implement category filtering
          if (selected) {
            context.read<AppState>().setSelectedCategory(label);
          }
        },
        backgroundColor: AppTheme.backgroundColor,
        selectedColor: AppTheme.primaryColor.withAlpha(26),
        labelStyle: AppTheme.bodyMedium.copyWith(
          color:
              isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
      ),
    );
  }
}
