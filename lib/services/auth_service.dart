import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// A service that manages authentication and user profile operations
class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Base URL for API calls
  final String _baseUrl =
      'http://localhost:3000/api'; // Change this to your server URL

  /// Initialize AuthService by checking for stored user data
  Future<void> init() async {
    _setLoading(true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user');

      if (userJson != null) {
        _currentUser =
            User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
      debugPrint('[AuthService.init] Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user with basic information
  Future<bool> registerBasicInfo({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create user with basic info
      final user = User(
        name: name,
        surname: surname,
        email: email,
        password: password,
      );

      // Store temporary user data
      _currentUser = user;

      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      debugPrint('[AuthService.registerBasicInfo] Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete registration with health profile information
  Future<bool> completeRegistration({
    double? weight,
    double? height,
    int? age,
    String? gender,
    List<String>? allergies,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw Exception(
            'No user data available. Please complete basic registration first.');
      }

      // Create a complete user object
      final user = _currentUser!.copyWith(
        weight: weight,
        height: height,
        age: age,
        gender: gender,
        allergies: allergies,
      );

      // Make API call to register user
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        // Parse response and save user data
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedUser =
            user.copyWith(id: responseData['userId']?.toString());

        // Save to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(updatedUser.toJson()));

        _currentUser = updatedUser;
        _isAuthenticated = true;
        notifyListeners();

        return true;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        _setError(errorData['message']?.toString() ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      debugPrint('[AuthService.completeRegistration] Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Make API call to login
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Parse response and save user data
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final user =
            User.fromJson(responseData['user'] as Map<String, dynamic>);

        // Save to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));

        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();

        return true;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        _setError(errorData['message']?.toString() ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      debugPrint('[AuthService.login] Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      debugPrint('[AuthService.logout] Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for state management
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
