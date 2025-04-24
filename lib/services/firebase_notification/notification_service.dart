// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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
      
      print('NotificationService: Setting up background message handler...');
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print('NotificationService: Requesting permissions...');
      await _requestPermission();

      print('NotificationService: Setting up message handlers...');
      await _setupMessageHandlers();

      print('NotificationService: Setting up flutter notifications...');
      await setupFlutterNotifications();

      print('NotificationService: Getting FCM token...');
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      await saveFcmToken(token);

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
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('Permission status: ${settings.authorizationStatus}');
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
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    try {
      //foreground message
      FirebaseMessaging.onMessage.listen((message) async {
        try {
          final type = message.data['type'] ?? 'default';
          final title = message.data['title'] ?? 'default';
          final body = message.data['body'] ?? 'default';
          final time = DateTime.now().toString();

          final context = navigatorKey.currentState?.context;
          if (context != null) {
            context.read<NotificationBadgeProvider>().incrementCount(type);

            if (type != 'chat') {
              await context
                  .read<NotificationBadgeProvider>()
                  .saveNotifications(title, body, time);
            }
          }
          await showNotification(message);
        } catch (e) {
          print('Error handling foreground message: $e');
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
