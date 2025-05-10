import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/meal_plan.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late DateTime _selectedDate;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: 0);
    Future.microtask(() {
      context.read<AppState>().loadMealPlans();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const LoadingIndicator(
            message: 'Loading meal plans...',
          );
        }

        if (appState.error != null) {
          return ErrorMessage(
            message: appState.error!,
            onRetry: () => appState.loadMealPlans(),
          );
        }

        if (appState.mealPlans.isEmpty) {
          return Center(
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
                  'No Meal Plans',
                  style: AppTheme.displaySmall.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Create a new meal plan to get started',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing24),
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Implement create meal plan
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Meal Plan'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Calendar Strip
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, weekIndex) {
                    final weekStart = DateTime.now().add(
                      Duration(
                          days: weekIndex * 7 - DateTime.now().weekday + 1),
                    );
                    return _buildWeekCalendar(weekStart);
                  },
                ),
              ),
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
                    const SizedBox(height: AppTheme.spacing24),
                    _buildMealSection('Breakfast', Icons.wb_sunny),
                    _buildMealSection('Lunch', Icons.wb_cloudy),
                    _buildMealSection('Dinner', Icons.nights_stay),
                    _buildMealSection('Snacks', Icons.cookie),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekCalendar(DateTime weekStart) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = weekStart.add(Duration(days: index));
        final isSelected = DateUtils.isSameDay(date, _selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, IconData icon) {
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
          onTap: () {
            // TODO: Navigate to meal selection
          },
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
                      Text(
                        'Tap to add a meal',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
