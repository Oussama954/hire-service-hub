// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:e_commerce/main.dart';
import 'package:e_commerce/providers/notifications_count/notification_badge_provider.dart';
import 'package:e_commerce/screens/authentication/splash_screen/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await NotificationService.instance.showNotification(message);
  } catch (e) {
    print('Error in background handler: $e');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    try {
      print('NotificationService: Starting initialization...');
      
      // Firebase messaging background handler setup
      print('NotificationService: Setting up background message handler...');
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print('NotificationService: Requesting permissions...');
      await _requestPermission();

      print('NotificationService: Setting up flutter notifications...');
      await setupFlutterNotifications();

      print('NotificationService: Setting up message handlers...');
      await _setupMessageHandlers();

      // Get and save FCM token
      print('NotificationService: Getting FCM token...');
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      if (token != null) {
        await saveFcmToken(token);
      } else {
        print('Warning: FCM token is null');
      }

      // Set foreground notification presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('NotificationService: Subscribing to topics...');
      subscribeToTopic('all_devices');
      
      print('NotificationService: Initialization complete');
    } catch (e) {
      print('Error initializing notification service: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> saveFcmToken(String? token) async {
    if (token != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    try {
      print('Requesting notification permissions...');
      
      // Request FCM permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('FCM Permission status: ${settings.authorizationStatus}');
      
      // Android notification permissions are handled through the app's manifest
      // and requested when the notification channel is created
      print('Note: Android notification permissions are handled through the notification channel');
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  Future<void> setupFlutterNotifications() async {
    print('setupFlutterNotifications: Starting setup...');
    if (_isFlutterLocalNotificationsInitialized) {
      print('setupFlutterNotifications: Already initialized, returning');
      return;
    }

    try {
      print('setupFlutterNotifications: Creating Android channel...');
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      AndroidInitializationSettings initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');

      // ios setup
      DarwinInitializationSettings initializationSettingsDarwin =
          const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // flutter notification setup
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          try {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              ),
            );
          } catch (e) {
            print('Error handling notification response: $e');
          }
        },
      );

      _isFlutterLocalNotificationsInitialized = true;
    } catch (e) {
      print('Error setting up flutter notifications: $e');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      if (!_isFlutterLocalNotificationsInitialized) {
        print('Cannot show notification: Flutter local notifications not initialized');
        await setupFlutterNotifications();
      }
      
      // Extract notification data
      final notificationTitle = message.notification?.title ?? 
                               message.data['title'] ?? 
                               'New notification';
      final notificationBody = message.notification?.body ?? 
                              message.data['body'] ?? 
                              'You have a new notification';
      
      // Create Android-specific notification details with fuller configuration
      const android = AndroidNotificationDetails(
        'high_importance_channel', // channel Id
        'High Importance Notifications', // channel Name
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'New notification',
        showWhen: true,
        autoCancel: true,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        // Use default notification icon if none provided
        icon: 'mipmap/ic_launcher',
      );
      
      // Create iOS-specific notification details
      const iOS = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );
      
      // Combine platform-specific details
      const notificationDetails = NotificationDetails(
        android: android,
        iOS: iOS,
      );
      
      // Generate a unique notification ID
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Show the notification
      await _localNotifications.show(
        notificationId,
        notificationTitle,
        notificationBody,
        notificationDetails,
      );
      
      print('Successfully showed notification with title: $notificationTitle, body: $notificationBody');
    } catch (e) {
      print('Error showing notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> showTestNotification({String title = 'Test Notification', String body = 'This is a test notification'}) async {
    try {
      print('Showing test notification: $title - $body');
      if (!_isFlutterLocalNotificationsInitialized) {
        print('Local notifications not initialized, initializing now...');
        await setupFlutterNotifications();
      }
      
      // Create a test notification with high visibility settings
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Test notification',
        showWhen: true,
        autoCancel: true,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        icon: 'mipmap/ic_launcher', // Use app icon
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
      
      print('Test notification displayed successfully');
    } catch (e) {
      print('Error showing test notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _setupMessageHandlers() async {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) async {
        try {
          print('Received foreground message: ${message.messageId}');
          print('Message data: ${message.data}');
          print('Message notification: ${message.notification?.title} - ${message.notification?.body}');
          
          // Extract message data with fallbacks
          final type = message.data['type'] ?? 'default';
          final title = message.notification?.title ?? message.data['title'] ?? 'New notification';
          final body = message.notification?.body ?? message.data['body'] ?? 'You have a new notification';
          final time = DateTime.now().toString();

          final context = navigatorKey.currentState?.context;
          if (context != null) {
            // Update notification badge count
            context.read<NotificationBadgeProvider>().incrementCount(type);

            // Save notification if it's not a chat notification
            if (type != 'chat') {
              await context
                  .read<NotificationBadgeProvider>()
                  .saveNotifications(title, body, time);
            }
          } else {
            print('Warning: Context is null, cannot update notification badge');
            // Save notification anyway using the singleton pattern
            final prefs = await SharedPreferences.getInstance();
            final notification = {'title': title, 'body': body, 'time': time, 'type': type};
            final existingJson = prefs.getString('notifications') ?? '[]';
            List<dynamic> existingNotifications = jsonDecode(existingJson);
            existingNotifications.add(notification);
            await prefs.setString('notifications', jsonEncode(existingNotifications));
          }
          
          // Show the notification
          await showNotification(message);
        } catch (e) {
          print('Error handling foreground message: $e');
          print('Stack trace: ${StackTrace.current}');
        }
      });

      // background message
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        try {
          final type = message.data['type'] ?? 'default';
          final title = message.data['title'] ?? 'default';
          final body = message.data['body'] ?? 'default';
          final time = DateTime.now().toString();

          final context = navigatorKey.currentState?.context;
          if (context != null) {
            context.read<NotificationBadgeProvider>().resetCount(type);
            if (type != 'chat') {
              await context
                  .read<NotificationBadgeProvider>()
                  .saveNotifications(title, body, time);
            }
          }

          _handleBackgroundMessage(message);
        } catch (e) {
          print('Error handling background message: $e');
        }
      });

      // opened app
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }
    } catch (e) {
      print('Error setting up message handlers: $e');
    }
  }

  void subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('Subscribed to $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    try {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
      );
    } catch (e) {
      print('Error handling background message: $e');
    }
  }
}
