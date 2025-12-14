import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/screens/auth/register_screen.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/app_text_field.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/route/app_routes.dart';
import '../../utils/widget/snacke_bar.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController(
      
    );

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.message.contains('❌')) {
          AppSnackbar.show(context, state.message);
        }
        if (state.isLoggedIn) {
          AppSnackbar.show(context, state.message);
          Navigator.pushNamed(context, AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Login'),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/Studioh_Logo.jpg",
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 50),
                  AppTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: state.isLoading ? 'Logging in...' : 'Login',
                        onPressed: state.isLoading
                            ? () {}
                            : () async {
                                final email = emailController.text.trim();

                                bool isValidEmail(String email) {
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  return emailRegex.hasMatch(email);
                                }

                                if (email.isEmpty) {
                                  AppSnackbar.show(
                                    context,
                                    'Please enter your email.',
                                  );
                                  return;
                                }

                                if (!isValidEmail(email)) {
                                  AppSnackbar.show(
                                    context,
                                    'Please enter a valid email address.',
                                  );
                                  return;
                                }

                                context.read<AuthCubit>().loginWithEmail(context, email);


                              },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                          ' Create Now',
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
