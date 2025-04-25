import 'package:e_commerce/common/buttons/custom_gradient_button.dart';
import 'package:e_commerce/common/buttons/iconbox_with_title.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/text_form_fields/custom_text_form_field.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/authentication/login_provider.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/orders/orders_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/screens/authentication/forget_password_screens/forget_password_screen.dart';
import 'package:e_commerce/screens/authentication/opt_verification_screen/opt_verification_screen.dart';
import 'package:e_commerce/screens/authentication/register_screen/register_screen.dart';
import 'package:e_commerce/screens/bottom_navigation_bar.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/network_observer_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../common/snakbar/custom_snakbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return ProviderNetworkObserver(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Background - using brand colors with a softer gradient
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.black,
                            Colors.black,
                            Color(0xFF1A1A1A),
                          ]
                        : [
                            Colors.white,
                            Colors.grey.shade50,
                            Colors.grey.shade100,
                          ],
                  ),
                ),
              ),

              // Content container with scrolling
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and header area
                      SizedBox(height: height * 0.08),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home_repair_service_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: Text(
                          "Service Hub",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Your one-stop solution for all services",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.06),

                      // Welcome back text
                      Text(
                        "Welcome back",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sign in to your account",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // Login form
                      Consumer2<AuthenticationProvider, LoginProvider>(
                        builder: (context, authProvider, loginProvider, child) {
                          return Form(
                            key: loginProvider.loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email field with modern design
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.black26 : Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radius_md),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                    boxShadow: isDarkMode ? null : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: loginProvider.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (_) => loginProvider.markEmailTouched(),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter your email address",
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: isDarkMode ? Colors.white54 : AppTheme.primaryColor.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                      errorStyle: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    autovalidateMode: loginProvider.emailTouched 
                                        ? AutovalidateMode.onUserInteraction 
                                        : AutovalidateMode.disabled,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                SizedBox(height: 24),

                                // Password field with modern design
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.black26 : Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radius_md),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                    boxShadow: isDarkMode ? null : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: loginProvider.passwordController,
                                    obscureText: loginProvider.obscurePassword,
                                    onChanged: (_) => loginProvider.markPasswordTouched(),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter your password",
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: isDarkMode ? Colors.white54 : AppTheme.primaryColor.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () => loginProvider.togglePasswordVisibility(),
                                        child: Icon(
                                          !loginProvider.obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                                          size: 20,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                      errorStyle: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    autovalidateMode: loginProvider.passwordTouched 
                                        ? AutovalidateMode.onUserInteraction 
                                        : AutovalidateMode.disabled,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Forgot password link with better positioning
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        SlidePageRoute(
                                          page: const ForgetPasswordScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.04),

                                // Login button with modern styling
                                loginProvider.isLoggingIn
                                    ? Center(
                                        child: SizedBox(
                                          height: 56,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppTheme.primaryColor,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppTheme.radius_md),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              AppTheme.secondaryColor,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (loginProvider.loginFormKey.currentState!.validate()) {
                                              loginProvider.setIsLoggingIn(true);

                                              final statusCode = await authProvider.login(
                                                loginProvider.emailController.text,
                                                loginProvider.passwordController.text,
                                              );

                                              loginProvider.setIsLoggingIn(false);

                                              if (statusCode == 200) {
                                                // Success, load other data
                                                await context.read<CategoryProvider>().fetchCategories();
                                                await context.read<ServiceProvider>().fetchServices();
                                                await context.read<OrderProvider>().fetchMyOrders();

                                                // Navigate to home
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  SlidePageRoute(
                                                    page: const BottomNavigationBarScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              } else if (statusCode == 401) {
                                                // Wrong credentials
                                                showCustomSnackBar(
                                                    context, "Invalid email or password.", Colors.red);
                                              } else if (statusCode == 403) {
                                                // Email not verified
                                                showCustomSnackBar(context,
                                                    "Please verify your email first.", Colors.orange);
                                                // Navigate to OTP verification
                                                Navigator.push(
                                                  context,
                                                  SlidePageRoute(
                                                    page: OptVerificationScreen(
                                                      email: loginProvider.emailController.text,
                                                    ),
                                                  ),
                                                );
                                              } else if (statusCode == -1) {
                                                // Network or other error
                                                showCustomSnackBar(context,
                                                    "Failed to login. Please try again.", Colors.red);
                                              } else {
                                                // Handle any other status codes
                                                showCustomSnackBar(
                                                    context,
                                                    "Failed to login. Please try again. Error code: $statusCode",
                                                    Colors.red);
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            "Sign In",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                SizedBox(height: height * 0.04),

                                // Create account option
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          SlidePageRoute(
                                            page: const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Create one",
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
