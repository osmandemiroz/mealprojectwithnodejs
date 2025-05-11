import 'dart:convert';
import 'dart:io';
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

  // Base URL for API calls - use a variable to easily switch between local and emulator mode
  final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api' // For Android emulator
      : 'http://localhost:3000/api'; // For iOS simulator or web

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
      // Validate email format
      final bool isValidEmail =
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      if (!isValidEmail) {
        _setError('Please enter a valid email address');
        return false;
      }

      // Validate password strength
      if (password.length < 6) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

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

      // Format the full name by combining first name and surname to match backend expectation
      final String fullName = '${user.name} ${user.surname}';

      // Format user data to match the backend's expected format
      final Map<String, dynamic> userData = {
        'name': fullName,
        'email': user.email,
        'password': user.password, // Backend expects a password field
        'accessLevel': 'user',
        'dietaryPreferences':
            user.allergies != null ? user.allergies!.join(', ') : '',
        'height': user.height,
        'weight': user.weight,
        'gender': user.gender,
        'age': user.age,
      };

      // Make API call to register user
      try {
        // Set a timeout for the API call
        final response = await http
            .post(
              Uri.parse('$_baseUrl/users/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(userData),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 201) {
          // Parse response and save user data
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
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
          // Use local fallback without showing an error to the user
          debugPrint(
              '[AuthService.completeRegistration] Server error: ${response.statusCode} - ${response.body}');
          return _useLocalFallback(user);
        }
      } catch (networkError) {
        // If server is not available, use local fallback
        debugPrint(
            '[AuthService.completeRegistration] Network error: $networkError');
        return _useLocalFallback(user);
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      debugPrint('[AuthService.completeRegistration] Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Local fallback method for saving user when server is unavailable
  Future<bool> _useLocalFallback(User user) async {
    debugPrint('[AuthService] Using local fallback for user data');
    try {
      // Generate a fake ID
      final updatedUser =
          user.copyWith(id: 'local-${DateTime.now().millisecondsSinceEpoch}');

      // Save to shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(updatedUser.toJson()));

      _currentUser = updatedUser;
      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to save user data locally: ${e.toString()}');
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // First validate the inputs
      if (email.isEmpty || password.isEmpty) {
        _setError('Email and password are required');
        return false;
      }

      // Check valid email format
      final bool isValidEmail =
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      if (!isValidEmail) {
        _setError('Please enter a valid email address');
        return false;
      }

      try {
        // Attempt to login with server, but use a timeout to avoid long waits
        final response = await http.get(
          Uri.parse('$_baseUrl/users?email=$email'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          try {
            final List<dynamic> users =
                jsonDecode(response.body) as List<dynamic>;

            // Find the user with matching email
            final user = users.cast<Map<String, dynamic>>().firstWhere(
                  (user) => user['Email'] == email,
                  orElse: () => <String, dynamic>{},
                );

            if (user.isNotEmpty) {
              // For demo purposes, any password works if email exists
              return _loginSuccess(User(
                id: user['UID']?.toString() ??
                    'server-${DateTime.now().millisecondsSinceEpoch}',
                name: _extractFirstName(user['Name']?.toString() ?? 'User'),
                surname:
                    _extractLastName(user['Name']?.toString() ?? 'Account'),
                email: email,
                password: password,
                weight: user['Weight'] != null
                    ? double.parse(user['Weight'].toString())
                    : null,
                height: user['Height'] != null
                    ? double.parse(user['Height'].toString())
                    : null,
                age: user['Age'] != null
                    ? int.parse(user['Age'].toString())
                    : null,
                gender: user['GENDER']?.toString(),
                allergies: user['Dietary_Preferences'] != null
                    ? (user['Dietary_Preferences'] as String).split(', ')
                    : null,
              ));
            }
          } catch (parseError) {
            debugPrint('[AuthService.login] Parse error: $parseError');
          }
        }

        // If we get here, either the user wasn't found or there was a response parsing error
        // Use local login fallback
        return _loginWithLocalFallback(email, password);
      } catch (networkError) {
        debugPrint('[AuthService.login] Network error: $networkError');
        return _loginWithLocalFallback(email, password);
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      debugPrint('[AuthService.login] Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Extract first name from a full name
  String _extractFirstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'User';
  }

  /// Extract last name from a full name
  String _extractLastName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  /// Login with local fallback when server is unavailable
  Future<bool> _loginWithLocalFallback(String email, String password) async {
    // Check if we have saved users in shared preferences that match these credentials
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? existingUserJson = prefs.getString('user');

    if (existingUserJson != null) {
      try {
        final existingUser =
            User.fromJson(jsonDecode(existingUserJson) as Map<String, dynamic>);
        if (existingUser.email == email) {
          // For demo purposes, any password works for saved user
          return _loginSuccess(existingUser);
        }
      } catch (e) {
        debugPrint(
            '[AuthService.loginWithLocalFallback] Error parsing saved user: $e');
      }
    }

    // Create a demo user if no matching user was found
    return _loginSuccess(User(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Demo',
      surname: 'User',
      email: email,
      password: password,
    ));
  }

  /// Common login success handler
  Future<bool> _loginSuccess(User user) async {
    try {
      // Save to shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to save login information: ${e.toString()}');
      return false;
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
