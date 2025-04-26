const db = require('../models');

/**
 * A simple notification service that integrates with the existing Socket.io
 * implementation to ensure messages are delivered to the right users in real-time.
 */

class NotificationService {

  /**
   * Gets the socket ID associated with a user ID
   * @param {string} userId - The user ID to look up
   * @param {Array} users - The array of connected users from Socket.io
   * @returns {string|null} The socket ID if found, null otherwise
   */
  getSocketIdByUserId(userId, users) {
    if (!userId || !users || !Array.isArray(users)) {
      return null;
    }
    
    const userInfo = users.find(user => user.userId === userId);
    return userInfo ? userInfo.socketId : null;
  }
  
  /**
   * Delivers a message to a specific user via Socket.io
   * @param {string} senderId - The ID of the message sender
   * @param {string} receiverId - The ID of the intended recipient
   * @param {string} message - The message text
   * @param {Object} io - The Socket.io server instance
   * @param {Array} users - The array of connected users
   * @returns {boolean} Success status
   */
  deliverMessage(senderId, receiverId, message, io, users) {
    if (!senderId || !receiverId || !message || !io || !users) {
      console.error('Missing parameters for message delivery');
      return false;
    }
    
    try {
      // Get recipient's socket ID
      const receiverSocketId = this.getSocketIdByUserId(receiverId, users);
      
      if (!receiverSocketId) {
        console.log(`Recipient ${receiverId} is not online or has no socket connection`);
        // Store message for offline delivery
        return false;
      }
      
      // Send to specific user's socket
      io.to(receiverSocketId).emit('getMessage', {
        senderId,
        text: message,
      });
      
      console.log(`Message delivered to ${receiverId} via socket ${receiverSocketId}`);
      return true;
    } catch (error) {
      console.error('Error delivering message via socket:', error);
      return false;
    }
  }

  /**
   * Records a new message in the database for history/offline viewing
   * @param {string} conversationId - The conversation ID
   * @param {string} senderId - The sender's user ID
   * @param {string} text - The message text
   * @returns {Promise<Object|null>} The created message or null on failure
   */
  async recordMessage(conversationId, senderId, text) {
    try {
      const Message = db.Message;
      const Conversation = db.Conversation;
      
      // Create the message record
      const message = await Message.create({
        conversation_id: conversationId,
        sender_id: senderId,
        text: text,
        is_read: false,
      });
      
      // Update the conversation's last message
      await Conversation.update(
        {
          last_message: text,
          last_message_time: new Date()
        },
        { where: { id: conversationId } }
      );
      
      return message;
    } catch (error) {
      console.error('Error recording message:', error);
      return null;
    }
  }
  
  /**
   * Processes a new chat message, recording it and delivering it to the recipient
   * @param {string} senderId - The sender's user ID
   * @param {string} receiverId - The recipient's user ID
   * @param {string} conversationId - The conversation ID
   * @param {string} text - The message text
   * @param {Object} io - The Socket.io server instance
   * @param {Array} users - The array of connected users
   * @returns {Promise<Object|null>} The processed message or null on failure
   */
  async processMessage(senderId, receiverId, conversationId, text, io, users) {
    try {
      // Record the message in the database
      const message = await this.recordMessage(conversationId, senderId, text);
      
      if (!message) {
        throw new Error('Failed to record message');
      }
      
      // Attempt real-time delivery via Socket.io
      const delivered = this.deliverMessage(senderId, receiverId, text, io, users);
      
      if (!delivered) {
        console.log(`Message could not be delivered in real-time to ${receiverId}`);
        // Message will be delivered when user comes online or refreshes conversation
      }
      
      return message;
    } catch (error) {
      console.error('Error processing message:', error);
      return null;
    }
  }
}

module.exports = new NotificationService();
