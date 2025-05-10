import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.useScaffold = false,
  });

  final String? message;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Use CupertinoActivityIndicator for iOS-style loading indicator
        const CupertinoActivityIndicator(
          radius: 16,
        ),
        if (message != null) ...[
          const SizedBox(height: AppTheme.spacing16),
          Text(
            message!,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (useScaffold) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
