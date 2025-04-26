import 'package:e_commerce/common/buttons/icon_gradient_button.dart';
import 'package:e_commerce/models/chat/conversation.dart';
import 'package:e_commerce/models/chat/messages.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/chatting/chatting_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the socket connection with the authenticated user ID only if it's not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider =
          Provider.of<ChattingProvider>(context, listen: false);
      final authUserId =
          Provider.of<AuthenticationProvider>(context, listen: false).user!.id;

      // Load messages
      chatProvider
          .loadMessages(widget.conversation.id)
          .then((_) => _scrollToBottom());

      // Only initialize socket if not already initialized
      if (!chatProvider.isSocketInitialized) {
        chatProvider.initializeSocket(authUserId!);
      }

      // Scroll to the bottom whenever new messages arrive
      chatProvider.addListener(() {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final chatProvider = Provider.of<ChattingProvider>(context, listen: false);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect socket when the app is in the background
      chatProvider.disconnectSocket();
    }

    if (state == AppLifecycleState.resumed) {
      // Only initialize socket if it's not already initialized
      if (!chatProvider.isSocketInitialized) {
        final authUserId =
            Provider.of<AuthenticationProvider>(context, listen: false)
                .user!
                .id;
        chatProvider.initializeSocket(authUserId!);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Scroll to the bottom to see newest messages
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didpop) {
        //Disconnect the socket before navigating back
        final chatProvider =
            Provider.of<ChattingProvider>(context, listen: false);
        chatProvider.disconnectSocket();
      },
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                final chatProvider =
                    Provider.of<ChattingProvider>(context, listen: false);
                chatProvider.disconnectSocket();
                Navigator.pop(context);
              },
              child: const Icon(IconlyLight.arrow_left),
            ),
            forceMaterialTransparency: true,
            title: Text(
              // Handle null firstName or empty name by using name field first, then defaulting
              widget.conversation.otherUser?.firstName ??
                  widget.conversation.otherUser?.name ??
                  "Unknown User",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Consumer2<ChattingProvider, AuthenticationProvider>(
              builder: (context, chatProvider, authProvider, _) {
                // Retrieve the authenticated user's ID
                final authUserId = authProvider.user!.id;
                // Get the receiver's ID by finding the ID in members that isn't the auth user's ID
                final receiverId = widget.conversation.members
                    .firstWhere((id) => id != authUserId);

                return Column(
                  children: [
                    // Message area (expanded to fill available space)
                    Expanded(
                      child: chatProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : chatProvider.messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 50,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white54
                                              : Colors.black38),
                                      const SizedBox(height: 16),
                                      Text("No messages yet!",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          )),
                                      const SizedBox(height: 8),
                                      Text("Start the conversation",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white54
                                                : Colors.black38,
                                          )),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  // No need for reverse: true when messages are already sorted correctly
                                  padding: const EdgeInsets.only(bottom: 10), 
                                  itemCount: chatProvider.messages.length,
                                  itemBuilder: (context, index) {
                                    // Access messages with most recent ones at the bottom
                                    final message = chatProvider.messages[index];
                                    final isMyMessage = message.senderId == authUserId;
                                    return _buildMessageBubble(message, isMyMessage);
                                  },
                                ),
                    ),
                    
                    // Optional debug info - display recipient ID
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Conversation with: $receiverId',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                    
                    // Message input at the bottom
                    _buildMessageInput(chatProvider, authUserId!, receiverId),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Messages message, bool isMyMessage) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Safely handle potentially null or empty text
    final messageText = message.text.isEmpty ? "[Empty message]" : message.text;
    
    // Safely handle potentially null createdAt values
    final messageTime = message.createdAt != null 
        ? calculateTimeForChatMessage(message.createdAt.toString())
        : 'Just now';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit bubble width
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: isMyMessage 
                ? AppTheme.fMainColor 
                : isDarkMode ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMyMessage
                  ? const Radius.circular(18)
                  : const Radius.circular(0),
              bottomRight: isMyMessage
                  ? const Radius.circular(0)
                  : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageText,
                style: TextStyle(
                  color: isMyMessage 
                      ? Colors.white 
                      : isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                messageTime,
                style: TextStyle(
                  color: isMyMessage 
                      ? Colors.white70 
                      : isDarkMode ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(
      ChattingProvider chatProvider, String authUserId, String receiverId) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.fdarkBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(24), // More rounded input field
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                      // Add enter key to send message
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          chatProvider.sendMessage(
                              widget.conversation.id, text, authUserId, receiverId);
                          _messageController.clear();
                          SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                          chatProvider.fetchConversations();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconGradientButton(
            width: 50,
            height: 50,
            icon: IconlyBold.send,
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                // Show loading indicator while sending
                try {
                  chatProvider.sendMessage(
                      widget.conversation.id, text, authUserId, receiverId);
                  _messageController.clear();

                  // Scroll to bottom after sending
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  chatProvider.fetchConversations();
                } catch (e) {
                  // Show error snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to send message: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
