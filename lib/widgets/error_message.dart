import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    required this.message,
    super.key,
    this.onRetry,
    this.useScaffold = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: AppTheme.errorColor,
        ),
        const SizedBox(height: AppTheme.spacing16),
        Text(
          message,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppTheme.spacing24),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ],
    );

    if (useScaffold) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Center(child: content),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Center(child: content),
    );
  }
}
