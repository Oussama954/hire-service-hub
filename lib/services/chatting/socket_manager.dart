import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/services/authentication/auth_servcies.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// A singleton class to manage socket connections globally across the app
class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  IO.Socket? _socket;
  bool _isInitialized = false;
  String? _currentUserId;

  bool get isInitialized => _isInitialized;
  IO.Socket? get socket => _socket;
  String? get currentUserId => _currentUserId;

  /// Initialize the socket connection with the current user's ID
  Future<void> initialize() async {
    if (_isInitialized && _socket?.connected == true) {
      print("🔄 Socket already initialized and connected");
      return;
    }

    // Get user ID from auth token
    final String? userId = await getUserIdFromToken();
    if (userId == null) {
      print("⚠️ Cannot initialize socket: No user ID available");
      return;
    }

    _currentUserId = userId;
    print("🔌 Initializing global socket for user: $_currentUserId");

    try {
      // Dispose any existing socket
      disposeSocket();

      // Create new socket
      _socket = IO.io(
        Constants.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setExtraHeaders({'userid': userId})
            .build(),
      );

      // Set up event handlers
      _setupEventHandlers();

      // Connect to server
      _socket?.connect();
      print("🔄 Global socket connection initiated");

      _isInitialized = true;
    } catch (e) {
      print("❌ Socket initialization error: $e");
      _isInitialized = false;
    }
  }

  void _setupEventHandlers() {
    // Connection events
    _socket?.onConnect((_) {
      print("✅ Global socket connected with ID: ${_socket?.id}");
      _socket?.emit("addUser", _currentUserId);
      print("👤 Registered user $_currentUserId with socket server");
    });

    // Error handling
    _socket?.onConnectError((error) {
      print("⚠️ Global socket connection error: $error");
    });

    _socket?.onError((error) {
      print("⚠️ Global socket error: $error");
    });

    // Handle disconnection
    _socket?.onDisconnect((_) {
      print("❌ Global socket disconnected");
      _isInitialized = false;
    });
  }

  void sendMessage({required String senderId, required String receiverId, required String text}) {
    if (!_isInitialized || _socket == null || !_socket!.connected) {
      print("⚠️ Cannot send message: Socket not initialized or connected");
      initialize(); // Try to reconnect
      return;
    }

    print("📤 Emitting message from $senderId to $receiverId: $text");
    _socket?.emit("sendMessage", {
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
    });
  }

  void disposeSocket() {
    if (_socket != null) {
      print("🔄 Disposing global socket connection");
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isInitialized = false;
    }
  }

  Future<String?> getUserIdFromToken() async {
    try {
      // You'll need to implement a way to get the user ID from the stored token
      final Map<String, dynamic>? userData = await AuthService.getUserDataFromToken();
      return userData?['userId'] as String?;
    } catch (e) {
      print("❌ Error getting user ID from token: $e");
      return null;
    }
  }
}
