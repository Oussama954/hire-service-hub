import 'package:e_commerce/providers/notifications_count/notification_badge_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<NotificationBadgeProvider>(context);
    // Make sure to get the list of notifications using the getter
    final notifications = provider.orderNotifications;
    
    final bool hasNotifications = notifications.isNotEmpty;

    // Sort the notifications by 'time' field (most recent first)
    if (hasNotifications) {
      notifications.sort((a, b) {
        try {
          DateTime timeA = DateTime.parse(a['time'] ?? DateTime.now().toString());
          DateTime timeB = DateTime.parse(b['time'] ?? DateTime.now().toString());
          return timeB.compareTo(timeA); // Descending order
        } catch (e) {
          print('Error sorting notifications: $e');
          return 0;
        }
      });
    }
    
    print('Building notifications screen with ${notifications.length} notifications');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "Notifications",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: hasNotifications
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(
                  name: notification['title'] ?? 'Notification',
                  message: notification['body'] ?? 'No content',
                  time: notification['time'] ?? DateTime.now().toString(),
                  avatarColor: AppTheme.fMainColor,
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet!",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You'll see updates about your orders and services here",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
                    ),
                  ),

                ],
              ),
            ),
    );
  }

  Widget _buildNotificationItem({
    required String name,
    required String message,
    required String time,
    required Color avatarColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor.withOpacity(0.9),
              child: const Icon(Icons.notifications, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification title
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Notification body
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatTime(time),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
