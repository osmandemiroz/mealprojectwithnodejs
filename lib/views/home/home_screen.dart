import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../providers/app_state.dart';
import '../goals/goal_screen.dart';
import '../meal_plan/meal_plan_screen.dart';
import '../recipes/recipes_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get the status bar height to properly position content
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      // Remove SafeArea and use a Column with proper padding for the top
      body: Column(
        children: [
          // App Bar with status bar height included
          Container(
            padding: EdgeInsets.only(
              top: statusBarHeight +
                  AppTheme.spacing8, // Add padding above the title
              left: AppTheme.spacing16,
              right: AppTheme.spacing16,
              bottom: AppTheme.spacing8,
            ),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                Text(
                  _getTitle(),
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    // Navigate to profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Subtle divider between app bar and content
          const Divider(
            height: 1,
            thickness: 0.5,
            color: AppTheme.borderColor,
          ),

          // Main Content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                MealPlanScreen(),
                RecipesScreen(),
                GoalScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Meal Plan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Meal Plan';
      case 1:
        return 'Recipes';
      case 2:
        return 'Goals';
      case 3:
        return 'Settings';
      default:
        return 'Meal Planner';
    }
  }
}
