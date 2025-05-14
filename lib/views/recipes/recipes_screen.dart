// ignore_for_file: inference_failure_on_instance_creation, document_ignores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/recipe_filter_panel.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  int _currentTabIndex = 0;
  final List<Tab> _tabs = [
    const Tab(text: 'All Recipes'),
    const Tab(text: 'Favorites'),
    const Tab(text: 'Breakfast'),
    const Tab(text: 'Lunch'),
    const Tab(text: 'Dinner'),
    const Tab(text: 'Snacks'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load recipes when the screen is first created
    Future.microtask(() {
      context.read<AppState>().loadRecipes();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _currentTabIndex != _tabController.index) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _updateFilters();
      });
    }
  }

  void _updateFilters() {
    final appState = context.read<AppState>();

    // Reset search and category filters
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      appState.setSearchQuery('');
    }

    if (appState.selectedCategory != 'All') {
      appState.setSelectedCategory('All');
    }

    // Set favorite and meal type filters based on tab
    switch (_currentTabIndex) {
      case 0: // All Recipes
        appState.setShowOnlyFavorites(false);
        appState.setMealTypeFilter(MealType.any);
      case 1: // Favorites
        appState.setShowOnlyFavorites(true);
        appState.setMealTypeFilter(MealType.any);
      case 2: // Breakfast
        appState.setShowOnlyFavorites(true);
        appState.setMealTypeFilter(MealType.breakfast);
      case 3: // Lunch
        appState.setShowOnlyFavorites(true);
        appState.setMealTypeFilter(MealType.lunch);
      case 4: // Dinner
        appState.setShowOnlyFavorites(true);
        appState.setMealTypeFilter(MealType.dinner);
      case 5: // Snacks
        appState.setShowOnlyFavorites(true);
        appState.setMealTypeFilter(MealType.snack);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
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

        // Show appropriate empty state message
        var emptyStateMessage = '';
        var emptyStateIcon = Icons.search_off;

        if (isEmptyResults) {
          if (_currentTabIndex == 0) {
            // All recipes tab with search or category filter applied
            if (appState.searchQuery.isNotEmpty) {
              emptyStateMessage =
                  'No recipes found for "${appState.searchQuery}"';
              emptyStateIcon = Icons.search_off;
            } else if (appState.selectedCategory != 'All') {
              emptyStateMessage =
                  'No recipes found in ${appState.selectedCategory} category';
              emptyStateIcon = Icons.category;
            } else if (appState.advancedFiltersActive) {
              emptyStateMessage = 'No recipes match the current filters';
              emptyStateIcon = Icons.filter_list_off;
            }
          } else if (_currentTabIndex == 1) {
            // Favorites tab
            emptyStateMessage =
                'No favorite recipes yet.\nTap the heart icon on any recipe to add it to your favorites.';
            emptyStateIcon = Icons.favorite_border;
          } else {
            // Meal type tabs
            emptyStateMessage =
                'No favorite ${_getMealTypeName(_currentTabIndex)} recipes yet';
            emptyStateIcon = _getMealTypeIcon(_currentTabIndex);
          }
        }

        return Column(
          children: [
            // Tab Bar
            Material(
              color: AppTheme.surfaceColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondaryColor,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Only show search, filters and advanced filter panel in the "All Recipes" tab
                  if (_currentTabIndex == 0) ...[
                    // Search and Filter Controls Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        child: Row(
                          children: [
                            // Search Bar
                            Expanded(
                              child: SearchBar(
                                controller: _searchController,
                                hintText: 'Search recipes...',
                                hintStyle: WidgetStateProperty.all(
                                  AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                textStyle: WidgetStateProperty.all(
                                  AppTheme.bodyLarge,
                                ),
                                leading: const Icon(
                                  Icons.search,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                trailing: appState.searchQuery.isNotEmpty
                                    ? [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            color: AppTheme.textSecondaryColor,
                                          ),
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
                                elevation:
                                    WidgetStateProperty.all(0), // Remove shadow
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ), // Transparent background
                                shadowColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ), // Remove shadow
                                surfaceTintColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ), // Remove tint
                                side: WidgetStateProperty.all(
                                  BorderSide.none, // Remove border
                                ),
                                onChanged: (query) {
                                  // Implement search functionality
                                  appState.setSearchQuery(query);
                                },
                              ),
                            ),

                            // Advanced Filter Toggle Button
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppTheme.spacing8,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: appState.advancedFiltersActive
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusMedium,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        color: appState.advancedFiltersActive
                                            ? Colors.white
                                            : AppTheme.textSecondaryColor,
                                      ),
                                      if (_hasActiveFilters(appState))
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  tooltip: 'Advanced Filters',
                                  onPressed: () {
                                    appState.toggleAdvancedFilters();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Advanced Filters Panel
                    const SliverToBoxAdapter(
                      child: RecipeFilterPanel(),
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
                              'breakfast-and-brunch',
                              appState.selectedCategory ==
                                  'breakfast-and-brunch',
                            ),
                            _buildCategoryChip(
                              'appetizers-and-snacks',
                              appState.selectedCategory ==
                                  'appetizers-and-snacks',
                            ),
                            _buildCategoryChip(
                              'desserts',
                              appState.selectedCategory == 'desserts',
                            ),
                            _buildCategoryChip(
                              'side-dish',
                              appState.selectedCategory == 'side-dish',
                            ),
                            _buildCategoryChip(
                              'meat-and-poultry',
                              appState.selectedCategory == 'meat-and-poultry',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverPadding(
                      padding: EdgeInsets.all(AppTheme.spacing8),
                    ),
                  ],

                  // Show empty results message if needed
                  if (isEmptyResults)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                emptyStateIcon,
                                size: 48,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                emptyStateMessage,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
              ),
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
        selected: isSelected,
        label: Text(_formatCategoryName(label)),
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        onSelected: (selected) {
          context
              .read<AppState>()
              .setSelectedCategory(selected ? label : 'All');
        },
      ),
    );
  }

  String _formatCategoryName(String name) {
    return name
        .split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  // Helper for getting meal type name based on tab index
  String _getMealTypeName(int tabIndex) {
    switch (tabIndex) {
      case 2:
        return 'breakfast';
      case 3:
        return 'lunch';
      case 4:
        return 'dinner';
      case 5:
        return 'snack';
      default:
        return '';
    }
  }

  // Helper for getting meal type icon based on tab index
  IconData _getMealTypeIcon(int tabIndex) {
    switch (tabIndex) {
      case 2:
        return Icons.wb_sunny;
      case 3:
        return Icons.wb_cloudy;
      case 4:
        return Icons.nights_stay;
      case 5:
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  // Helper to check if any advanced filters are active
  bool _hasActiveFilters(AppState appState) {
    return appState.caloriesFilterActive ||
        appState.prepTimeFilterActive ||
        appState.proteinFilterActive ||
        appState.carbsFilterActive ||
        appState.fatFilterActive;
  }
}
