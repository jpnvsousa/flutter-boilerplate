import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  bool _magicLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onAuthSuccess() {
    final redirect = widget.redirectTo;
    if (redirect != null && redirect != AppRoutes.login) {
      context.go(redirect);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth success
    ref.listen(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.success && next.user != null) {
        _onAuthSuccess();
      }
      if (next.status == AuthStatus.success && next.user == null) {
        // Magic link sent
        setState(() => _magicLinkSent = true);
      }
      if (next.hasError) {
        context.showErrorSnackBar(next.error ?? 'Authentication failed');
        authNotifier.clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTokens.spacing48),

              // ── Logo / Brand ───────────────────────────────────────────
              const _BrandHeader(),
              const SizedBox(height: AppTokens.spacing48),

              if (_magicLinkSent) ...[
                _MagicLinkSentCard(email: _emailController.text),
              ] else ...[
                // ── Social Login ──────────────────────────────────────────
                _SocialLoginButton(
                  label: 'Continue with Google',
                  icon: 'assets/icons/google.svg',
                  isLoading: authState.isLoading,
                  onTap: authNotifier.signInWithGoogle,
                ),
                const SizedBox(height: AppTokens.spacing12),
                _SocialLoginButton(
                  label: 'Continue with Apple',
                  icon: 'assets/icons/apple.svg',
                  isLoading: authState.isLoading,
                  onTap: authNotifier.signInWithApple,
                ),

                // ── Divider ───────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTokens.spacing24),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTokens.spacing12,
                        ),
                        child: Text(
                          'or',
                          style: TextStyle(color: AppTokens.grey400),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

                // ── Magic Link ────────────────────────────────────────────
                _MagicLinkForm(
                  controller: _emailController,
                  isLoading: authState.isLoading,
                  onSend: (email) => authNotifier.sendMagicLink(email),
                ),
              ],

              const SizedBox(height: AppTokens.spacing32),
              _TermsFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-Widgets ───────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTokens.primary,
            borderRadius: BorderRadius.circular(AppTokens.radiusL),
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 36),
        ),
        const SizedBox(height: AppTokens.spacing16),
        Text(
          'Welcome back',
          style: context.textTheme.headlineLarge,
        ),
        const SizedBox(height: AppTokens.spacing8),
        Text(
          'Sign in to continue',
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppTokens.grey500,
          ),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.onSurface,
        side: BorderSide(color: context.colors.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing16,
          vertical: AppTokens.spacing16,
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

class _MagicLinkForm extends StatelessWidget {
  const _MagicLinkForm({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final void Function(String email) onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or sign in with email',
          style: context.textTheme.labelMedium,
        ),
        const SizedBox(height: AppTokens.spacing8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'your@email.com',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: AppTokens.spacing12),
        ElevatedButton(
          onPressed: isLoading ? null : () => onSend(controller.text.trim()),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send magic link'),
        ),
      ],
    );
  }
}

class _MagicLinkSentCard extends StatelessWidget {
  const _MagicLinkSentCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spacing24),
      decoration: BoxDecoration(
        color: AppTokens.infoLight,
        borderRadius: BorderRadius.circular(AppTokens.radiusL),
        border: Border.all(color: AppTokens.info.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.mark_email_read, color: AppTokens.info, size: 48),
          const SizedBox(height: AppTokens.spacing16),
          Text('Check your inbox', style: context.textTheme.headlineSmall),
          const SizedBox(height: AppTokens.spacing8),
          Text(
            'We sent a magic link to\n$email',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppTokens.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy.',
      textAlign: TextAlign.center,
      style: context.textTheme.bodySmall?.copyWith(color: AppTokens.grey400),
    );
  }
}
