const db = require('../models');
const { Op } = require('sequelize');
const notificationService = require('../services/notification.service');

// References to store socket.io instance and connected users
let io;
let connectedUsers = [];

// Function to initialize socket references
function setSocketReferences(socketIo, users) {
  io = socketIo;
  connectedUsers = users;
  console.log('Socket references set in MessageController');
}

class MessageController {
  // Send a new message
  async sendMessage(req, res) {
    try {
      // Access models from the db object
      const User = db.User;
      const Message = db.Message;
      const Conversation = db.Conversation;
      
      const { conversation_id, text } = req.body;
      const sender_id = req.user.id;

      if (!conversation_id || !text) {
        return res.status(400).json({
          success: false,
          message: "Conversation ID and message text are required"
        });
      }

      // Check if conversation exists
      const conversation = await Conversation.findByPk(conversation_id);

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      // Check if user is a member using direct query
      const membershipCheck = await db.sequelize.query(
        `SELECT 1 FROM "ConversationMembers" WHERE conversation_id = :conversationId AND user_id = :userId LIMIT 1`,
        {
          replacements: { conversationId: conversation_id, userId: sender_id },
          type: db.sequelize.QueryTypes.SELECT
        }
      );

      if (membershipCheck.length === 0) {
        return res.status(403).json({
          success: false,
          message: "You are not a member of this conversation"
        });
      }

      // Create the new message
      const message = await Message.create({
        conversation_id,
        sender_id,
        text
      });

      // Update the conversation's last message and time
      await conversation.update({
        last_message: text,
        last_message_time: new Date()
      });

      // Get sender details
      const sender = await User.findByPk(sender_id, {
        attributes: ['id', 'name', 'avatar']
      });
      
      // Construct message response
      const messageWithDetails = {
        ...message.toJSON(),
        sender
      };
      
      // Find the receiver ID (the other user in the conversation)
      try {
        // Query to get the other member of the conversation (not the sender)
        const memberQuery = await db.sequelize.query(
          `SELECT user_id FROM "ConversationMembers" 
           WHERE conversation_id = :conversationId AND user_id != :senderId LIMIT 1`,
          {
            replacements: { conversationId: conversation_id, senderId: sender_id },
            type: db.sequelize.QueryTypes.SELECT
          }
        );
        
        if (memberQuery.length > 0) {
          const receiverId = memberQuery[0].user_id;
          console.log(`Processing message delivery to user ${receiverId}`);
          
          // Use the socket.io instance to deliver message in real-time if recipient is online
          if (io && connectedUsers) {
            const delivered = notificationService.deliverMessage(
              sender_id,
              receiverId,
              text,
              io,
              connectedUsers
            );
            
            if (delivered) {
              console.log(`Message delivered in real-time to user ${receiverId}`);
            } else {
              console.log(`User ${receiverId} will receive message when they connect`);
            }
          } else {
            console.log('Socket.io references not set, cannot deliver in real-time');
          }
        }
      } catch (notificationError) {
        console.error('Failed to process message notification:', notificationError);
        // Continue execution - notification failure shouldn't prevent message sending
      }

      return res.status(200).json({
        success: true,
        data: [messageWithDetails]
      });
    } catch (error) {
      console.error('Send message error:', error);
      return res.status(500).json({
        success: false,
        message: "Error sending message",
        error: error.message
      });
    }
  }

  // Get messages from a specific conversation
  async getConversationMessages(req, res) {
    try {
      // Access models from the db object
      const User = db.User;
      const Message = db.Message;
      const Conversation = db.Conversation;
      
      const { conversation_id } = req.params;
      const userId = req.user.id;

      // Check if conversation exists
      const conversation = await Conversation.findByPk(conversation_id);

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found"
        });
      }

      // Check if user is a member using direct query
      const membershipCheck = await db.sequelize.query(
        `SELECT 1 FROM "ConversationMembers" WHERE conversation_id = :conversationId AND user_id = :userId LIMIT 1`,
        {
          replacements: { conversationId: conversation_id, userId },
          type: db.sequelize.QueryTypes.SELECT
        }
      );

      if (membershipCheck.length === 0) {
        return res.status(403).json({
          success: false,
          message: "You are not a member of this conversation"
        });
      }

      // Get message data with simple join query
      const messagesData = await db.sequelize.query(
        `SELECT m.id, m.text, m.sender_id, m.is_read, m.created_at, m.updated_at, 
                u.id as user_id, u.name, u.avatar 
         FROM "Messages" m 
         JOIN "Users" u ON m.sender_id = u.id 
         WHERE m.conversation_id = :conversationId 
         ORDER BY m.created_at DESC`,
        {
          replacements: { conversationId: conversation_id },
          type: db.sequelize.QueryTypes.SELECT
        }
      );
      
      // Format the message data
      const messages = messagesData.map(msg => ({
        id: msg.id,
        text: msg.text,
        is_read: msg.is_read,
        created_at: msg.created_at,
        updated_at: msg.updated_at,
        conversation_id,
        sender_id: msg.sender_id,
        sender: {
          id: msg.user_id,
          name: msg.name,
          avatar: msg.avatar
        }
      }));

      // Mark unread messages as read if the current user is not the sender
      await Message.update(
        { is_read: true },
        {
          where: {
            conversation_id,
            sender_id: { [Op.ne]: userId },
            is_read: false
          }
        }
      );

      return res.status(200).json({
        success: true,
        data: messages
      });
    } catch (error) {
      console.error('Get conversation messages error:', error);
      return res.status(500).json({
        success: false,
        message: "Error retrieving messages",
        error: error.message
      });
    }
  }
}

const messageController = new MessageController();

module.exports = {
  controller: messageController,
  setSocketReferences
};
