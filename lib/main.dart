import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/app_state.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style for edge-to-edge UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness
          .light, // iOS: light status bar content for dark backgrounds
      statusBarIconBrightness: Brightness
          .dark, // Android: dark status bar content for light backgrounds
      systemNavigationBarColor:
          Colors.transparent, // Make the navigation bar transparent
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Enable edge-to-edge for both platforms
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Initialize services
  final authService = AuthService();
  await authService.init();

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MyApp(
      authService: authService,
      storageService: storageService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.authService,
    required this.storageService,
    super.key,
  });
  final AuthService authService;
  final StorageService storageService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(storageService: storageService),
        ),
        ChangeNotifierProvider<AuthService>.value(value: authService),
      ],
      child: MaterialApp(
        title: 'Meal Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Show login screen if not authenticated, otherwise show home screen
        home: authService.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/meal-plan': (context) => const HomeScreen(),
          '/recipes': (context) => const HomeScreen(initialTab: 1),
          '/goals': (context) => const HomeScreen(initialTab: 2),
          '/settings': (context) => const HomeScreen(initialTab: 3),
        },
      ),
    );
  }
}
