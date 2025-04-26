const db = require('../models');
const { sequelize } = db;
const { Op } = require('sequelize');

class ConversationController {
  // Create a new conversation or get an existing one
  async createConversation(req, res) {
    try {
      const { receiver_id } = req.body;
      const sender_id = req.user.id;
      
      // Access models from the db object
      const User = db.User;
      const Conversation = db.Conversation;
      
      if (!receiver_id) {
        return res.status(400).json({
          success: false,
          message: "Receiver ID is required"
        });
      }

      // Check if users exist
      const [sender, receiver] = await Promise.all([
        User.findByPk(sender_id),
        User.findByPk(receiver_id)
      ]);

      if (!sender || !receiver) {
        return res.status(404).json({
          success: false,
          message: "One or both users not found"
        });
      }
      
      // Check if conversation already exists
      const existingConversation = await Conversation.findOne({
        include: [
          {
            model: User,
            as: 'members',
            where: { id: sender_id },
            through: { attributes: [] }
          },
          {
            model: User,
            as: 'members',
            where: { id: receiver_id },
            through: { attributes: [] }
          }
        ]
      });

      if (existingConversation) {
        return res.status(200).json({
          success: true,
          message: "Conversation already exists",
          data: [existingConversation]
        });
      }

      // Create a new conversation
      const newConversation = await Conversation.create({
        last_message: null,
        last_message_time: new Date()
      });

      // Add both users to the conversation
      await newConversation.addMembers([sender_id, receiver_id]);

      // Fetch the conversation with members
      const conversationWithMembers = await Conversation.findByPk(newConversation.id, {
        include: [
          {
            model: User,
            as: 'members',
            attributes: ['id', 'name', 'email', 'avatar'],
            through: { attributes: [] }
          }
        ]
      });

      // Return 201 Created status for new conversations
      return res.status(201).json({
        success: true,
        message: "Conversation created successfully",
        data: [conversationWithMembers]
      });
    } catch (error) {
      console.error('Create conversation error:', error);
      return res.status(500).json({
        success: false,
        message: "Error creating conversation",
        error: error.message
      });
    }
  }

  // Get all conversations for the authenticated user
  async getConversations(req, res) {
    try {
      const userId = req.user.id;
      const User = db.User;
      const Conversation = db.Conversation;
      
      // Use a simpler direct query for now to list conversations
      const conversationsData = await sequelize.query(
        `SELECT c.id, c.last_message, c.last_message_time, c.created_at, c.updated_at
         FROM "Conversations" c
         JOIN "ConversationMembers" cm ON c.id = cm.conversation_id
         WHERE cm.user_id = :userId
         ORDER BY c.last_message_time DESC NULLS LAST`,
        {
          replacements: { userId },
          type: sequelize.QueryTypes.SELECT
        }
      );
      
      // Get members for each conversation
      const conversations = [];
      
      for (const conv of conversationsData) {
        const members = await User.findAll({
          attributes: ['id', 'email', 'name', 'avatar'],
          include: [{
            model: Conversation,
            as: 'conversations',
            where: { id: conv.id },
            through: { attributes: [] },
            attributes: []
          }]
        });
        
        conversations.push({
          ...conv,
          members
        });
      }

      return res.status(200).json({
        success: true,
        data: conversations
      });
    } catch (error) {
      console.error('Get conversations error:', error);
      return res.status(500).json({
        success: false,
        message: "Error retrieving conversations",
        error: error.message
      });
    }
  }
}

module.exports = new ConversationController();
