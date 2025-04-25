import 'dart:async';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/screens/authentication/login_screen/login_screen.dart';
import 'package:e_commerce/screens/authentication/starting_screen/get_started.dart';
import 'package:e_commerce/screens/bottom_navigation_bar.dart';
import 'package:e_commerce/services/authentication/auth_servcies.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/network_observer_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    // Get the access token from SharedPreferences
    String? accessToken = await AuthService.getAccessToken();

    if (accessToken != null) {
      // If access token exists, get user data
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final statusCode = await authProvider.getUserData();

      if (statusCode == 200) {
        // User is logged in, navigate to home screen
        showCustomSnackBar(context, "Welcome Back!", Colors.green);
        Navigator.of(context).pushReplacement(
          SlidePageRoute(
            page: const BottomNavigationBarScreen(),
          ),
        );
      } else {
        // User is not logged in or token refresh failed, navigate to login screen
        Navigator.of(context).pushReplacement(
          SlidePageRoute(
            page: const LoginScreen(),
          ),
        );
      }
    } else {
      // No access token found, navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        SlidePageRoute(
          page: const GetStarted(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderNetworkObserver(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : null,
            gradient: Theme.of(context).brightness == Brightness.dark ? null : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.accentText.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              // Center widget to ensure child is in the center
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    height: 80, 
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/service_icon.svg',
                        height: 50,
                        width: 50,
                        colorFilter: ColorFilter.mode(
                          AppTheme.secondaryColor, 
                          BlendMode.srcIn
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App Name
                  Text(
                    'E-Services',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tagline
                  Text(
                    'Your One-Stop Service Hub',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
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
