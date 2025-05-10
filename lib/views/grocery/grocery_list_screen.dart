import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/grocery_list.dart';
import '../../providers/app_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppState>().loadGroceryLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const LoadingIndicator(
            message: 'Loading grocery lists...',
          );
        }

        if (appState.error != null) {
          return ErrorMessage(
            message: appState.error!,
            onRetry: () {
              // TODO: Implement retry
            },
          );
        }

        if (appState.groceryLists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_basket_outlined,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'No Grocery Lists',
                  style: AppTheme.displaySmall.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Create a new grocery list to get started',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing24),
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Implement create grocery list
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Grocery List'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          itemCount: appState.groceryLists.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: AppTheme.spacing16,
          ),
          itemBuilder: (context, index) {
            final groceryList = appState.groceryLists[index];
            return _GroceryListCard(groceryList: groceryList)
                .animate()
                .fadeIn()
                .slideX();
          },
        );
      },
    );
  }
}

class _GroceryListCard extends StatelessWidget {
  const _GroceryListCard({
    required this.groceryList,
  });

  final GroceryList groceryList;

  @override
  Widget build(BuildContext context) {
    final completedItems =
        groceryList.items.where((item) => item.isChecked).length;
    final totalItems = groceryList.items.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to grocery list details
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groceryList.name,
                style: AppTheme.displaySmall.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                '$completedItems/$totalItems items completed',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.primaryColor.withAlpha(31),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
