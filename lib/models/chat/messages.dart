class Messages {
  String? id;
  String? conversationId;
  String senderId;
  String text;
  DateTime? createdAt;
  bool? isRead;
  Map<String, dynamic>? sender;

  Messages({
    this.id,
    this.conversationId,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.isRead,
    this.sender,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    // Add error handling and debugging
    try {
      // Handle the created_at field which might be a string or DateTime
      DateTime? parsedDate;
      if (json["created_at"] != null && json["created_at"] != 'null' && json["created_at"] != '') {
        try {
          parsedDate = DateTime.parse(json["created_at"]);
        } catch (e) {
          print('Error parsing date: ${json["created_at"]}');
          parsedDate = DateTime.now();
        }
      } else {
        // Default to current time if no date is provided
        parsedDate = DateTime.now();
      }

      // Process sender data if available
      Map<String, dynamic>? senderData;
      if (json["sender"] != null) {
        // Convert sender info to a consistent format
        senderData = {
          'id': json["sender"]["id"] ?? '',
          'name': json["sender"]["name"] ?? '',
          'avatar': json["sender"]["avatar"] ?? '',
        };
      }
      
      return Messages(
        id: json["id"] ?? '',
        conversationId: json["conversation_id"] ?? '',
        senderId: json["sender_id"] ?? '',
        text: json["text"] ?? '',
        createdAt: parsedDate,
        isRead: json["is_read"] ?? false,
        sender: senderData,
      );
    } catch (e) {
      print('Error parsing message: $e');
      print('JSON data: $json');
      // Return a fallback message
      return Messages(
        id: '',
        senderId: '',
        text: 'Error loading message',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "sender_id": senderId,
        "text": text,
        "created_at": createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "is_read": isRead ?? false,
        "sender": sender,
      };  
}
