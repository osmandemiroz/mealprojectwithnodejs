// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../providers/app_state.dart';

/// A panel that displays advanced filtering options for recipes
class RecipeFilterPanel extends StatelessWidget {
  const RecipeFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Determine if any advanced filters are active
        final hasActiveFilters = appState.caloriesFilterActive ||
            appState.prepTimeFilterActive ||
            appState.proteinFilterActive ||
            appState.carbsFilterActive ||
            appState.fatFilterActive;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: appState.advancedFiltersActive ? null : 0,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: appState.advancedFiltersActive
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Card(
              margin: const EdgeInsets.all(AppTheme.spacing16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and reset button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Advanced Filters',
                          style: AppTheme.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasActiveFilters)
                          TextButton.icon(
                            onPressed: () {
                              appState.resetAllFilters();
                            },
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Reset All'),
                          ),
                      ],
                    ),
                    const Divider(),

                    // Calories filter
                    _FilterSection(
                      title: 'Calories',
                      icon: Icons.local_fire_department,
                      isActive: appState.caloriesFilterActive,
                      onActiveChanged: (value) {
                        appState.setCaloriesFilter(active: value);
                      },
                      content: _NumericFilterContent(
                        value: appState.caloriesValue.toDouble(),
                        min: 0,
                        max: 2000,
                        divisions: 200,
                        unit: 'kcal',
                        mode: appState.caloriesFilterMode,
                        onModeChanged: (mode) {
                          appState.setCaloriesFilter(
                            active: appState.caloriesFilterActive,
                            mode: mode,
                          );
                        },
                        onValueChanged: (value) {
                          appState.setCaloriesFilter(
                            active: appState.caloriesFilterActive,
                            value: value.round(),
                          );
                        },
                      ),
                    ),

                    // Preparation time filter
                    _FilterSection(
                      title: 'Total Preparation Time',
                      icon: Icons.timer,
                      isActive: appState.prepTimeFilterActive,
                      onActiveChanged: (value) {
                        appState.setPrepTimeFilter(active: value);
                      },
                      content: _NumericFilterContent(
                        value: appState.prepTimeValue.toDouble(),
                        min: 0,
                        max: 180,
                        divisions: 180,
                        unit: 'min',
                        mode: appState.prepTimeFilterMode,
                        onModeChanged: (mode) {
                          appState.setPrepTimeFilter(
                            active: appState.prepTimeFilterActive,
                            mode: mode,
                          );
                        },
                        onValueChanged: (value) {
                          appState.setPrepTimeFilter(
                            active: appState.prepTimeFilterActive,
                            value: value.round(),
                          );
                        },
                      ),
                    ),

                    // Nutrient filters section header
                    const SizedBox(height: AppTheme.spacing16),
                    Text(
                      'Nutrients',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),

                    // Protein filter
                    _FilterSection(
                      title: 'Protein',
                      icon: Icons.fitness_center,
                      isActive: appState.proteinFilterActive,
                      onActiveChanged: (value) {
                        appState.setProteinFilter(active: value);
                      },
                      content: _NumericFilterContent(
                        value: appState.proteinValue,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        unit: 'g',
                        mode: appState.proteinFilterMode,
                        onModeChanged: (mode) {
                          appState.setProteinFilter(
                            active: appState.proteinFilterActive,
                            mode: mode,
                          );
                        },
                        onValueChanged: (value) {
                          appState.setProteinFilter(
                            active: appState.proteinFilterActive,
                            value: value,
                          );
                        },
                      ),
                    ),

                    // Carbohydrates filter
                    _FilterSection(
                      title: 'Carbohydrates',
                      icon: Icons.grain,
                      isActive: appState.carbsFilterActive,
                      onActiveChanged: (value) {
                        appState.setCarbsFilter(active: value);
                      },
                      content: _NumericFilterContent(
                        value: appState.carbsValue,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        unit: 'g',
                        mode: appState.carbsFilterMode,
                        onModeChanged: (mode) {
                          appState.setCarbsFilter(
                            active: appState.carbsFilterActive,
                            mode: mode,
                          );
                        },
                        onValueChanged: (value) {
                          appState.setCarbsFilter(
                            active: appState.carbsFilterActive,
                            value: value,
                          );
                        },
                      ),
                    ),

                    // Fat filter
                    _FilterSection(
                      title: 'Fat',
                      icon: Icons.opacity,
                      isActive: appState.fatFilterActive,
                      onActiveChanged: (value) {
                        appState.setFatFilter(active: value);
                      },
                      content: _NumericFilterContent(
                        value: appState.fatValue,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        unit: 'g',
                        mode: appState.fatFilterMode,
                        onModeChanged: (mode) {
                          appState.setFatFilter(
                            active: appState.fatFilterActive,
                            mode: mode,
                          );
                        },
                        onValueChanged: (value) {
                          appState.setFatFilter(
                            active: appState.fatFilterActive,
                            value: value,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing8),
                    // Applied filters summary
                    if (hasActiveFilters) ...[
                      const Divider(),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Active Filters:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Wrap(
                        spacing: AppTheme.spacing8,
                        runSpacing: AppTheme.spacing8,
                        children: [
                          if (appState.caloriesFilterActive)
                            _buildFilterChip(
                              'Calories ${appState.caloriesFilterMode.label} ${appState.caloriesValue} kcal',
                              Icons.local_fire_department,
                              () => appState.setCaloriesFilter(active: false),
                            ),
                          if (appState.prepTimeFilterActive)
                            _buildFilterChip(
                              'Prep Time ${appState.prepTimeFilterMode.label} ${appState.prepTimeValue} min',
                              Icons.timer,
                              () => appState.setPrepTimeFilter(active: false),
                            ),
                          if (appState.proteinFilterActive)
                            _buildFilterChip(
                              'Protein ${appState.proteinFilterMode.label} ${appState.proteinValue}g',
                              Icons.fitness_center,
                              () => appState.setProteinFilter(active: false),
                            ),
                          if (appState.carbsFilterActive)
                            _buildFilterChip(
                              'Carbs ${appState.carbsFilterMode.label} ${appState.carbsValue}g',
                              Icons.grain,
                              () => appState.setCarbsFilter(active: false),
                            ),
                          if (appState.fatFilterActive)
                            _buildFilterChip(
                              'Fat ${appState.fatFilterMode.label} ${appState.fatValue}g',
                              Icons.opacity,
                              () => appState.setFatFilter(active: false),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build a filter chip to display an active filter
  Widget _buildFilterChip(String label, IconData icon, VoidCallback onRemove) {
    return Chip(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text(label),
        ],
      ),
      deleteIcon: const Icon(
        Icons.cancel,
        size: 18,
      ),
      onDeleted: onRemove,
    );
  }
}

/// Section for a single filter type
class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onActiveChanged,
    required this.content,
  });

  final String title;
  final IconData icon;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.spacing8),
        // Filter section title with switch
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? AppTheme.textPrimaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ),
            Switch(
              value: isActive,
              onChanged: onActiveChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),

        // Filter content (only visible if filter is active)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isActive ? null : 0,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
              ),
              child: content,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        if (isActive) const Divider(),
      ],
    );
  }
}

/// Content for a numeric filter with slider and mode selector
class _NumericFilterContent extends StatelessWidget {
  const _NumericFilterContent({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.mode,
    required this.onModeChanged,
    required this.onValueChanged,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final FilterMode mode;
  final ValueChanged<FilterMode> onModeChanged;
  final ValueChanged<double> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter mode selector
        Row(
          children: [
            Expanded(
              child: SegmentedButton<FilterMode>(
                segments: const [
                  ButtonSegment<FilterMode>(
                    value: FilterMode.less,
                    label: Text('Less Than'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment<FilterMode>(
                    value: FilterMode.exactly,
                    label: Text('Exactly'),
                    icon: Icon(Icons.drag_handle),
                  ),
                  ButtonSegment<FilterMode>(
                    value: FilterMode.more,
                    label: Text('More Than'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (Set<FilterMode> selection) {
                  if (selection.isNotEmpty) {
                    onModeChanged(selection.first);
                  }
                },
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),

        // Value display and slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$min $unit',
              style: AppTheme.bodySmall,
            ),
            Text(
              '${value.round()} $unit',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$max $unit',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: '${value.round()} $unit',
          onChanged: onValueChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
