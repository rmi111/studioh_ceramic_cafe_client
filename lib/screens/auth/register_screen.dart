import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/app_text_field.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_btn.dart';

import '../../utils/route/app_routes.dart';
import '../../utils/widget/snacke_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// AuthCubit is provided at the root, so the login screen listens to the same
  /// state and would also navigate. Only navigate once, from the visible route.
  bool _navigating = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return phoneRegex.hasMatch(phone);
  }

  void _validateAndRegister(BuildContext context) {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneNumberController.text.trim();

    if (email.isEmpty || phone.isEmpty || name.isEmpty) {
      AppSnackbar.showError(context, 'Please fill in all fields.');
      return;
    }

    if (!isValidEmail(email)) {
      AppSnackbar.showError(context, 'Please enter a valid email address.');
      return;
    }

    if (!isValidPhone(phone)) {
      AppSnackbar.showError(context, 'Please enter a valid phone number.');
      return;
    }

    // All validations passed, call cubit
    context.read<AuthCubit>().onRegistration(
      context: context,
      email: email,
      name: name,
      phone: phone,
    );
  }

  /// Show welcome dialog for first-time users, then navigate to home
  void _showWelcomeAndNavigate(BuildContext context, AuthState state) async {
    final authCubit = context.read<AuthCubit>();
    final user = state.currentUserModel!;

    // New users are always first-time, show welcome
    if (!user.enrolledByClient) {
      await authCubit.checkFirstLoginAndShowWelcome(context, user.id);
    }

    // Navigate to home
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      _navigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Show error messages
        if (state.message.contains('❌') && !state.isLoading) {
          AppSnackbar.showError(context, state.message);
        }

        // Only the visible route should react.
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
        if (!isVisible) return;

        // Handle successful registration — show welcome and navigate to home
        if (state.isLoggedIn &&
            state.currentUserModel != null &&
            !state.isLoading &&
            !_navigating) {
          _navigating = true;
          AppSnackbar.show(context, 'Registration Successful! 🎉');
          _showWelcomeAndNavigate(context, state);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          centerTitle: true,
          titleTextStyle: const TextStyle(fontSize: 30, color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/Studioh_Logo.jpg",
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: nameController,
                    label: 'Username',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    label: 'Phone Number',
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: state.isLoading ? 'Registering...' : 'Register',
                        onPressed: state.isLoading
                            ? () {}
                            : () => _validateAndRegister(context),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
