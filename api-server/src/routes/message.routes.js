const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { controller: messageController } = require('../controllers/message.controller');

const router = express.Router();

// All message routes require authentication
router.use(verifyToken);

// Send a new message
router.post('/', messageController.sendMessage.bind(messageController));

// Get messages for a specific conversation
router.get('/:conversation_id', messageController.getConversationMessages.bind(messageController));

module.exports = router;
