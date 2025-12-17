import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/main.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/screens/auth/login_screen.dart';
import 'package:studioh_ceramic_cafe_client/screens/customer_home.dart';

import '../utils/route/app_routes.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAsync();
  }

  Future<void> _checkLoginStatusAsync() async {
    print('=== Splash Screen: Checking Login Status ===');

    try {
      // Get AuthCubit
      final authCubit = context.read<AuthCubit>();

      print('🔍 Checking login status...');
      await authCubit.checkLoginStatus();
      print(' Login status checked');
    print(' Waiting for initialization to complete...');
      int attempts = 0;
         print(' Initialization complete (attempts: $attempts)');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Check login status
      final isLoggedIn = authCubit.state.isLoggedIn;
      final currentUser = authCubit.state.currentUserModel;

      print('Login Status: $isLoggedIn');
      print('Current User: ${currentUser?.email}');

      if (isLoggedIn && currentUser != null) {
        print('✅ User is logged in. Going to home...');
        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CustomerHomePage()));
        }
      } else {
        print('❌ User is not logged in. Going to login...');
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
        }
      }
    } catch (e) {
      print('❌ Error checking login status: $e');
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/Studioh_Logo.jpg',
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to StudioH',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Lottie.asset(
                    'assets/images/Animation - 1749106532062.json',
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Powered by Studioh',
                  style: TextStyle(
                    color: Color.fromARGB(255, 92, 86, 86),
                    fontSize: 14,
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

// /// Screen for unknown user roles
// class UnknownRoleScreen extends StatelessWidget {
//   const UnknownRoleScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 80, color: Colors.red),
//             const SizedBox(height: 24),
//             const Text(
//               'Unknown User Role',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 32.0),
//               child: Text(
//                 'Please contact support or try logging in again.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 32),
//             BlocBuilder<AuthCubit, AuthState>(
//               builder: (context, state) {
//                 return ElevatedButton(
//                   onPressed: () {
//                     context.read<AuthCubit>().signOut(context);
//                   },
//                   child: const Text('Return to Login'),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Screen for errors
// class ErrorScreen extends StatelessWidget {
//   final String message;

//   const ErrorScreen({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.warning_amber_rounded,
//               size: 80,
//               color: Colors.orange,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Oops! Something went wrong',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32.0),
//               child: Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//             const SizedBox(height: 32),
//             BlocBuilder<AuthCubit, AuthState>(
//               builder: (context, state) {
//                 return ElevatedButton(
//                   onPressed: () {
//                     context.read<AuthCubit>().signOut(context);
//                   },
//                   child: const Text('Go to Login'),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Placeholder for Admin Home (since admin app is separate)
// class AdminPlaceholder extends StatelessWidget {
//   const AdminPlaceholder({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Admin Panel')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Admin Dashboard',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Admin features will be available in the admin application.',
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             BlocBuilder<AuthCubit, AuthState>(
//               builder: (context, state) {
//                 return ElevatedButton(
//                   onPressed: () {
//                     context.read<AuthCubit>().signOut(context);
//                   },
//                   child: const Text('Logout'),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
