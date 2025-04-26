import 'dart:convert';
import 'package:e_commerce/models/chat/conversation.dart';
import 'package:e_commerce/models/chat/messages.dart';
import 'package:e_commerce/services/authentication/auth_servcies.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:http/http.dart' as http;

class ChatService {
  Map<String, String> _generateHeaders({String? accessToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<http.Response> createConversation(String receiverId) async {
    String? accessToken = await AuthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }
    final url = Uri.parse('${Constants.baseUrl}${Constants.conversation}');

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(accessToken: accessToken),
        body: jsonEncode({
          "receiver_id": receiverId,
        }),
      );
      return response;
    } catch (e) {
      print('Error creating conversation: $e');
      throw Exception('Failed to create conversation');
    }
  }

  Future<List<Conversation>> getAllConversations() async {
    String? accessToken = await AuthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }
    final response = await http.get(
        Uri.parse('${Constants.baseUrl}${Constants.conversation}'),
        headers: _generateHeaders(accessToken: accessToken));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        List conversations = data['data'];

        return conversations
            .map((conv) => Conversation.fromJsonGetConversations(conv))
            .toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<Messages?> sendMessage(String conversationId, String text) async {
    String? accessToken = await AuthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }
    final url = Uri.parse('${Constants.baseUrl}${Constants.messages}');

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(accessToken: accessToken),
        body: json.encode({
          'conversation_id': conversationId,
          'text': text,
        }),
      );

      // Handle both 200 and 201 as success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Message sent successfully: ${data['message']}');
        return Messages.fromJson(data['data'][0]);
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Method to get messages by conversation ID
  Future<List<Messages>> getMessagesByConversationId(
      String conversationId) async {
    String? accessToken = await AuthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }
    final url =
        Uri.parse('${Constants.baseUrl}${Constants.messages}/$conversationId');
    final response = await http.get(
      url,
      headers: _generateHeaders(accessToken: accessToken),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // If the response contains data, map it to the Message model, else return an empty list
      if (data['data'] != null && data['data'].isNotEmpty) {
        List<Messages> messages = (data['data'] as List)
            .map((messageData) => Messages.fromJson(messageData))
            .toList();
            
        // Sort messages by createdAt date (oldest first)
        // This ensures messages appear chronologically in the ListView
        // with newest messages at the bottom
        messages.sort((a, b) => a.createdAt != null && b.createdAt != null
            ? a.createdAt!.compareTo(b.createdAt!)
            : 0);
            
        return messages;
      } else {
        return []; // Return an empty list if no messages are found
      }
    } else {
      // Handle the error (you can throw an exception, show an error message, etc.)
      return [];
    }
  }
}
