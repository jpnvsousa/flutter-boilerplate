import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../../core/subscription/subscription_service.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  Offerings? _offerings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);
    try {
      final offerings = await Purchases.getOfferings();
      setState(() => _offerings = offerings);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to load plans: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isLoading = true);
    try {
      await Purchases.purchasePackage(package);
      if (mounted) {
        context.showSnackBar('✅ Subscription activated!');
        context.pop();
      }
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError && mounted) {
        context.showErrorSnackBar('Purchase failed: ${e.name}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    try {
      final info = await Purchases.restorePurchases();
      if (mounted) {
        if (info.activeSubscriptions.isNotEmpty) {
          context.showSnackBar('✅ Purchases restored!');
        } else {
          context.showSnackBar('No purchases to restore.');
        }
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(user);
        },
      ),
    );
  }

  Widget _buildContent(dynamic user) {
    final currentOffering = _offerings?.current;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Current Plan Status ──────────────────────────────────────
          _CurrentPlanCard(user: user),
          const SizedBox(height: AppTokens.spacing32),

          if (!user.isSubscribed) ...[
            Text('Upgrade to Pro', style: context.textTheme.headlineMedium),
            const SizedBox(height: AppTokens.spacing8),
            Text(
              'Unlock all features with a Pro subscription.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppTokens.grey500,
              ),
            ),
            const SizedBox(height: AppTokens.spacing24),

            // ── Packages ─────────────────────────────────────────────────
            if (currentOffering != null) ...[
              ...currentOffering.availablePackages.map(
                (pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.spacing12),
                  child: _PackageCard(
                    package: pkg,
                    isRecommended: pkg.packageType == PackageType.annual,
                    onTap: () => _purchase(pkg),
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Text('No plans available. Please try again later.'),
              ),
            ],

            const SizedBox(height: AppTokens.spacing24),

            // ── Features List ────────────────────────────────────────────
            const _ProFeaturesList(),

            const SizedBox(height: AppTokens.spacing32),
          ],

          // ── Restore Purchases (required by App Store) ─────────────────
          Center(
            child: TextButton(
              onPressed: _restorePurchases,
              child: const Text('Restore purchases'),
            ),
          ),

          const SizedBox(height: AppTokens.spacing8),
          Center(
            child: Text(
              'Subscriptions auto-renew unless cancelled.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppTokens.grey400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.primary, AppTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusL),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Colors.white, size: 32),
          const SizedBox(width: AppTokens.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current plan',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  user.planDisplayName,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isRecommended,
    required this.onTap,
  });

  final Package package;
  final bool isRecommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTokens.spacing20),
        decoration: BoxDecoration(
          color: isRecommended
              ? AppTokens.primary.withOpacity(0.05)
              : context.colors.surface,
          border: Border.all(
            color: isRecommended ? AppTokens.primary : AppTokens.grey200,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusL),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRecommended)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppTokens.spacing8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spacing8,
                        vertical: AppTokens.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.primary,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusFull),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          fontSize: AppTokens.fontSizeXs,
                          fontWeight: AppTokens.fontWeightBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Text(
                    package.storeProduct.title,
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    package.storeProduct.description,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  package.storeProduct.priceString,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: AppTokens.primary,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProFeaturesList extends StatelessWidget {
  const _ProFeaturesList();

  static const _features = [
    (Icons.all_inclusive, 'Unlimited items'),
    (Icons.cloud_upload_outlined, 'Unlimited storage'),
    (Icons.group_outlined, 'Team collaboration'),
    (Icons.download_outlined, 'Export to PDF & CSV'),
    (Icons.support_agent, 'Priority support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Everything in Pro:', style: context.textTheme.titleMedium),
        const SizedBox(height: AppTokens.spacing12),
        ..._features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.spacing8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppTokens.success,
                  size: 20,
                ),
                const SizedBox(width: AppTokens.spacing12),
                Icon(f.$1, size: 18, color: AppTokens.grey600),
                const SizedBox(width: AppTokens.spacing8),
                Text(f.$2, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
