import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/bottom_navigation/navigation_provider.dart';
import 'package:e_commerce/providers/notifications_count/notification_badge_provider.dart';
import 'package:e_commerce/screens/home/home_screen.dart';
import 'package:e_commerce/screens/orders/orders_screen.dart';
import 'package:e_commerce/screens/profile/profile_screen.dart';
import 'package:e_commerce/screens/service/service_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final orderBadgeCount = context
        .watch<NotificationBadgeProvider>()
        .getNotificationCount('order');

    return Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
      return Scaffold(
        extendBody: true,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            // Removed shadow for a more minimal look like the header
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black 
              : Colors.white,
          ),
          child: ClipRRect(
            // Reduced border radius to be more subtle
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black 
                : Colors.white,
              currentIndex: navigationProvider.currentIndex,
              type: BottomNavigationBarType.fixed,
              // Exactly match header icons style
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
              // Keep labels for better usability
              selectedFontSize: 10,
              unselectedFontSize: 10,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) async {
                if (index == 2) {
                  await context
                      .read<NotificationBadgeProvider>()
                      .resetCount('order');
                }
                navigationProvider.updateIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(IconlyLight.home, size: 24), // Standard icon size to match header exactly
                  activeIcon: Icon(IconlyBold.home, size: 24, color: AppTheme.primaryColor),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(IconlyLight.category, size: 24), // Standard icon size to match header exactly
                  activeIcon: Icon(IconlyBold.category, size: 24, color: AppTheme.primaryColor),
                  label: 'Services',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(IconlyLight.bag, size: 24), // Standard icon size to match header exactly
                      if (orderBadgeCount > 0)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.error, // Using error color to match header badge style
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                orderBadgeCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(IconlyBold.bag, size: 20, color: AppTheme.primaryColor),
                      if (orderBadgeCount > 0)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.error, // Using error color to match header badge style
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                orderBadgeCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: authProvider.user?.role?.title == "service_provider"
                      ? 'Orders'
                      : 'My Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(IconlyLight.profile, size: 24), // Standard icon size to match header exactly
                  activeIcon: Icon(IconlyBold.profile, size: 24, color: AppTheme.primaryColor),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
        body: PageView(
          controller: navigationProvider.pageController,
          onPageChanged: (index) {
            navigationProvider.updateIndex(index);
          },
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            ServiceScreen(),
            OrdersScreen(),
            ProfileScreen(),
          ],
        ),
      );
    });
  }
}
