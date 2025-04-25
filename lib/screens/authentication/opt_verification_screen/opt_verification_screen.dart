// ignore_for_file: use_build_context_synchronously

import 'package:e_commerce/common/buttons/back_icon_button_with_title.dart';
import 'package:e_commerce/common/buttons/custom_gradient_button.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/screens/authentication/login_screen/login_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/network_observer_provider.dart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../common/snakbar/custom_snakbar.dart';

class OptVerificationScreen extends StatefulWidget {
  final String email;
  const OptVerificationScreen({super.key, required this.email});

  @override
  State<OptVerificationScreen> createState() => _OptVerificationScreenState();
}

class _OptVerificationScreenState extends State<OptVerificationScreen> {
  String otp = ''; // Variable to store OTP input
  bool isOtpValid = false; // Track if OTP length is valid (6 digits)
  final GlobalKey<FormState> _otpFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Brightness brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;
    return ProviderNetworkObserver(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.accentText.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // App Title and Icon
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.05,
                top: height * 0.1,
              ),
              child: BackIconButtonWithTitle(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: "Verfication",
                  icon: IconlyLight
                      .arrow_left_2), // Replace with your custom widget
            ),
            // Login Form Container
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.80,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.darkSurface
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Consumer<AuthenticationProvider>(
                    builder: (context, authProvider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title removed
                        SizedBox(height: height * 0.01),
                        Text(
                          "Enter the OTP you received on your given email address ${widget.email}",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: height * 0.02),
                        PinCodeTextField(
                          appContext: context,
                          length: 6, // OTP length
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(AppTheme.radius_md),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
                            inactiveFillColor: isDarkMode ? AppTheme.darkGrey.withOpacity(0.1) : Colors.grey.shade100,
                            selectedFillColor: isDarkMode ? AppTheme.darkGrey.withOpacity(0.2) : Colors.grey.shade200,
                            activeColor: AppTheme.primaryColor,
                            inactiveColor: Colors.grey.shade300,
                            selectedColor: AppTheme.secondaryColor,
                          ),
                          enableActiveFill: true,
                          onChanged: (value) {
                            setState(() {
                              otp = value;
                              isOtpValid =
                                  otp.length == 6; // Check if OTP is 6 digits
                            });
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: Size(width * 0.9, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius_md),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.white70,
                          ),
                          onPressed: isOtpValid
                              ? () async {
                                  if (authProvider.isLoading) return;
                                  // Call verifyAccount and handle navigation based on the status code
                                  final statusCode =
                                      await authProvider.verifyAccount(
                                    email: widget.email,
                                    otp: otp,
                                  );
                                  if (statusCode == 200) {
                                    // OTP verified successfully, navigate to the Login screen
                                    Navigator.of(context).pushReplacement(
                                      SlidePageRoute(
                                        page: const LoginScreen(),
                                      ),
                                    );
                                    showCustomSnackBar(
                                      context,
                                      "Account is created successfully. You can login now.",
                                      Colors.green,
                                    );
                                  } else if (statusCode == 400) {
                                    // User already verified or bad request
                                    showCustomSnackBar(
                                      context,
                                      "User is already verified.",
                                      Colors.orange,
                                    );
                                  } else {
                                    // Handle other error cases
                                    showCustomSnackBar(
                                      context,
                                      "OTP verification failed. Please try again.",
                                      Colors.red,
                                    );
                                  }
                                }
                              : null, // Disable button if OTP is not valid
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Verify OTP",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        SizedBox(height: height * 0.03),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Didn't receive the OTP? ",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                              children: [
                                TextSpan(
                                  text: "Request New",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final statusCode = await authProvider
                                          .requestNewOTP(widget.email);
                                      if (statusCode == 200) {
                                        showCustomSnackBar(
                                          context,
                                          "A new OTP has been sent to ${widget.email}.",
                                          Colors.green,
                                        );
                                      } else if (statusCode == 400) {
                                        showCustomSnackBar(
                                            context,
                                            "Failed to send OTP. Please try again.",
                                            Colors.red);
                                      } else {
                                        showCustomSnackBar(
                                            context,
                                            "An error occurred. Please try again later.",
                                            Colors.red);
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
