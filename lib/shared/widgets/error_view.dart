import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Generic error view for use in async widgets.
/// Shows an icon, message, and retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTokens.error,
              size: 56,
            ),
            const SizedBox(height: AppTokens.spacing16),
            Text(
              'Something went wrong',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTokens.spacing8),
              Text(
                message!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppTokens.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppTokens.spacing24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
