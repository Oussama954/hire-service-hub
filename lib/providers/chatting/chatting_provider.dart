import 'dart:convert';
import 'package:e_commerce/models/chat/conversation.dart';
import 'package:e_commerce/models/chat/messages.dart';
import 'package:e_commerce/providers/notifications_count/notification_badge_provider.dart';
import 'package:e_commerce/services/chatting/chatting_service.dart';
import 'package:e_commerce/services/chatting/socket_manager.dart';
import 'package:e_commerce/services/firebase_notification/notification_service.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChattingProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketManager _socketManager = SocketManager(); // Use the singleton
  
  Conversation? _conversation;
  Conversation? get conversation => _conversation;
  String? errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isConversationFetchingLoading = false;
  get isConversationFetchingLoading => _isConversationFetchingLoading;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  List<Messages> _messages = [];
  List<Messages> get messages => _messages;
  
  // Use the initialized state from the SocketManager
  bool get isSocketInitialized => _socketManager.isInitialized;

  /// Initialize socket for chat and set up message event listeners
  void initializeSocket(String userId) async {
    // Initialize the global socket if needed
    if (!_socketManager.isInitialized) {
      print("✅ Initializing global socket for chat by user: $userId");
      await _socketManager.initialize();
    }
    
    // Set up message event listeners
    setupMessageListeners();
  }
  
  /// Set up message listeners on the global socket
  void setupMessageListeners() {
    final socket = _socketManager.socket;
    if (socket == null) {
      print("⚠️ Cannot setup listeners: socket is null");
      return;
    }
    
    // Listen for incoming messages
    socket.on("getMessage", (data) {
      print("📩 Received message: $data");
      if (data != null) {
        try {
          // Extract message data
          final String senderId = data['senderId'] ?? "";
          final String messageText = data['text'] ?? "[Message content missing]";
          
          // Create message object
          final newMessage = Messages(
            id: UniqueKey().toString(),
            conversationId: _conversation?.id ?? "",
            senderId: senderId,
            text: messageText,
            createdAt: DateTime.now(),
          );
          
          // Add to local messages list
          _messages.add(newMessage);
          fetchConversations();
          notifyListeners();
          
          // Trigger a local notification for the received message
          _triggerMessageNotification(senderId, messageText);
        } catch (e) {
          print("Error processing incoming message: $e");
        }
      }
    });
    
    // Monitor user list updates from server
    socket.on("getUsers", (userList) {
      print("👥 Online users updated: $userList");
    });
    
    // Listen for system notifications (bookings, services, etc)
    socket.on("notification", (data) {
      print("🔔 Received system notification: $data");
      if (data != null) {
        try {
          // Handle various notification types
          final String type = data['type'] ?? "default";
          final String title = data['title'] ?? "New Notification";
          final String body = data['body'] ?? "You have a new notification";
          
          // Create notification data
          final notificationData = Map<String, dynamic>.from(data);
          
          // Create a RemoteMessage to display with FlutterLocalNotifications
          final remoteMessage = RemoteMessage(
            notification: RemoteNotification(
              title: title,
              body: body,
            ),
            data: notificationData,
          );
          
          // Display notification using NotificationService
          NotificationService.instance.showNotification(remoteMessage);
          
          // Update notification count
          NotificationBadgeProvider.incrementCountGlobally(type);
          
          // Save to notification history
          _saveNotificationToHistory(title, body, type);
          
        } catch (e) {
          print("❌ Error processing system notification: $e");
        }
      }
    });
  }
  
  /// Trigger a local notification for an incoming message
  void _triggerMessageNotification(String senderId, String messageText) async {
    try {
      // Default sender name
      String senderName = "New message";
      
      // Try to get sender name from otherUser if available
      if (_conversation != null && _conversation!.otherUser != null) {
        if (_conversation!.otherUser!.id == senderId) {
          // Handle nullable name property with null-aware operator
          senderName = _conversation!.otherUser!.name ?? "User";
        }
      }
      
      // Create notification data
      final notificationData = {
        "type": "chat",
        "title": senderName,
        "body": messageText,
        "senderId": senderId,
        "conversationId": _conversation?.id,
        "click_action": "CHAT_MESSAGE"
      };

      print("Creating notification for message from $senderName");
      
      // Create a RemoteMessage to display with FlutterLocalNotifications
      final remoteMessage = RemoteMessage(
        notification: RemoteNotification(
          title: senderName,
          body: messageText,
        ),
        data: notificationData,
      );
      
      // Display notification using NotificationService
      await NotificationService.instance.showNotification(remoteMessage);
      
      // Update notification count using the static method
      NotificationBadgeProvider.incrementCountGlobally("chat");
      
      // Save notification to message history
      final prefs = await SharedPreferences.getInstance();
      final notification = {
        'title': senderName, 
        'body': messageText, 
        'time': DateTime.now().toString(),
        'type': 'chat'
      };
      
      // Load existing notifications
      final existingJson = prefs.getString('notifications') ?? '[]';
      List<dynamic> existingNotifications = [];
      try {
        existingNotifications = jsonDecode(existingJson);
      } catch (e) {
        print('Error decoding notifications: $e');
        existingNotifications = [];
      }
      
      // Add notification and save
      existingNotifications.add(notification);
      await prefs.setString('notifications', jsonEncode(existingNotifications));
      print('Saved chat notification to history');
      
    } catch (e) {
      print("❌ Error triggering message notification: $e");
    }
  }

  // Start a conversation by calling the API and initializing the socket
  Future<int> startConversation(String receiverId, String authUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.createConversation(receiverId);

      // Handle both 200 and 201 as success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Conversation response: $responseData");

        if (responseData['success'] == true) {
          _conversation = Conversation.fromJson(responseData['data'][0]);
          print("Conversation members: ${_conversation!.members}");
        } else {
          errorMessage = responseData['message'];
          notifyListeners();
        }
      } else if (response.statusCode == 400) {
        errorMessage =
            "You are already registered for a conversation with this user.";
        notifyListeners();
      } else {
        errorMessage =
            "Failed to create conversation. Status code: ${response.statusCode}";
        notifyListeners();
      }
      return response.statusCode;
    } catch (e) {
      errorMessage = "An error occurred: $e";
      notifyListeners();
      return 500;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String conversationId, String text, String senderId,
      String receiverId) async {
    try {
      // Make sure receiverId is not empty
      if (receiverId.isEmpty) {
        print("⚠️ Cannot send message: receiverId is empty");
        errorMessage = "Cannot identify recipient";
        notifyListeners();
        return;
      }

      print("📤 Sending message to $receiverId: $text");

      // First add message to the database via API
      final responseMessage =
          await _chatService.sendMessage(conversationId, text);

      if (responseMessage != null) {
        // Add to local messages list
        _messages.add(responseMessage);
        notifyListeners();

        // Send via socket for real-time delivery
        print("Emitting socket message from $senderId to $receiverId");
        
        // Use the global socket manager to send the message
        _socketManager.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          text: text,
        );
        
        // If socket isn't initialized, try to initialize it
        if (!_socketManager.isInitialized) {
          print("⚠️ Socket is not initialized! Attempting to initialize...");
          _socketManager.initialize();
        }
      } else {
        print("❌ API message sending failed");
        errorMessage = "Failed to send message.";
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error sending message: $e");
      errorMessage = "Error sending message: $e";
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    notifyListeners();
    List<Messages> loadedMessages =
        await _chatService.getMessagesByConversationId(conversationId);

    _messages = loadedMessages;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchConversations() async {
    _isConversationFetchingLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getAllConversations();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load conversations: $e';
      notifyListeners();
    } finally {
      _isConversationFetchingLoading = false;
    }
  }

  /// Remove message listeners from the chat screen
  /// Note: This doesn't disconnect the socket since other parts of the app may use it
  void disconnectSocket() {
    print("Removing chat-specific socket listeners");
    final socket = _socketManager.socket;
    if (socket != null) {
      // Just remove our specific listeners
      socket.off("getMessage");
      socket.off("getUsers");
      // We don't remove the notification listener as it should stay active
      print("Chat event listeners removed");
    }
    notifyListeners();
  }
  
  // Helper to save notification to history
  Future<void> _saveNotificationToHistory(String title, String body, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notification = {
        'title': title, 
        'body': body, 
        'time': DateTime.now().toString(),
        'type': type
      };
      
      // Load existing notifications
      final existingJson = prefs.getString('notifications') ?? '[]';
      List<dynamic> existingNotifications = [];
      try {
        existingNotifications = jsonDecode(existingJson);
      } catch (e) {
        print('Error decoding notifications: $e');
        existingNotifications = [];
      }
      
      // Add notification and save
      existingNotifications.add(notification);
      await prefs.setString('notifications', jsonEncode(existingNotifications));
      print('Saved $type notification to history');
    } catch (e) {
      print('Error saving notification to history: $e');
    }
  }
}
