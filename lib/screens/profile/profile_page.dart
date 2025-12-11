import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/utils/route/app_routes.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';
import '../../cubit/auth_cubit/auth_cubit.dart';
import '../../model/user.dart';
import '../../utils/constant/app_colors.dart';
import '../../utils/widget/custom_text.dart';
class OwnProfileScreen extends StatelessWidget {
  const OwnProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle logout navigation here only
        if (!state.isLoggedIn && !state.isLoading) {
          AppSnackbar.show(context, 'Successfully logged out.');
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final currentUser = state.currentUserModel;

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (currentUser == null) {
              return const Center(child: Text('No user data available'));
            }

            return SafeArea(
              child: Column(
                children: [
                  // Top Bar with Edit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.text),
                          tooltip: 'Close',
                        ),
                        Expanded(
                          child: Center(
                            child: CustomText(
                              text: 'Profile',
                              color: AppColors.text,
                              fontSizeFactor: 1.3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                           Navigator.pushNamed(context,AppRoutes.editProfile);
                            },
                            icon: Icon(Icons.edit, color: AppColors.background),
                            tooltip: 'Edit Profile',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Profile Header Card
                  _PersonalInfoCard(user: currentUser),

                  const SizedBox(height: 10),

                  // Menu Options
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [

                            _PremiumCard(),
                            const SizedBox(height: 14),
                            _LogoutButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  final UserModel user;

  const _PersonalInfoCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.button, AppColors.button.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.button.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.background,
                  backgroundImage:
                      user.imageUrl != null && user.imageUrl!.isNotEmpty
                      ? NetworkImage(user.imageUrl!)
                      : null,
                  child: user.imageUrl == null || user.imageUrl!.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.button,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Name
          Text(
            user.name  ?? user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),


          // User Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.userType.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.button,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Divider
          Container(height: 1, color: AppColors.background.withOpacity(0.2)),
          const SizedBox(height: 10),

          // Info Items
          _buildInfoItem(icon: Icons.email_rounded, text: user.email),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.phone_rounded,
            text: user.phoneNumber ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.background.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final GestureTapCallback? onTap;

  const _ProfileOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[300]!, Colors.purple[600]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                'Premium Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlock exclusive features and benefits',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement paywall
                // RevenueCatUI.presentPaywall(displayCloseButton: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Manage Subscription',
                style: TextStyle(
                  color: Colors.purple[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({Key? key}) : super(key: key);

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
          
              context.read<AuthCubit>().signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : () => _showLogoutConfirmation(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    else
                      const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      isLoading ? 'Logging out...' : 'Logout',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
