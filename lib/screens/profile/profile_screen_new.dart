import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/common/dialog_box/logout_dialogbox.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/screens/profile/more_screens/account_screens/account_screen.dart';
import 'package:e_commerce/screens/profile/profile_updation_screens/profile_details_screen.dart';
import 'package:e_commerce/screens/service/create_services_screen.dart' as create_screen;
import 'package:e_commerce/screens/service/my_services_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isServiceProvider = false;
  bool _isLoading = false;
  
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppTheme.darkGrey,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDarkMode ? Colors.white70 : AppTheme.darkGrey.withOpacity(0.7),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    SlidePageRoute(page: const AccountScreen()),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Container(
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(authProvider),
                    _buildProfileCompletionCard(authProvider),
                    _buildSellerModeToggle(context, authProvider),
                    if (authProvider.user?.role?.title == "service_provider")
                      _buildServiceProviderOptions(authProvider, context),
                    _buildAccountSettings(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Profile header with user info and avatar
  Widget _buildProfileHeader(AuthenticationProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black
            : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.7),
                      AppTheme.secondaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: authProvider.user?.profilePicture != null
                        ? CachedNetworkImage(
                            imageUrl: authProvider.user!.profilePicture!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 30.0,
                                height: 30.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              debugPrint('Image load error: $error');
                              return Image.asset('assets/images/default-user.jpg');
                            },
                          )
                        : Image.asset('assets/images/default-user.jpg'),
                  ),
                ),
              ),
              
              // Edit button overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: const ProfileDetailsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // User name
          Text(
            authProvider.user?.firstName ?? "User",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          
          // User email
          Text(
            authProvider.user?.email ?? "email@example.com",
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          
          // User Role Badge
          if (authProvider.user?.role?.title != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                authProvider.user!.role!.title == "service_provider" 
                    ? "Service Provider" 
                    : "Customer",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Profile completion card with progress bar
  Widget _buildProfileCompletionCard(AuthenticationProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.05) 
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Text(
                "Profile Completion",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              // Percentage display
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: authProvider.profileCompletion?.userCompletionPercentage == 100 
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (authProvider.profileCompletion?.userCompletionPercentage == 100 
                          ? Colors.green : AppTheme.primaryColor).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "${authProvider.profileCompletion?.userCompletionPercentage}%",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress info
          Text(
            authProvider.profileCompletion?.userCompletionPercentage == 100
                ? "Your profile is complete! Clients can now find you easily."
                : "Complete your profile to increase visibility to potential clients.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Stack(
            children: [
              // Background track
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress indicator
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final progressWidth = maxWidth * 
                      ((authProvider.profileCompletion?.userCompletionPercentage ?? 0) / 100);
                  
                  return Container(
                    height: 8,
                    width: progressWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: authProvider.profileCompletion?.userCompletionPercentage == 100 
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (authProvider.profileCompletion?.userCompletionPercentage == 100 
                              ? Colors.green : AppTheme.primaryColor).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          if (authProvider.profileCompletion?.userCompletionPercentage != 100) ...[  
            const SizedBox(height: 16),
            // Complete Profile Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  SlidePageRoute(
                    page: const ProfileDetailsScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.05) 
                      : AppTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.1) 
                        : AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Complete Your Profile",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode 
                          ? AppTheme.primaryColor.withOpacity(0.9) 
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Seller Mode Toggle Section
  Widget _buildSellerModeToggle(BuildContext context, AuthenticationProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.05) 
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.secondaryColor.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_center, 
                      color: isDarkMode ? Colors.white : AppTheme.primaryColor, 
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Service Provider Mode",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
              Selector<AuthenticationProvider, String?>(
                selector: (_, provider) => provider.user?.role?.title,
                builder: (context, roleTitle, child) {
                  final isSeller = roleTitle == "service_provider";
                  return Switch(
                    value: isSeller,
                    activeColor: AppTheme.primaryColor,
                    activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                    inactiveThumbColor: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                    inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                    onChanged: (value) async {
                      if (value != isSeller) {
                        final statusCode = await Provider.of<AuthenticationProvider>(context, listen: false).switchRole();
                        if (statusCode == 200 && context.mounted) {
                          showCustomSnackBar(
                            context,
                            "Role switched successfully!",
                            Colors.green,
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "Switch to service provider mode to create and manage your services.",
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Service Provider Options Section
  Widget _buildServiceProviderOptions(AuthenticationProvider authProvider, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
          child: Text(
            "Services Management",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
            ),
          ),
        ),
        
        // Create New Service Button
        Container(
          margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: isDarkMode ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (authProvider.profileCompletion?.userCompletionPercentage.toString() != "100") {
                  showCustomSnackBar(
                      context,
                      'Please complete your profile to create a new service.',
                      Colors.red);
                  return;
                } else {
                  Navigator.of(context).push(
                    SlidePageRoute(page: const create_screen.CreateServiceScreen()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.secondaryColor.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconlyLight.plus, 
                        size: 20,
                        color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a New Service',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a new service offering to your profile',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // My Services Button
        Container(
          margin: const EdgeInsets.only(top: 12, left: 20, right: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: isDarkMode ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (authProvider.profileCompletion?.userCompletionPercentage.toString() != "100") {
                  showCustomSnackBar(
                      context,
                      'Please complete your profile to view your services.',
                      Colors.red);
                } else {
                  Navigator.of(context).push(
                    SlidePageRoute(page: const MyServicesScreen()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.secondaryColor.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconlyLight.paper, 
                        size: 20,
                        color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Services',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage all your service listings',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Account Settings Section
  Widget _buildAccountSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 12),
          child: Text(
            "Account Settings",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
            ),
          ),
        ),
        
        // Account Settings Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: isDarkMode ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  SlidePageRoute(
                    page: const AccountScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.secondaryColor.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconlyLight.profile, 
                        size: 20,
                        color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your account settings and preferences',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Contact Support Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: isDarkMode ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Add support contact functionality here
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.secondaryColor.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconlyLight.call, 
                        size: 20,
                        color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Support',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get help with any issues or questions',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Logout Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(isDarkMode ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showLogoutDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.powerOff,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Bottom spacing
        const SizedBox(height: 24),
      ],
    );
  }
}
