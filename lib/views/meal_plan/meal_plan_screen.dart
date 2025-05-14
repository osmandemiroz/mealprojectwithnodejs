import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen>
    with AutomaticKeepAliveClientMixin {
  late DateTime _selectedDate;
  late PageController _pageController;
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _didInitialLoad = false;

  // Store selected meals for each meal type
  final Map<String, Recipe?> _selectedMeals = {
    'Breakfast': null,
    'Lunch': null,
    'Dinner': null,
    'Snacks': null,
  };

  // Daily nutrition totals
  int _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data the first time the widget is inserted into the tree
    // or when dependencies change (e.g., after navigation)
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      _loadData(showLoading: true);
    }
  }

  // Force reload data when this screen becomes visible again
  void reloadData() {
    if (mounted) {
      _loadData();
    }
  }

  /// Load all required data including recipes and meal plans
  Future<void> _loadData({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // First load recipes which are needed for meal plans
      final appState = context.read<AppState>();

      // Always reload meal data when this method is called
      try {
        await _loadMealsForSelectedDate();
      } catch (e) {
        print('[MealPlanScreen] Error loading meals: $e');
      }

      // Check if we need to load recipes (if they're empty)
      if (appState.recipes.isEmpty) {
        try {
          await appState.loadRecipes();
          // After loading recipes, reload meal data again in case it depends on recipes
          await _loadMealsForSelectedDate();
        } catch (e) {
          print('[MealPlanScreen] Error loading recipes: $e');
          // Continue anyway with what we have
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[MealPlanScreen] Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load meal plan data. Please try again.';
        });
      }
    }
  }

  /// Load meals for the selected date from storage
  Future<void> _loadMealsForSelectedDate() async {
    try {
      final mealPlanData =
          await _storageService.loadDailyMealPlan(_selectedDate);
      final recipes = context.read<AppState>().recipes;

      // Reset meal selections
      final updatedMeals = <String, Recipe?>{
        'Breakfast': null,
        'Lunch': null,
        'Dinner': null,
        'Snacks': null,
      };

      if (mealPlanData != null && recipes.isNotEmpty) {
        // Reconstruct Recipe objects from stored data
        mealPlanData.forEach((mealType, mealData) {
          final recipeId = mealData['recipeId']?.toString();
          if (recipeId != null) {
            // Find the recipe in the app state
            final matchingRecipes =
                recipes.where((r) => r.id == recipeId).toList();
            if (matchingRecipes.isNotEmpty) {
              updatedMeals[mealType] = matchingRecipes.first;
            } else {
              // If recipe not found in app state, create a temporary one from stored data
              updatedMeals[mealType] = Recipe(
                id: recipeId,
                name: mealData['name']?.toString() ?? 'Unknown Recipe',
                description: '',
                imageUrl: mealData['imageUrl']?.toString() ?? '',
                preparationTime: 0,
                cookingTime: 0,
                servings: 0,
                ingredients: [],
                instructions: [],
                categories: [],
                calories:
                    int.tryParse(mealData['calories']?.toString() ?? '0') ?? 0,
                nutrients: {},
              );
            }
          }
        });
      }

      if (mounted) {
        setState(() {
          _selectedMeals.clear();
          _selectedMeals.addAll(updatedMeals);
          _calculateDailyNutritionTotals();
        });
      }
    } catch (e) {
      print('[MealPlanScreen] Error loading meals for date: $e');
      // Don't show error to user, just log it
    }
  }

  /// Save current meal selections for the selected date
  Future<void> _saveMealsForSelectedDate() async {
    final mealPlanData = <String, Map<String, dynamic>>{};

    _selectedMeals.forEach((mealType, recipe) {
      if (recipe != null) {
        mealPlanData[mealType] = {
          'recipeId': recipe.id,
          'name': recipe.name,
          'calories': recipe.calories,
        };
      }
    });

    await _storageService.saveDailyMealPlan(_selectedDate, mealPlanData);
  }

  void _calculateDailyNutritionTotals() {
    _totalCalories = 0;
    _totalProtein = 0;
    _totalCarbs = 0;
    _totalFat = 0;

    _selectedMeals.forEach((mealType, recipe) {
      if (recipe != null) {
        _totalCalories += recipe.calories;
        _totalProtein += recipe.nutrients['protein'] ?? 0;
        _totalCarbs += recipe.nutrients['carbohydrates'] ?? 0;
        _totalFat += recipe.nutrients['fat'] ?? 0;
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    // Always try to reload when visible - this ensures data is fresh after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        // Only reload if we're coming back from another screen (e.g. recipe details)
        reloadData();
      }
    });

    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (_isLoading) {
          return const LoadingIndicator(
            message: 'Loading meal plans...',
          );
        }

        if (_errorMessage != null) {
          return ErrorMessage(
            message: _errorMessage!,
            onRetry: () {
              _loadData(showLoading: true);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadData();
          },
          child: CustomScrollView(
            slivers: [
              // Calendar Strip
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  margin:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  child: FutureBuilder<List<DateTime>>(
                      future: _storageService.getSavedMealPlanDates(),
                      builder: (context, snapshot) {
                        final savedDates = snapshot.data ?? [];

                        return PageView.builder(
                          controller: _pageController,
                          itemBuilder: (context, weekIndex) {
                            final weekStart = DateTime.now().add(
                              Duration(
                                days:
                                    weekIndex * 7 - DateTime.now().weekday + 1,
                              ),
                            );
                            return _buildWeekCalendar(weekStart, savedDates);
                          },
                        );
                      }),
                ),
              ),

              // Daily Nutrition Summary
              SliverToBoxAdapter(
                child: _buildDailyNutritionSummary(),
              ),

              // Today's Meals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(_selectedDate),
                        style: AppTheme.displaySmall,
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        DateUtils.isSameDay(_selectedDate, DateTime.now())
                            ? "Today's Meals"
                            : "Meals for ${DateFormat('MMMM d').format(_selectedDate)}",
                        style: AppTheme.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      _buildMealSection('Breakfast', Icons.wb_sunny, appState),
                      _buildMealSection('Lunch', Icons.wb_cloudy, appState),
                      _buildMealSection('Dinner', Icons.nights_stay, appState),
                      _buildMealSection('Snacks', Icons.cookie, appState),
                    ],
                  ),
                ),
              ),

              // Instructions to pull-to-refresh
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing24),
                    child: Text(
                      'Pull down to refresh meal plan',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyNutritionSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            Color(0xFF5D8D9C), // Darker shade for depth
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nutrition',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Nutrition stats
          Row(
            children: [
              Expanded(
                child: _buildNutrientStat(
                  'Calories',
                  _totalCalories.toString(),
                  'kcal',
                  Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _buildNutrientStat(
                  'Protein',
                  _totalProtein.toStringAsFixed(1),
                  'g',
                  Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildNutrientStat(
                  'Carbs',
                  _totalCarbs.toStringAsFixed(1),
                  'g',
                  Icons.grain,
                ),
              ),
              Expanded(
                child: _buildNutrientStat(
                  'Fat',
                  _totalFat.toStringAsFixed(1),
                  'g',
                  Icons.opacity,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildNutrientStat(
      String label, String value, String unit, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: AppTheme.spacing8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: AppTheme.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' $unit',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(DateTime weekStart, List<DateTime> savedDates) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = weekStart.add(Duration(days: index));
        final isSelected = DateUtils.isSameDay(date, _selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());
        final hasSavedMealPlan =
            savedDates.any((savedDate) => DateUtils.isSameDay(savedDate, date));

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
            // Load meals for the newly selected date
            _loadMealsForSelectedDate();
          },
          child: Container(
            width: 54,
            margin: const EdgeInsets.only(right: AppTheme.spacing8),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: isToday ? Border.all(color: AppTheme.primaryColor) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 1),
                  style: AppTheme.bodyMedium.copyWith(
                    color:
                        isSelected ? Colors.white : AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  date.day.toString(),
                  style: AppTheme.displaySmall.copyWith(
                    color:
                        isSelected ? Colors.white : AppTheme.textPrimaryColor,
                  ),
                ),
                if (hasSavedMealPlan)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, IconData icon, AppState appState) {
    // Get the selected recipe for this meal type, if any
    final selectedRecipe = _selectedMeals[title];

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
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
          onTap: () => _showMealSelectionDialog(title, appState),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.displaySmall.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      if (selectedRecipe != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedRecipe.name,
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              '${selectedRecipe.calories} kcal',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Tap to add a meal',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selectedRecipe != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade300,
                    onPressed: () {
                      setState(() {
                        _selectedMeals[title] = null;
                        _calculateDailyNutritionTotals();
                        // Save the updated meal plan
                        _saveMealsForSelectedDate();
                      });
                    },
                  )
                else
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  void _showMealSelectionDialog(String mealType, AppState appState) {
    // Filter recipes based on meal type
    final List<Recipe> filteredRecipes = appState.recipes.where((recipe) {
      // Use categories or recipe name to suggest appropriate meals
      switch (mealType.toLowerCase()) {
        case 'breakfast':
          return recipe.categories.any((category) =>
                  category.toLowerCase().contains('breakfast') ||
                  category.toLowerCase().contains('morning')) ||
              recipe.name.toLowerCase().contains('breakfast') ||
              recipe.name.toLowerCase().contains('pancake') ||
              recipe.name.toLowerCase().contains('cereal') ||
              recipe.name.toLowerCase().contains('eggs') ||
              recipe.name.toLowerCase().contains('toast') ||
              recipe.name.toLowerCase().contains('oatmeal') ||
              recipe.name.toLowerCase().contains('smoothie');
        case 'lunch':
          return recipe.categories.any((category) =>
                  category.toLowerCase().contains('lunch') ||
                  category.toLowerCase().contains('salad') ||
                  category.toLowerCase().contains('sandwich')) ||
              recipe.name.toLowerCase().contains('lunch') ||
              recipe.name.toLowerCase().contains('salad') ||
              recipe.name.toLowerCase().contains('sandwich') ||
              recipe.name.toLowerCase().contains('soup') ||
              recipe.name.toLowerCase().contains('wrap');
        case 'dinner':
          return recipe.categories.any((category) =>
                  category.toLowerCase().contains('dinner') ||
                  category.toLowerCase().contains('main dish') ||
                  category.toLowerCase().contains('entrée')) ||
              recipe.name.toLowerCase().contains('dinner') ||
              recipe.name.toLowerCase().contains('steak') ||
              recipe.name.toLowerCase().contains('pasta') ||
              recipe.name.toLowerCase().contains('curry') ||
              recipe.name.toLowerCase().contains('roast');
        case 'snacks':
          return recipe.categories.any((category) =>
                  category.toLowerCase().contains('snack') ||
                  category.toLowerCase().contains('appetizer')) ||
              recipe.name.toLowerCase().contains('snack') ||
              recipe.name.toLowerCase().contains('chips') ||
              recipe.name.toLowerCase().contains('nuts') ||
              recipe.name.toLowerCase().contains('fruit') ||
              recipe.name.toLowerCase().contains('yogurt');
        default:
          return true; // Show all recipes if meal type is unknown
      }
    }).toList();

    // Show "All Recipes" option if filtered list is too restrictive
    final bool showAllOption =
        filteredRecipes.length < appState.recipes.length * 0.3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        // Track if we're showing all recipes or filtered ones
        bool showingAll = false;
        List<Recipe> displayedRecipes =
            showingAll ? appState.recipes : filteredRecipes;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusLarge),
              topRight: Radius.circular(AppTheme.borderRadiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacing8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title and filter toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select $mealType',
                            style: AppTheme.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showAllOption)
                            Text(
                              showingAll
                                  ? 'Showing all recipes'
                                  : 'Showing suggested recipes for $mealType',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (showAllOption)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            showingAll = !showingAll;
                            displayedRecipes =
                                showingAll ? appState.recipes : filteredRecipes;
                          });
                        },
                        icon: Icon(
                          showingAll
                              ? Icons.filter_list
                              : Icons.filter_list_off,
                          size: 18,
                        ),
                        label: Text(showingAll ? 'Show Suggested' : 'Show All'),
                      ),
                  ],
                ),
              ),

              // Recipes list
              Expanded(
                child: displayedRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              'No Recipes Available',
                              style: AppTheme.displaySmall.copyWith(
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              showingAll
                                  ? 'Add recipes to select for your meals'
                                  : 'No suggested recipes found for $mealType',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!showingAll && showAllOption)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: AppTheme.spacing16),
                                child: FilledButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      showingAll = true;
                                      displayedRecipes = appState.recipes;
                                    });
                                  },
                                  icon: const Icon(Icons.all_inclusive),
                                  label: const Text('Show All Recipes'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        itemCount: displayedRecipes.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: AppTheme.spacing12,
                        ),
                        itemBuilder: (context, index) {
                          final recipe = displayedRecipes[index];

                          // Add a "Recommended" badge for top suggested recipes
                          final isRecommended = !showingAll &&
                              filteredRecipes.indexOf(recipe) < 3 &&
                              displayedRecipes.length > 5;

                          return _RecipeListItem(
                            recipe: recipe,
                            onTap: () {
                              this.setState(() {
                                _selectedMeals[mealType] = recipe;
                                _calculateDailyNutritionTotals();
                                // Save the updated meal plan
                                _saveMealsForSelectedDate();
                              });
                              Navigator.pop(context);
                            },
                            isRecommended: isRecommended,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _RecipeListItem extends StatelessWidget {
  const _RecipeListItem({
    required this.recipe,
    required this.onTap,
    this.isRecommended = false,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: Row(
            children: [
              // Recipe image
              Stack(
                children: [
                  if (recipe.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                      child: Image.network(
                        recipe.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  if (isRecommended)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft:
                                Radius.circular(AppTheme.borderRadiusSmall),
                            bottomRight:
                                Radius.circular(AppTheme.borderRadiusSmall),
                          ),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacing12),
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      recipe.description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    // Nutrition quick info
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${recipe.calories} kcal',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${recipe.preparationTime + recipe.cookingTime} min',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add button
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryColor,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
