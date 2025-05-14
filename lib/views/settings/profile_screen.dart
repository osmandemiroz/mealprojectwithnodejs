// ignore_for_file: avoid_unnecessary_containers, omit_local_variable_types, document_ignores, deprecated_member_use

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

/// A screen for the user to view and edit their profile information
/// Following Apple's Human Interface Guidelines with a clean, modern design
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;

  // Health measurements
  double _weight = 70;
  double _height = 170;
  int _age = 30;
  String _gender = '';

  bool _isEditing = false;
  double? _bmi;
  String _bmiCategory = '';
  Color _bmiColor = Colors.blue;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize with user data
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
    final User? user = authService.currentUser;

    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _surnameController = TextEditingController(text: user.surname);
      _emailController = TextEditingController(text: user.email);

      if (user.weight != null) _weight = user.weight!;
      if (user.height != null) _height = user.height!;
      if (user.age != null) _age = user.age!;
      if (user.gender != null) _gender = user.gender!;

      // Calculate BMI on initialization
      _calculateBMI();
    } else {
      _nameController = TextEditingController();
      _surnameController = TextEditingController();
      _emailController = TextEditingController();
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Calculate BMI using weight (kg) and height (cm)
  void _calculateBMI() {
    if (_height <= 0) return;

    // BMI formula: weight (kg) / (height (m))²
    final double heightInMeters = _height / 100;
    _bmi = _weight / (heightInMeters * heightInMeters);

    // Categorize BMI value
    if (_bmi! < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiColor = Colors.orange;
    } else if (_bmi! < 25) {
      _bmiCategory = 'Normal';
      _bmiColor = Colors.green;
    } else if (_bmi! < 30) {
      _bmiCategory = 'Overweight';
      _bmiColor = Colors.orange;
    } else {
      _bmiCategory = 'Obese';
      _bmiColor = Colors.red;
    }
  }

  /// Show number picker for weight, height or age
  void _showNumberPicker({required String type}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Select your ${type.toLowerCase()}',
                  style: AppTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: type == 'weight'
                    ? _buildWeightPicker()
                    : type == 'height'
                        ? _buildHeightPicker()
                        : _buildAgePicker(),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Calculate BMI after closing the picker
      setState(_calculateBMI);
    });
  }

  Widget _buildWeightPicker() {
    return CupertinoPicker(
      magnification: 1.2,
      backgroundColor: Colors.white,
      itemExtent: 40,
      scrollController: FixedExtentScrollController(
        initialItem: _weight.toInt() - 20,
      ),
      children: List<Widget>.generate(161, (int index) {
        // 20-180 kg range
        final weight = index + 20;
        return Center(
          child: Text(
            '$weight kg',
            style: TextStyle(
              color: weight == _weight
                  ? AppTheme.primaryColor
                  : AppTheme.textPrimaryColor,
              fontWeight:
                  weight == _weight ? FontWeight.w600 : FontWeight.normal,
              fontSize: 22,
            ),
          ),
        );
      }),
      onSelectedItemChanged: (int index) {
        setState(() {
          _weight = (index + 20).toDouble();
        });
      },
    );
  }

  Widget _buildHeightPicker() {
    return CupertinoPicker(
      magnification: 1.2,
      backgroundColor: Colors.white,
      itemExtent: 40,
      scrollController: FixedExtentScrollController(
        initialItem: _height.toInt() - 100,
      ),
      children: List<Widget>.generate(151, (int index) {
        // 100-250 cm range
        final height = index + 100;
        return Center(
          child: Text(
            '$height cm',
            style: TextStyle(
              color: height == _height
                  ? AppTheme.primaryColor
                  : AppTheme.textPrimaryColor,
              fontWeight:
                  height == _height ? FontWeight.w600 : FontWeight.normal,
              fontSize: 22,
            ),
          ),
        );
      }),
      onSelectedItemChanged: (int index) {
        setState(() {
          _height = (index + 100).toDouble();
        });
      },
    );
  }

  Widget _buildAgePicker() {
    return CupertinoPicker(
      magnification: 1.2,
      backgroundColor: Colors.white,
      itemExtent: 40,
      scrollController: FixedExtentScrollController(
        initialItem: _age - 1,
      ),
      children: List<Widget>.generate(100, (int index) {
        // 1-100 years range
        final age = index + 1;
        return Center(
          child: Text(
            age == 1 ? '$age year' : '$age years',
            style: TextStyle(
              color: age == _age
                  ? AppTheme.primaryColor
                  : AppTheme.textPrimaryColor,
              fontWeight: age == _age ? FontWeight.w600 : FontWeight.normal,
              fontSize: 22,
            ),
          ),
        );
      }),
      onSelectedItemChanged: (int index) {
        setState(() {
          _age = index + 1;
        });
      },
    );
  }

  /// Save updated profile data
  Future<void> _saveProfile() async {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
    final User? currentUser = authService.currentUser;

    if (currentUser != null) {
      // Create updated user with new data
      currentUser.copyWith(
        name: _nameController.text,
        surname: _surnameController.text,
        weight: _weight,
        height: _height,
        age: _age,
        gender: _gender,
      );

      // Update user in AuthService (would need to add this method)
      await authService.completeRegistration(
        weight: _weight,
        height: _height,
        age: _age,
        gender: _gender,
        allergies: currentUser.allergies,
      );

      setState(() {
        _isEditing = false;
        _calculateBMI();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    final User? user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  _isEditing = true;
                }
              });
            },
            child: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      '${user.name[0]}${user.surname[0]}',
                      style: AppTheme.displayMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ).animate().slideY(
                        begin: -0.2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    '${user.name} ${user.surname}',
                    style: AppTheme.headlineLarge,
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 500),
                      ),
                  Text(
                    user.email,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 500),
                      ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // BMI Card
            if (_bmi != null)
              _buildBmiCard().animate().scale(
                    begin: const Offset(0.95, 0.95),
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad,
                  ),

            const SizedBox(height: AppTheme.spacing24),

            // Personal Information Section
            _buildSection(
              title: 'Personal Information',
              children: [
                if (_isEditing)
                  _buildTextField(
                    controller: _nameController,
                    label: 'First Name',
                  )
                else
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'First Name',
                    value: user.name,
                  ),
                if (_isEditing)
                  _buildTextField(
                    controller: _surnameController,
                    label: 'Last Name',
                  )
                else
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Last Name',
                    value: user.surname,
                  ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user.email,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Health Information Section
            _buildSection(
              title: 'Health Information',
              children: [
                _buildInfoTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Weight',
                  value: '${_weight.toInt()} kg',
                  onTap: _isEditing
                      ? () => _showNumberPicker(type: 'weight')
                      : null,
                ),
                _buildInfoTile(
                  icon: Icons.height_outlined,
                  title: 'Height',
                  value: '${_height.toInt()} cm',
                  onTap: _isEditing
                      ? () => _showNumberPicker(type: 'height')
                      : null,
                ),
                _buildInfoTile(
                  icon: Icons.cake_outlined,
                  title: 'Age',
                  value: '$_age years',
                  onTap:
                      _isEditing ? () => _showNumberPicker(type: 'age') : null,
                ),
                _buildInfoTile(
                  icon: Icons.wc_outlined,
                  title: 'Gender',
                  value: _gender.isEmpty ? 'Not specified' : _gender,
                  onTap: _isEditing
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(AppTheme.spacing16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Male'),
                                    onTap: () {
                                      setState(() => _gender = 'Male');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Female'),
                                    onTap: () {
                                      setState(() => _gender = 'Female');
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BMI (Body Mass Index)',
                style: AppTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _bmiColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  _bmiCategory,
                  style: AppTheme.bodySmall.copyWith(
                    color: _bmiColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              Text(
                _bmi!.toStringAsFixed(1),
                style: AppTheme.displayMedium.copyWith(
                  color: _bmiColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'kg/m²',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Based on your height (${_height.toInt()} cm) and weight (${_weight.toInt()} kg)',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacing16,
            bottom: AppTheme.spacing8,
          ),
          child: Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 200));
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 22,
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
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
        ),
      ),
    );
  }
}
