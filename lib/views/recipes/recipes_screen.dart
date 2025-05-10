import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../models/recipe.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  void initState() {
    super.initState();
    // Load recipes when the screen is first created
    Future.microtask(() {
      context.read<AppState>().loadRecipes();
    });
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

        return CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: SearchBar(
                  hintText: 'Search recipes...',
                  leading: const Icon(Icons.search),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                  ),
                  onChanged: (query) {
                    // TODO: Implement search
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
                    _buildCategoryChip('All', true),
                    _buildCategoryChip('Breakfast', false),
                    _buildCategoryChip('Lunch', false),
                    _buildCategoryChip('Dinner', false),
                    _buildCategoryChip('Snacks', false),
                    _buildCategoryChip('Desserts', false),
                  ],
                ),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.all(AppTheme.spacing8),
            ),

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
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = appState.recipes[index];
                    return Hero(
                      tag: 'recipe_image_${recipe.id}',
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () => _navigateToRecipeDetails(recipe),
                      ),
                    );
                  },
                  childCount: appState.recipes.length,
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
          // TODO: Implement category filtering
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
