import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../cubit/auth_cubit/auth_cubit.dart';
import '../../cubit/subscription_cubit/subscription_cubit.dart';
import '../../cubit/subscription_cubit/subscription_state.dart';
import '../../utils/constant/app_colors.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.currentUserModel?.uid;
    
    return BlocProvider(
      create: (_) => SubscriptionCubit(userId: userId),
      child: const _SubscriptionView(),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state.status == SubscriptionStatus.purchased) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Welcome to Premium!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: state.status == SubscriptionStatus.loading
                ? null
                : () => _restorePurchases(context),
            child: Text(
              'Restore',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionState state) {
    if (state.status == SubscriptionStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.status == SubscriptionStatus.error && state.offerings == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load subscriptions',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<SubscriptionCubit>().loadOfferings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPremiumIcon(),
          const SizedBox(height: 24),
          const Text(
            'Unlock Premium',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get access to all exclusive features',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildFeaturesList(),
          const SizedBox(height: 32),
          _buildPackagesList(context, state),
          const SizedBox(height: 24),
          _buildSubscribeButton(context, state),
          const SizedBox(height: 16),
          _buildTermsText(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPremiumIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.button,
            AppColors.button.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.button.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Unlimited voucher redemptions',
      'Priority booking access',
      'Exclusive member discounts',
      'Early access to new features',
      'Premium customer support',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.button.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackagesList(BuildContext context, SubscriptionState state) {
    final packages = state.packages;
    
    if (packages.isEmpty) {
      // Fallback to mock data when no offerings available
      return Column(
        children: [
          _buildMockPackageCard(
            context,
            state,
            'Monthly',
            9.99,
            'month',
            null,
            false,
          ),
          const SizedBox(height: 16),
          _buildMockPackageCard(
            context,
            state,
            'Yearly',
            23.99,
            'year',
            '80% OFF',
            true,
          ),
        ],
      );
    }
    
    return Column(
      children: packages.map((package) {
        final isSelected = state.selectedPackage?.identifier == package.identifier;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPackageCard(context, package, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package, bool isSelected) {
    final product = package.storeProduct;
    final isYearly = package.packageType == PackageType.annual;
    
    return GestureDetector(
      onTap: () => context.read<SubscriptionCubit>().selectPackage(package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.button : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.button : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.button : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPackageTitle(package),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.grey[900] : Colors.white,
                        ),
                      ),
                      if (isYearly) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[400]!, Colors.green[600]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.grey[600] : Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.button : Colors.white,
                  ),
                ),
                Text(
                  '/${_getPeriodLabel(package)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.grey[600] : Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockPackageCard(
    BuildContext context,
    SubscriptionState state,
    String name,
    double price,
    String period,
    String? badge,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.button : Colors.white.withOpacity(0.2),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.button.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.button : Colors.grey,
                width: 2,
              ),
              color: isSelected ? AppColors.button : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.grey[900] : Colors.white,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[400]!, Colors.green[600]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Billed $period',
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.grey[600] : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.button : Colors.white,
                ),
              ),
              Text(
                '/$period',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.grey[600] : Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context, SubscriptionState state) {
    final isLoading = state.status == SubscriptionStatus.purchasing;
    final packages = state.packages;
    
    String buttonText;
    if (packages.isNotEmpty && state.selectedPackage != null) {
      buttonText = 'Subscribe for ${state.selectedPackage!.storeProduct.priceString}';
    } else {
      buttonText = 'Subscribe Now';
    }

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.button, AppColors.button.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.button.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : () => _handleSubscribe(context, state),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Cancel anytime. Subscription auto-renews until cancelled.\nBy subscribing, you agree to our Terms of Service and Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.5),
        height: 1.5,
      ),
    );
  }

  void _handleSubscribe(BuildContext context, SubscriptionState state) {
    if (state.packages.isEmpty) {
      // Show message when no real products configured
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscriptions not yet configured. Please set up products in App Store Connect.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    context.read<SubscriptionCubit>().purchase();
  }

  void _restorePurchases(BuildContext context) async {
    final cubit = context.read<SubscriptionCubit>();
    final restored = await cubit.restorePurchases();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored 
                ? '✅ Purchases restored successfully!' 
                : 'No previous purchases found.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      if (restored) {
        Navigator.pop(context, true);
      }
    }
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly';
      case PackageType.weekly:
        return 'Weekly';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return package.identifier;
    }
  }

  String _getPeriodLabel(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'month';
      case PackageType.annual:
        return 'year';
      case PackageType.weekly:
        return 'week';
      case PackageType.lifetime:
        return 'one-time';
      default:
        return '';
    }
  }
}
