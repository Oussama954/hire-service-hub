const express = require('express');
const router = express.Router();
const fcmController = require('../controllers/fcm.controller');
const { verifyToken } = require('../middlewares/auth');

// These routes require authentication
router.use(verifyToken);

// Save FCM token
router.post('/token', fcmController.saveToken);

// Test sending a notification (development only)
router.post('/test', fcmController.testNotification);

module.exports = router;
