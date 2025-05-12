import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/goal.dart';
import '../../models/progress.dart';
import '../../providers/app_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppState>().loadGoals();
      context.read<AppState>().loadProgressEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const LoadingIndicator(
            message: 'Loading goals...',
          );
        }

        if (appState.error != null) {
          return ErrorMessage(
            message: appState.error!,
            onRetry: () {
              appState.loadGoals();
              appState.loadProgressEntries();
            },
          );
        }

        if (appState.goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'No Goals Set',
                  style: AppTheme.displaySmall.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Create a new goal to track your nutrition progress',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing24),
                FilledButton.icon(
                  onPressed: () => _showAddGoalDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Goal'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Current Weekly Stats Section
            SliverToBoxAdapter(
              child: _WeeklyStatsSummary(
                goals: appState.goals,
                progressEntries: appState.progressEntries,
              ).animate().fadeIn().slideY(),
            ),

            // Active Goals Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing16,
                  AppTheme.spacing24,
                  AppTheme.spacing16,
                  AppTheme.spacing8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Goals',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddGoalDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),

            // Goal Cards List
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = appState.goals[index];
                    // Find progress for this goal
                    final progress = appState.progressEntries
                        .where((p) => p.goalId == goal.id)
                        .toList();

                    return _GoalCard(
                      goal: goal,
                      progress: progress.isNotEmpty ? progress.first : null,
                    ).animate().fadeIn().slideX();
                  },
                  childCount: appState.goals.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    // TODO: Implement add goal dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content:
            const Text('Goal creation will be implemented in a future update'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStatsSummary extends StatelessWidget {
  const _WeeklyStatsSummary({
    required this.goals,
    required this.progressEntries,
  });

  final List<Goal> goals;
  final List<Progress> progressEntries;

  @override
  Widget build(BuildContext context) {
    // Get the active goal with the most recent progress entry
    Goal? activeGoal;
    Progress? latestProgress;

    if (goals.isNotEmpty) {
      activeGoal = goals.first;

      if (progressEntries.isNotEmpty) {
        progressEntries
            .sort((a, b) => b.lastUpdatedDate.compareTo(a.lastUpdatedDate));
        latestProgress = progressEntries.first;
      }
    }

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
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
            'Weekly Summary',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            activeGoal != null
                ? 'Goal: ${activeGoal.goalType}'
                : 'No active goal',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Calorie stats
          Row(
            children: [
              Expanded(
                child: _NutritionStatItem(
                  icon: Icons.local_fire_department,
                  title: 'Daily Calories',
                  value: activeGoal?.targetCalories.toString() ?? 'N/A',
                  unit: 'kcal',
                  progress: 0.7, // Mock progress value
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: _NutritionStatItem(
                  icon: Icons.fitness_center,
                  title: 'Protein',
                  value: activeGoal?.targetProtein.toString() ?? 'N/A',
                  unit: 'g',
                  progress: 0.65, // Mock progress value
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            children: [
              Expanded(
                child: _NutritionStatItem(
                  icon: Icons.grain,
                  title: 'Carbs',
                  value: activeGoal?.targetCarbs.toString() ?? 'N/A',
                  unit: 'g',
                  progress: 0.8, // Mock progress value
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: _NutritionStatItem(
                  icon: Icons.opacity,
                  title: 'Fat',
                  value: activeGoal?.targetFat.toString() ?? 'N/A',
                  unit: 'g',
                  progress: 0.5, // Mock progress value
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing16),
          // Weight progress if available
          if (latestProgress != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Weight: ${latestProgress.currentWeight.toStringAsFixed(1)} kg',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (activeGoal?.desiredWeight != null)
                  Text(
                    ' / Goal: ${activeGoal!.desiredWeight!.toStringAsFixed(1)} kg',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NutritionStatItem extends StatelessWidget {
  const _NutritionStatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: AppTheme.spacing4),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing4),
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
        const SizedBox(height: AppTheme.spacing8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    this.progress,
  });

  final Goal goal;
  final Progress? progress;

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.endDate.difference(DateTime.now()).inDays;
    final isActive = goal.endDate.isAfter(DateTime.now());

    final dateFormat = DateFormat('MMM d, yyyy');
    final startDateStr = dateFormat.format(goal.startDate);
    final endDateStr = dateFormat.format(goal.endDate);

    // Calculate progress percentage
    final progressPercent = progress?.progressPercentage ?? 0.0;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to goal details
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.goalType,
                          style: AppTheme.displaySmall.copyWith(
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '$startDateStr to $endDateStr',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      isActive ? '$daysLeft days left' : 'Completed',
                      style: AppTheme.bodySmall.copyWith(
                        color: isActive ? AppTheme.primaryColor : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Nutrition targets
              Row(
                children: [
                  _GoalNutritionTarget(
                    icon: Icons.local_fire_department,
                    value: '${goal.targetCalories}',
                    label: 'kcal',
                  ),
                  _GoalNutritionTarget(
                    icon: Icons.fitness_center,
                    value: '${goal.targetProtein}g',
                    label: 'protein',
                  ),
                  _GoalNutritionTarget(
                    icon: Icons.grain,
                    value: '${goal.targetCarbs}g',
                    label: 'carbs',
                  ),
                  _GoalNutritionTarget(
                    icon: Icons.opacity,
                    value: '${goal.targetFat}g',
                    label: 'fat',
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacing16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(0)}%',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalNutritionTarget extends StatelessWidget {
  const _GoalNutritionTarget({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
