import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/app_state.dart';
import 'services/auth_service.dart';
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

  // Initialize auth service
  final authService = AuthService();
  await authService.init();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.authService, super.key});
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
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
        },
      ),
    );
  }
}
