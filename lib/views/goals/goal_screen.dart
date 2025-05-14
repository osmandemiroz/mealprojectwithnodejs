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
    // Load goals on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadGoals();
      appState.loadActiveGoals();
      appState.loadCompletedGoals();
      appState.loadProgressEntries();
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
              appState.loadActiveGoals();
              appState.loadCompletedGoals();
              appState.loadProgressEntries();
            },
          );
        }

        // Show empty state only when there are no goals
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
            // Only show Weekly Stats Summary if there's an active goal
            if (appState.goals.any((goal) =>
                goal.endDate.isAfter(DateTime.now()) &&
                goal.startDate.isBefore(DateTime.now())))
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
                    // Only show the Add button if there are no goals
                    if (appState.goals.isEmpty)
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
    // Check if there's already a goal
    final appState = context.read<AppState>();
    final hasActiveGoal = appState.goals.any((goal) =>
        goal.endDate.isAfter(DateTime.now()) &&
        goal.startDate.isBefore(DateTime.now()));

    if (hasActiveGoal) {
      // Show a message that only one active goal is allowed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only have one active goal at a time'),
        ),
      );
      return;
    }

    _showCreateGoalModal(context);
  }

  void _showCreateGoalModal(BuildContext context) {
    // Initialize variables for the modal
    String goalType = 'Weight Loss';
    DateTime? startDate;
    DateTime? endDate;
    String activityStatusPerDay = 'Moderate';
    int numberOfMealsPerDay = 3;
    int targetCalories = 2000;
    int targetProtein = 120;
    int targetCarbs = 200;
    int targetFat = 65;

    // Text controllers
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController startWeightController = TextEditingController();
    final TextEditingController desiredWeightController =
        TextEditingController();

    // Form key
    final formKey = GlobalKey<FormState>();

    // Define activity status options
    final List<String> activityOptions = [
      'Sedentary',
      'Light',
      'Moderate',
      'Active',
      'Very Active'
    ];

    // Define goal type options
    final List<String> goalTypeOptions = [
      'Weight Loss',
      'Weight Gain',
      'Muscle Building',
      'Maintenance'
    ];

    // Show full-screen bottom sheet for better UX
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
          // Custom select date function that uses the modal's setState
          Future<void> _selectDate(
              BuildContext context, bool isStartDate) async {
            final initialDate = isStartDate
                ? DateTime.now()
                : (startDate?.add(const Duration(days: 30)) ??
                    DateTime.now().add(const Duration(days: 30)));
            final firstDate = isStartDate
                ? DateTime.now().subtract(const Duration(days: 1))
                : (startDate ?? DateTime.now());
            final lastDate = isStartDate
                ? DateTime.now().add(const Duration(days: 365))
                : DateTime.now().add(const Duration(days: 730));

            final pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppTheme.textPrimaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              setModalState(() {
                if (isStartDate) {
                  startDate = pickedDate;
                  startDateController.text =
                      DateFormat('MMM d, yyyy').format(pickedDate);
                } else {
                  endDate = pickedDate;
                  endDateController.text =
                      DateFormat('MMM d, yyyy').format(pickedDate);
                }
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle and title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create New Goal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Goal Type Section
                          const Text(
                            'Goal Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                isCollapsed: false,
                              ),
                              value: goalType,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              items: goalTypeOptions.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    goalType = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Date Section
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Start Date
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await _selectDate(context, true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Start Date',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                startDateController.text.isEmpty
                                                    ? 'Select date'
                                                    : startDateController.text,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: startDateController
                                                          .text.isEmpty
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // End Date
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await _selectDate(context, false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'End Date',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                endDateController.text.isEmpty
                                                    ? 'Select date'
                                                    : endDateController.text,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: endDateController
                                                          .text.isEmpty
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (startDate != null &&
                              endDate != null &&
                              !endDate!.isAfter(startDate!))
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'End date must be after start date',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Weight Information (conditional)
                          if (goalType == 'Weight Loss' ||
                              goalType == 'Weight Gain') ...[
                            const Text(
                              'Weight Goals',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Current Weight
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextFormField(
                                      controller: startWeightController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Current Weight',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                        suffixText: 'kg',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        border: InputBorder.none,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Invalid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Target Weight
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextFormField(
                                      controller: desiredWeightController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Target Weight',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                        suffixText: 'kg',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        border: InputBorder.none,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Invalid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Activity Level
                          const Text(
                            'Activity Level',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              value: activityStatusPerDay,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              items: activityOptions.map((String activity) {
                                return DropdownMenuItem<String>(
                                  value: activity,
                                  child: Text(activity),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    activityStatusPerDay = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Meals Per Day
                          const Text(
                            'Meals Per Day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              value: numberOfMealsPerDay,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              items: [3, 4, 5, 6].map((int number) {
                                return DropdownMenuItem<int>(
                                  value: number,
                                  child: Text(number.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    numberOfMealsPerDay = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nutrition Goals Section
                          const Text(
                            'Daily Nutrition Goals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Calories
                          _NutritionSliderCard(
                            icon: Icons.local_fire_department,
                            iconColor: Colors.orange,
                            title: 'Calories',
                            value: targetCalories.toDouble(),
                            min: 1200.0,
                            max: 3000.0,
                            unit: 'kcal',
                            onChanged: (value) {
                              setModalState(() {
                                targetCalories = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Protein
                          _NutritionSliderCard(
                            icon: Icons.fitness_center,
                            iconColor: Colors.blue,
                            title: 'Protein',
                            value: targetProtein.toDouble(),
                            min: 50.0,
                            max: 250.0,
                            unit: 'g',
                            onChanged: (value) {
                              setModalState(() {
                                targetProtein = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Carbs
                          _NutritionSliderCard(
                            icon: Icons.grain,
                            iconColor: Colors.amber,
                            title: 'Carbohydrates',
                            value: targetCarbs.toDouble(),
                            min: 50.0,
                            max: 400.0,
                            unit: 'g',
                            onChanged: (value) {
                              setModalState(() {
                                targetCarbs = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Fat
                          _NutritionSliderCard(
                            icon: Icons.opacity,
                            iconColor: Colors.deepPurple,
                            title: 'Fat',
                            value: targetFat.toDouble(),
                            min: 20.0,
                            max: 150.0,
                            unit: 'g',
                            onChanged: (value) {
                              setModalState(() {
                                targetFat = value.round();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom action buttons
                Container(
                  padding: EdgeInsets.fromLTRB(
                      24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            // Validate form
                            if (formKey.currentState?.validate() ?? false) {
                              // Validate dates
                              if (startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please select a start date')),
                                );
                                return;
                              }
                              if (endDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please select an end date')),
                                );
                                return;
                              }
                              if (endDate!.isBefore(startDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'End date must be after start date')),
                                );
                                return;
                              }

                              // Create goal object
                              final newGoal = Goal(
                                id: '', // API will assign an ID
                                goalType: goalType,
                                startDate: startDate!,
                                endDate: endDate!,
                                targetCalories: targetCalories,
                                targetProtein: targetProtein,
                                targetCarbs: targetCarbs,
                                targetFat: targetFat,
                                userId:
                                    '1', // Use current user ID - would come from auth
                                startWeight: startWeightController
                                        .text.isNotEmpty
                                    ? double.parse(startWeightController.text)
                                    : null,
                                desiredWeight: desiredWeightController
                                        .text.isNotEmpty
                                    ? double.parse(desiredWeightController.text)
                                    : null,
                                numberOfMealsPerDay: numberOfMealsPerDay,
                                activityStatusPerDay: activityStatusPerDay,
                              );

                              // Add goal using provider
                              context.read<AppState>().addGoal(newGoal);

                              // Close dialog
                              Navigator.pop(context);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Goal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
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
    // Find the active goal
    final now = DateTime.now();
    Goal? activeGoal = goals.isNotEmpty
        ? goals.firstWhere(
            (goal) => goal.endDate.isAfter(now) && goal.startDate.isBefore(now),
            orElse: () => goals.first,
          )
        : null;

    Progress? latestProgress;

    if (activeGoal != null && progressEntries.isNotEmpty) {
      // Find progress entries for this goal
      final goalProgressEntries = progressEntries
          .where((progress) => progress.goalId == activeGoal.id)
          .toList();

      if (goalProgressEntries.isNotEmpty) {
        // Sort by date to get the most recent
        goalProgressEntries
            .sort((a, b) => b.lastUpdatedDate.compareTo(a.lastUpdatedDate));
        latestProgress = goalProgressEntries.first;
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
  final Goal goal;
  final Progress? progress;

  const _GoalCard({
    Key? key,
    required this.goal,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDateStr = DateFormat('MMM d, yyyy').format(goal.startDate);
    final endDateStr = DateFormat('MMM d, yyyy').format(goal.endDate);
    final isActive = goal.endDate.isAfter(DateTime.now()) &&
        goal.startDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing8,
        horizontal: AppTheme.spacing16,
      ),
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
      child: InkWell(
        onTap: () {
          // Navigate to goal details
          // TODO: Implement goal details screen
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
                  // Status indicator and action buttons
                  Row(
                    children: [
                      // Status badge
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
                      const SizedBox(width: AppTheme.spacing8),
                      // Menu for more actions
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDeleteGoal(context, goal.id);
                          } else if (value == 'edit') {
                            _editGoal(context, goal);
                          } else if (value == 'set_active') {
                            context.read<AppState>().setActiveGoal(goal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${goal.goalType} set as active goal'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isActive)
                            const PopupMenuItem<String>(
                              value: 'set_active',
                              child: Text('Set as active'),
                            ),
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
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
      ),
    );
  }

  // Show confirmation dialog before deleting a goal
  void _confirmDeleteGoal(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text(
            'Are you sure you want to delete this goal? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().deleteGoal(goalId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal deleted successfully'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Open the edit goal dialog
  void _editGoal(BuildContext context, Goal goal) {
    _showEditGoalDialog(context, goal);
  }
}

// Method to show the edit goal dialog with pre-filled data
void _showEditGoalDialog(BuildContext context, Goal goal) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController startDateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(goal.startDate));
  final TextEditingController endDateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(goal.endDate));
  final TextEditingController startWeightController = TextEditingController(
      text: goal.startWeight != null && goal.startWeight! > 0
          ? goal.startWeight.toString()
          : '');
  final TextEditingController desiredWeightController = TextEditingController(
      text: goal.desiredWeight != null && goal.desiredWeight! > 0
          ? goal.desiredWeight.toString()
          : '');

  // Initialize with goal values
  DateTime startDate = goal.startDate;
  DateTime endDate = goal.endDate;
  String goalType = goal.goalType;
  String activityStatusPerDay = goal.activityStatusPerDay ?? 'Moderate';
  int numberOfMealsPerDay = goal.numberOfMealsPerDay ?? 3;
  int targetCalories = goal.targetCalories;
  int targetProtein = goal.targetProtein;
  int targetCarbs = goal.targetCarbs;
  int targetFat = goal.targetFat;

  // Define activity status options
  final List<String> activityOptions = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];

  // Define goal type options
  final List<String> goalTypeOptions = [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Maintenance'
  ];

  // Show date picker for edit goal screen
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? startDate : endDate;
    final firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 1))
        : startDate;
    final lastDate = isStartDate
        ? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 730));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (isStartDate) {
        startDate = pickedDate;
        startDateController.text = DateFormat('MMM d, yyyy').format(pickedDate);
      } else {
        endDate = pickedDate;
        endDateController.text = DateFormat('MMM d, yyyy').format(pickedDate);
      }
    }
  }

  // Show full-screen bottom sheet for better UX
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setEditState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle and title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Edit Goal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form content - same as add goal form but pre-filled
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goal Type Section
                        const Text(
                          'Goal Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              isCollapsed: false,
                            ),
                            value: goalType,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            items: goalTypeOptions.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setEditState(() {
                                  goalType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Date Section
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Start Date
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await _selectDate(context, true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Start Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              startDateController.text.isEmpty
                                                  ? 'Select date'
                                                  : startDateController.text,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: startDateController
                                                        .text.isEmpty
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // End Date
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await _selectDate(context, false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'End Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              endDateController.text.isEmpty
                                                  ? 'Select date'
                                                  : endDateController.text,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: endDateController
                                                        .text.isEmpty
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!endDate.isAfter(startDate))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'End date must be after start date',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Weight Information (conditional)
                        if (goalType == 'Weight Loss' ||
                            goalType == 'Weight Gain') ...[
                          const Text(
                            'Weight Goals',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Current Weight
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextFormField(
                                    controller: startWeightController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Current Weight',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      suffixText: 'kg',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Target Weight
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextFormField(
                                    controller: desiredWeightController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Target Weight',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      suffixText: 'kg',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Activity Level
                        const Text(
                          'Activity Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                            ),
                            value: activityStatusPerDay,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            items: activityOptions.map((String activity) {
                              return DropdownMenuItem<String>(
                                value: activity,
                                child: Text(activity),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setEditState(() {
                                  activityStatusPerDay = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Meals Per Day
                        const Text(
                          'Meals Per Day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                            ),
                            value: numberOfMealsPerDay,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            items: [3, 4, 5, 6].map((int number) {
                              return DropdownMenuItem<int>(
                                value: number,
                                child: Text(number.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setEditState(() {
                                  numberOfMealsPerDay = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nutrition Goals Section
                        const Text(
                          'Daily Nutrition Goals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Calories
                        _NutritionSliderCard(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                          title: 'Calories',
                          value: targetCalories.toDouble(),
                          min: 1200.0,
                          max: 3000.0,
                          unit: 'kcal',
                          onChanged: (value) {
                            setEditState(() {
                              targetCalories = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Protein
                        _NutritionSliderCard(
                          icon: Icons.fitness_center,
                          iconColor: Colors.blue,
                          title: 'Protein',
                          value: targetProtein.toDouble(),
                          min: 50.0,
                          max: 250.0,
                          unit: 'g',
                          onChanged: (value) {
                            setEditState(() {
                              targetProtein = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Carbs
                        _NutritionSliderCard(
                          icon: Icons.grain,
                          iconColor: Colors.amber,
                          title: 'Carbohydrates',
                          value: targetCarbs.toDouble(),
                          min: 50.0,
                          max: 400.0,
                          unit: 'g',
                          onChanged: (value) {
                            setEditState(() {
                              targetCarbs = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Fat
                        _NutritionSliderCard(
                          icon: Icons.opacity,
                          iconColor: Colors.deepPurple,
                          title: 'Fat',
                          value: targetFat.toDouble(),
                          min: 20.0,
                          max: 150.0,
                          unit: 'g',
                          onChanged: (value) {
                            setEditState(() {
                              targetFat = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom action buttons
              Container(
                padding: EdgeInsets.fromLTRB(
                    24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          // Validate form
                          if (formKey.currentState?.validate() ?? false) {
                            // Validate dates
                            if (!endDate.isAfter(startDate)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'End date must be after start date')),
                              );
                              return;
                            }

                            // Get updated values for weight fields
                            double? startWeight;
                            double? desiredWeight;

                            if (startWeightController.text.isNotEmpty) {
                              startWeight =
                                  double.parse(startWeightController.text);
                            }

                            if (desiredWeightController.text.isNotEmpty) {
                              desiredWeight =
                                  double.parse(desiredWeightController.text);
                            }

                            // Create goal object with updates
                            final updatedGoal = Goal(
                              id: goal.id, // Keep the same ID
                              goalType: goalType,
                              startDate: startDate,
                              endDate: endDate,
                              targetCalories: targetCalories,
                              targetProtein: targetProtein,
                              targetCarbs: targetCarbs,
                              targetFat: targetFat,
                              userId: goal.userId, // Keep the same user ID
                              startWeight: startWeight,
                              desiredWeight: desiredWeight,
                              numberOfMealsPerDay: numberOfMealsPerDay,
                              activityStatusPerDay: activityStatusPerDay,
                            );

                            // Update goal using provider
                            context.read<AppState>().updateGoal(updatedGoal);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goal updated successfully'),
                              ),
                            );

                            // Close dialog
                            Navigator.pop(context);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    },
  );
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

class _NutritionSliderCard extends StatelessWidget {
  const _NutritionSliderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(0)} $unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: iconColor,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: iconColor,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                max.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
