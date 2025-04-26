const express = require('express');
const { verifyToken } = require('../middleware/auth');
const conversationController = require('../controllers/conversation.controller');

const router = express.Router();

// All conversation routes require authentication
router.use(verifyToken);

// Create a new conversation or get existing one
router.post('/', conversationController.createConversation);

// Get all conversations for authenticated user
router.get('/', conversationController.getConversations);

module.exports = router;
