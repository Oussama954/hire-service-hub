import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationBadgeProvider with ChangeNotifier {
  final Map<String, int> _notificationCounts = {};
  List<Map<String, dynamic>> _notifications = [];

  NotificationBadgeProvider() {
    // Load notifications when provider is created
    loadNotification();
  }
  
  // Static method to increment notification count without requiring a Provider instance
  static Future<void> incrementCountGlobally(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('${type}_notification_count') ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt('${type}_notification_count', newCount);
      print('📈 Globally incremented $type notification count to $newCount');
    } catch (e) {
      print('❌ Error incrementing global notification count: $e');
    }
  }

  int getNotificationCount(String type) => _notificationCounts[type] ?? 0;

  List<Map<String, dynamic>> get orderNotifications => _notifications;

  Future<void> loadNotificationCount(String type) async {
    final prefs = await SharedPreferences.getInstance();
    _notificationCounts[type] = prefs.getInt('${type}_notification_count') ?? 0;
    notifyListeners();
  }

  Future<void> incrementCount(String type) async {
    _notificationCounts[type] = (_notificationCounts[type] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        '${type}_notification_count', _notificationCounts[type]!);
    notifyListeners();
  }

  Future<void> resetCount(String type) async {
    _notificationCounts[type] = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${type}_notification_count', 0);
    notifyListeners();
  }

  Future<void> saveNotifications(String title, String body, String time) async {
    try {
      print('Saving notification: $title - $body');
      final prefs = await SharedPreferences.getInstance();
      final notification = {'title': title, 'body': body, 'time': time};
      
      // Add to in-memory list
      _notifications.add(notification);
      
      // Load existing notifications first
      List<Map<String, dynamic>> existingNotifications = [];
      final existingData = prefs.getString('notifications');
      if (existingData != null) {
        try {
          final decoded = jsonDecode(existingData);
          if (decoded is List) {
            existingNotifications = List<Map<String, dynamic>>.from(
              decoded.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
            );
          }
        } catch (e) {
          print('Error decoding existing notifications: $e');
        }
      }
      
      // Add new notification and save the entire list
      existingNotifications.add(notification);
      final notificationsJson = jsonEncode(existingNotifications);
      await prefs.setString('notifications', notificationsJson);
      
      print('Saved notification. Total notifications: ${existingNotifications.length}');
      notifyListeners();
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  Future<void> loadNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(notificationsJson);
          if (decoded is List) {
            _notifications = List<Map<String, dynamic>>.from(
              decoded.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
            );
            print('Loaded ${_notifications.length} notifications from storage');
          } else {
            print('Decoded notifications is not a list: $decoded');
            _notifications = [];
          }
        } catch (e) {
          print('Error parsing notifications JSON: $e');
          _notifications = [];
        }
      } else {
        print('No notifications found in storage');
        _notifications = [];
      }
      
      // Load notification counts for different types
      await loadNotificationCount('chat');
      await loadNotificationCount('order');
      await loadNotificationCount('default');
      
      
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = [];
      notifyListeners();
    }
  }
  

}
