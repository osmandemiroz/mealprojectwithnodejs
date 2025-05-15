// ignore_for_file: deprecated_member_use, avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/goal.dart';
import '../../models/progress.dart';
import '../../providers/app_state.dart';

/// A screen that displays detailed information about a goal
class GoalDetailScreen extends StatefulWidget {
  /// Constructs a GoalDetailScreen with the required goal
  const GoalDetailScreen({
    required this.goal,
    super.key,
  });

  /// The goal to display details for
  final Goal goal;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appState = Provider.of<AppState>(context);

    // Find progress for this goal
    final progress = appState.progressEntries
        .where((p) => p.goalId == widget.goal.id)
        .toList();

    // Get the current version of the goal from app state
    final currentGoal = appState.goals.firstWhere(
      (g) => g.id == widget.goal.id,
      orElse: () => widget.goal,
    );

    // Calculate days remaining
    final now = DateTime.now();
    final daysRemaining = currentGoal.endDate.difference(now).inDays;
    final isActive = currentGoal.endDate.isAfter(DateTime.now()) &&
        currentGoal.startDate.isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 150 + statusBarHeight,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: AppTheme.spacing16,
                right: AppTheme.spacing16,
                bottom: AppTheme.spacing16,
              ),
              title: Text(
                currentGoal.goalType,
                style: AppTheme.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      Color(0xFF5D8D9C), // Darker shade for depth
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppTheme.spacing16,
                      right: AppTheme.spacing16,
                      top: AppTheme.spacing48,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isActive ? 'Active Goal' : 'Completed Goal',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 16, top: statusBarHeight - 4),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
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
              // Edit button
              Padding(
                padding: EdgeInsets.only(right: 16, top: statusBarHeight - 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      _showEditGoalDialog(context, currentGoal);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Goal Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range and progress
                  _buildStatusCard(
                    context,
                    currentGoal,
                    daysRemaining,
                    progress.isNotEmpty ? progress.first : null,
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Nutrition Targets
                  Text(
                    'Daily Nutrition Targets',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing16),

                  // Calorie target
                  _buildNutritionCard(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: Colors.orange,
                    title: 'Calories',
                    value: '${currentGoal.targetCalories}',
                    unit: 'kcal',
                  ),

                  // Protein target
                  _buildNutritionCard(
                    icon: Icons.fitness_center_outlined,
                    iconColor: Colors.blue,
                    title: 'Protein',
                    value: '${currentGoal.targetProtein}',
                    unit: 'g',
                  ),

                  // Carbohydrates target
                  _buildNutritionCard(
                    icon: Icons.grain_outlined,
                    iconColor: Colors.amber,
                    title: 'Carbohydrates',
                    value: '${currentGoal.targetCarbs}',
                    unit: 'g',
                  ),

                  // Fat target
                  _buildNutritionCard(
                    icon: Icons.opacity_outlined,
                    iconColor: Colors.deepPurple,
                    title: 'Fat',
                    value: '${currentGoal.targetFat}',
                    unit: 'g',
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Goal Details Section
                  Text(
                    'Goal Details',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: AppTheme.spacing16),

                  // Activity level
                  if (currentGoal.activityStatusPerDay != null)
                    _buildDetailItem(
                      icon: Icons.directions_run_outlined,
                      iconColor: Colors.green,
                      title: 'Activity Level',
                      value: currentGoal.activityStatusPerDay!,
                    ),

                  // Number of meals
                  if (currentGoal.numberOfMealsPerDay != null)
                    _buildDetailItem(
                      icon: Icons.restaurant_outlined,
                      iconColor: Colors.red,
                      title: 'Meals Per Day',
                      value: '${currentGoal.numberOfMealsPerDay}',
                    ),

                  // Start weight
                  if (currentGoal.startWeight != null)
                    _buildDetailItem(
                      icon: Icons.scale_outlined,
                      iconColor: Colors.blueGrey,
                      title: 'Start Weight',
                      value: '${currentGoal.startWeight} kg',
                    ),

                  // Target weight
                  if (currentGoal.desiredWeight != null)
                    _buildDetailItem(
                      icon: Icons.flag_outlined,
                      iconColor: Colors.teal,
                      title: 'Target Weight',
                      value: '${currentGoal.desiredWeight} kg',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    Goal goal,
    int daysRemaining,
    Progress? progress,
  ) {
    final startDateStr = DateFormat('MMM d, yyyy').format(goal.startDate);
    final endDateStr = DateFormat('MMM d, yyyy').format(goal.endDate);
    final isActive = goal.endDate.isAfter(DateTime.now()) &&
        goal.startDate.isBefore(DateTime.now());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(
          color: isActive
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duration',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
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
                    isActive ? 'Active' : 'Completed',
                    style: AppTheme.bodySmall.copyWith(
                      color: isActive
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              '$startDateStr to $endDateStr',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Days remaining or completed
            Row(
              children: [
                Icon(
                  isActive ? Icons.calendar_today : Icons.check_circle_outline,
                  size: 20,
                  color:
                      isActive ? AppTheme.primaryColor : AppTheme.successColor,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  isActive ? '$daysRemaining days remaining' : 'Completed',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacing16),

            // Progress
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
                      '${((progress?.progressPercentage ?? 0.0) * 100).toStringAsFixed(0)}%',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                LinearProgressIndicator(
                  value: progress?.progressPercentage ?? 0.0,
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
    ).animate().fadeIn().slideY();
  }

  Widget _buildNutritionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '$value $unit',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}

// Adapter to use the existing edit goal dialog
void _showEditGoalDialog(BuildContext context, Goal goal) {
  // Navigate back to goal screen to use edit dialog
  Navigator.pop(context);

  // We need a delayed execution to ensure the GoalScreen's context is used
  Future.delayed(const Duration(milliseconds: 100), () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal'),
        content: const Text(
          'Please use the edit option on the main Goal screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  });
}
