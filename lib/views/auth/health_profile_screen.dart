import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';

/// A screen to collect health profile information following Apple's Human Interface Guidelines
class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = '';
  final List<String> _selectedAllergies = [];

  // Default values for number pickers
  double _weight = 70.0;
  double _height = 170.0;
  int _age = 30;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
  ];

  // Enhanced allergy categories with more general options
  final Map<String, List<String>> _allergyCategories = {
    'Dairy & Eggs': ['Milk', 'Cheese', 'Yogurt', 'Eggs', 'Butter', 'Cream'],
    'Nuts & Seeds': [
      'Peanuts',
      'Tree nuts',
      'Almonds',
      'Walnuts',
      'Cashews',
      'Pistachios',
      'Sesame',
      'Sunflower seeds'
    ],
    'Seafood': [
      'Fish',
      'Shellfish',
      'Shrimp',
      'Crab',
      'Lobster',
      'Clams',
      'Mussels'
    ],
    'Grains': ['Wheat', 'Gluten', 'Barley', 'Rye', 'Oats', 'Corn'],
    'Fruits & Vegetables': [
      'Soy',
      'Celery',
      'Avocado',
      'Citrus fruits',
      'Strawberries',
      'Tomatoes'
    ],
    'Other': ['Sulfites', 'MSG', 'Food colorings', 'Preservatives', 'None']
  };

  // Track expanded categories
  final Set<String> _expandedCategories = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showNumberPicker({required String type}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: type == 'weight'
              ? _buildWeightPicker()
              : type == 'height'
                  ? _buildHeightPicker()
                  : _buildAgePicker(),
        );
      },
    );
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
              color: weight == _weight.toInt() ? Colors.blue : Colors.black,
              fontWeight: weight == _weight.toInt()
                  ? FontWeight.w600
                  : FontWeight.normal,
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
              color: height == _height.toInt() ? Colors.blue : Colors.black,
              fontWeight: height == _height.toInt()
                  ? FontWeight.w600
                  : FontWeight.normal,
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
              color: age == _age ? Colors.blue : Colors.black,
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

  Future<void> _completeRegistration() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      final String? gender =
          _selectedGender.isNotEmpty ? _selectedGender : null;

      // Filter out 'None' from allergies if selected
      final List<String> allergies =
          _selectedAllergies.contains('None') ? [] : _selectedAllergies;

      final success = await authService.completeRegistration(
        weight: _weight,
        height: _height,
        age: _age,
        gender: gender,
        allergies: allergies.isNotEmpty ? allergies : null,
      );

      if (success && mounted) {
        // Navigate to home screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Your Health Profile',
                    style: AppTheme.displayMedium.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spacing8),

                  Text(
                    'Help us personalize your meal plans',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spacing32),

                  // Health Profile Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Weight Selection with Number Picker
                        _buildMeasurementSelector(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Weight',
                          value: '${_weight.toInt()} kg',
                          onTap: () => _showNumberPicker(type: 'weight'),
                        ),

                        const SizedBox(height: AppTheme.spacing16),

                        // Height Selection with Number Picker
                        _buildMeasurementSelector(
                          icon: Icons.height_outlined,
                          label: 'Height',
                          value: '${_height.toInt()} cm',
                          onTap: () => _showNumberPicker(type: 'height'),
                        ),

                        const SizedBox(height: AppTheme.spacing16),

                        // Age Selection with Number Picker
                        _buildMeasurementSelector(
                          icon: Icons.cake_outlined,
                          label: 'Age',
                          value: _age == 1 ? '$_age year' : '$_age years',
                          onTap: () => _showNumberPicker(type: 'age'),
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Gender Selection
                        Text(
                          'Gender',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing8),

                        Wrap(
                          spacing: AppTheme.spacing8,
                          children: _genderOptions.map((gender) {
                            final isSelected = _selectedGender == gender;
                            return _buildChip(
                              label: gender,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedGender = gender;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppTheme.spacing24),

                        // Allergies Selection with Categories
                        Text(
                          'Allergies (optional)',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacing12),

                        // Allergy Categories with expandable sections
                        ..._allergyCategories.entries.map((entry) {
                          final category = entry.key;
                          final allergies = entry.value;
                          final isExpanded =
                              _expandedCategories.contains(category);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Header
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedCategories.remove(category);
                                    } else {
                                      _expandedCategories.add(category);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_right,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category,
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded Allergies
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, bottom: 8.0),
                                  child: Wrap(
                                    spacing: AppTheme.spacing8,
                                    runSpacing: AppTheme.spacing8,
                                    children: allergies.map((allergy) {
                                      final isSelected =
                                          _selectedAllergies.contains(allergy);
                                      return _buildChip(
                                        label: allergy,
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            if (allergy == 'None') {
                                              // If 'None' is selected, clear other selections
                                              if (!isSelected) {
                                                _selectedAllergies.clear();
                                                _selectedAllergies.add('None');
                                              } else {
                                                _selectedAllergies
                                                    .remove('None');
                                              }
                                            } else {
                                              // If another allergy is selected, remove 'None'
                                              _selectedAllergies.remove('None');

                                              // Toggle the selection
                                              if (isSelected) {
                                                _selectedAllergies
                                                    .remove(allergy);
                                              } else {
                                                _selectedAllergies.add(allergy);
                                              }
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Selected Allergies Summary
                  if (_selectedAllergies.isNotEmpty &&
                      !_selectedAllergies.contains('None'))
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Allergies:',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAllergies.join(', '),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error Message
                  if (authService.error != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing12),
                      child: Text(
                        authService.error!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Complete Registration Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          authService.isLoading ? null : _completeRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing16),
                      ),
                      child: authService.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementSelector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: AppTheme.spacing16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
            right: AppTheme.spacing8, bottom: AppTheme.spacing8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
