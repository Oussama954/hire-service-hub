import 'package:e_commerce/models/auth/user_model.dart';
import 'package:e_commerce/models/chat/messages.dart';

class Conversation {
  String id;
  List<String> members;
  DateTime createdAt;
  List<Messages>? messages;
  UserModel? otherUser;

  Conversation({
    required this.id,
    required this.members,
    required this.createdAt,
    this.otherUser,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      List<String> memberIds = [];
      // Extract member IDs
      if (json["members"] != null) {
        memberIds = List<String>.from(
            json["members"].map((member) => member['id'] ?? ''));
      }

      return Conversation(
        id: json["id"],
        members: memberIds,
        createdAt: json["timestamp"] != null
            ? DateTime.parse(json["timestamp"])
            : (json["created_at"] != null
                ? DateTime.parse(json["created_at"])
                : DateTime.now()),
      );
    } catch (e) {
      print('Error parsing conversation: $e');
      print('JSON data: $json');
      throw e;
    }
  }

  factory Conversation.fromJsonGetConversations(Map<String, dynamic> json) {
    try {
      List<String> memberIds = [];
      // Extract member IDs
      if (json["members"] != null) {
        memberIds = List<String>.from(
            json["members"].map((member) => member['id'] ?? ''));
      }

      // Create temporary UserModel using available fields
      UserModel otherUser = UserModel(
        id: json["otherUser"]?["id"] ?? '',
        email: json["otherUser"]?["email"] ?? '',
        // Map the name field to firstName for compatibility
        firstName: json["otherUser"]?["name"] ?? '',
        profilePicture: json["otherUser"]?["avatar"] ?? '',
      );

      List<Messages> messagesList = [];
      if (json["messages"] != null) {
        messagesList = List<Messages>.from(
            json["messages"].map((x) => Messages.fromJson(x)));
      }

      return Conversation(
        id: json["id"],
        members: memberIds,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        otherUser: otherUser,
        messages: messagesList,
      );
    } catch (e) {
      print('Error parsing conversation: $e');
      print('JSON data: $json');
      return Conversation(
          id: json["id"] ?? 'unknown',
          members: [],
          createdAt: DateTime.now());
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "members": List<dynamic>.from(members.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
      };
}
