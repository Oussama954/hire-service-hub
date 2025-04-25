import 'dart:async';
import 'package:e_commerce/common/buttons/custom_elevated_button.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/bottom_navigation/navigation_provider.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/notifications_count/notification_badge_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/screens/chatting/message_screen.dart';
import 'package:e_commerce/screens/home/categories/categories_detail_screen.dart';
import 'package:e_commerce/screens/home/categories/category_search_detail_screen.dart';
import 'package:e_commerce/screens/home/categories/category_widget.dart';
import 'package:e_commerce/screens/home/services/small_service_card_widget.dart';
import 'package:e_commerce/screens/notifications/notifications.dart';
import 'package:e_commerce/screens/service/service_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';

import '../../providers/chatting/chatting_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<String> images = [
    'assets/bg/bg-hero1.webp',
    'assets/bg/bg-hero2.webp',
    'assets/bg/bg-hero3.webp',
    'assets/bg/bg-hero4.webp',
    'assets/bg/bg-hero5.webp',
  ];
  
  // For auto-scrolling carousel
  late PageController _carouselController;
  Timer? _autoScrollTimer;
  int _currentCarouselPage = 0;
  final int _totalAdItems = 3; // The number of ad items in the carousel

  @override
  void initState() {
    super.initState();
    
    // Initialize PageController for the ad carousel
    _carouselController = PageController(initialPage: 0, viewportFraction: 1.0);
    
    // Start auto-scrolling timer
    _startAutoScroll();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).clearServicesList();
      Provider.of<CategoryProvider>(context, listen: false).resetCategories();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
      Provider.of<ChattingProvider>(context, listen: false)
          .fetchConversations();
      Provider.of<AuthenticationProvider>(context, listen: false)
          .getProfileCompletion();
    });
  }

  @override
  void dispose() {
    // Cancel the auto-scroll timer
    _autoScrollTimer?.cancel();
    _carouselController.dispose();
    searchController.dispose();
    super.dispose();
  }
  
  // Start auto-scrolling carousel every 3 seconds
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentCarouselPage < _totalAdItems - 1) {
        _currentCarouselPage++;
      } else {
        _currentCarouselPage = 0;
      }
      
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentCarouselPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final chatBadgeCount =
        context.watch<NotificationBadgeProvider>().getNotificationCount('chat');
    final orderBadgeCount = context
        .watch<NotificationBadgeProvider>()
        .getNotificationCount('order');
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
        
    return Scaffold(
      appBar: AppBar(
        // Removed title for more minimal UI
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Messages button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(IconlyLight.message),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const MessagesScreen()),
                  ).then((_) async {
                    await context
                        .read<NotificationBadgeProvider>()
                        .resetCount('chat');
                  });
                },
              ),
              if (chatBadgeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$chatBadgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Notifications button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(IconlyLight.notification),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const NotificationsScreen()),
                  ).then((_) async {
                    await context
                        .read<NotificationBadgeProvider>()
                        .resetCount('order');
                  });
                },
              ),
              if (orderBadgeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$orderBadgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Modern Advertisement Carousel Section
              Container(
                height: 190, // Increased height to prevent overflow
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                  boxShadow: isDarkMode ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _carouselController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCarouselPage = index;
                          });
                        },
                        children: [
                          // Ad 1: Special Promotion
                          _buildAdItem(
                            title: "50% OFF All Services",
                            subtitle: "Limited time offer for first-time users",
                            color: Color(0xFF3A5ACD),
                            gradientColors: [Color(0xFF3A5ACD), Color(0xFF1F2B8B)],
                            icon: Icons.celebration_outlined,
                          ),
                          // Ad 2: Feature Highlight
                          _buildAdItem(
                            title: "Get It Done Right",
                            subtitle: "Professional services at your fingertips",
                            color: Color(0xFF09B65A),
                            gradientColors: [Color(0xFF09B65A), Color(0xFF076E38)],
                            icon: Icons.engineering_outlined,
                          ),
                          // Ad 3: New Services
                          _buildAdItem(
                            title: "New Home Services",
                            subtitle: "Find trusted professionals for your home",
                            color: Color(0xFFD94C00),
                            gradientColors: [Color(0xFFD94C00), Color(0xFF8C3100)],
                            icon: Icons.home_repair_service_outlined,
                          ),
                        ],
                      ),
                    ),
                    // Page indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalAdItems,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentCarouselPage == index
                                ? AppTheme.primaryColor
                                : (isDarkMode ? Colors.white24 : Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                  boxShadow: isDarkMode ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const ServiceScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Search for services...",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),

              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categories",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const CategoriesDetailScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        backgroundColor: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.08),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "All",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              
              // Horizontal scrolling categories with modern design
              SizedBox(
                height: 110, // Slightly taller for better visuals
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2.0,
                          ),
                        ),
                      );
                    }

                    if (categoryProvider.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black12 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: isDarkMode ? Colors.white60 : AppTheme.error.withOpacity(0.7),
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categoryProvider.errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (categoryProvider.categories.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black12 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No categories found",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryProvider.categories.length,
                      itemExtent: 90, // Fixed width for each item
                      itemBuilder: (context, index) {
                        return CategoryItem(
                          category: categoryProvider.categories[index],
                          width: 90, // Slightly wider for better visuals
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Services Section with modern styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Featured Services",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const ServiceScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        backgroundColor: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.08),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "All",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<ServiceProvider>(
                  builder: (context, serviceProvider, child) {
                    if (serviceProvider.isLoading) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading services...",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    if (serviceProvider.errorMessage != null &&
                        serviceProvider.services.isEmpty) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppTheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              serviceProvider.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                serviceProvider.fetchServices();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radius_md),
                                ),
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    }

                    if (serviceProvider.services.isEmpty) {
                      return Container(
                        height: 240,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black12 : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                          boxShadow: isDarkMode ? null : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.business_center_outlined,
                                size: 40,
                                color: isDarkMode ? Colors.white60 : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No services available yet",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Services will appear here once added",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (authProvider.user?.role?.title == "service_provider")
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page: const ServiceScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radius_md),
                                    ),
                                  ),
                                  child: Text(
                                    "Create Service",
                                    style: GoogleFonts.inter(
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

                    // Enhanced grid with modern styling
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75, // Taller cards for better visuals
                      ),
                      itemCount: serviceProvider.services.length > 4
                          ? 4 
                          : serviceProvider.services.length,
                      itemBuilder: (context, index) {
                        return SmallServiceCard(
                          service: serviceProvider.services[index],
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build advertisement carousel items
  Widget _buildAdItem({
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
      ),
      child: Stack(
        children: [
          // Background pattern for visual interest
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard({required IconData icon, required String title, required Color color}) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDarkMode ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
