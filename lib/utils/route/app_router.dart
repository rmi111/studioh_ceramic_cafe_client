import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/screens/profile/edit_profile.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/customer_home.dart';
import '../../screens/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const CustomerHomePage());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfile());


      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}