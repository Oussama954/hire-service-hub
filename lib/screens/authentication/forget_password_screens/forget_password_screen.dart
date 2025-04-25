import 'package:e_commerce/common/buttons/back_icon_button_with_title.dart';
import 'package:e_commerce/common/buttons/custom_gradient_button.dart';
import 'package:e_commerce/common/text_form_fields/custom_text_form_field.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/authentication/forget_password_provider.dart';
import 'package:e_commerce/screens/authentication/forget_password_screens/forget_password_otp_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/network_observer_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../common/snakbar/custom_snakbar.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return ProviderNetworkObserver(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Forgot Password",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Background with subtle gradient
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
                  child: Consumer2<AuthenticationProvider, ForgetPasswordProvider>(
                    builder: (context, authProvider, forgetPasswordProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Illustration/icon area
                          SizedBox(height: height * 0.06),
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white12 : AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_reset_outlined,
                                  size: 40,
                                  color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Header text
                          Text(
                            "Forgot your password?",
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Don't worry, it happens to the best of us. Enter your email and we'll send you a verification code to reset your password.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: height * 0.06),

                          // Form
                          Form(
                            key: forgetPasswordProvider.formKey,
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
                                    controller: forgetPasswordProvider.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter your registered email",
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
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
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

                                SizedBox(height: height * 0.06),

                                // Submit button with modern styling
                                Container(
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
                                      if (forgetPasswordProvider.validateForm()) {
                                        int statusCode = await authProvider.requestNewOTP(
                                          forgetPasswordProvider.emailController.text.trim(),
                                        );

                                        if (statusCode == 200) {
                                          // Inform the user that the OTP has been sent
                                          showCustomSnackBar(
                                            context,
                                            "Verification code sent to your email",
                                            Colors.green,
                                          );

                                          // Navigate to the OTP screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ForgetPasswordOtpScreen(
                                                email: forgetPasswordProvider.emailController.text.trim(),
                                              ),
                                            ),
                                          );
                                        } else if (statusCode == 400) {
                                          // Show failed OTP message
                                          showCustomSnackBar(
                                            context,
                                            "Failed to send verification code. Try again later.",
                                            Colors.red,
                                          );
                                        } else {
                                          // Handle other errors
                                          showCustomSnackBar(
                                            context,
                                            "An error occurred. Please try again.",
                                            Colors.red,
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    child: authProvider.isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            "Send Verification Code",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Return to login option
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "Back to Login",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
