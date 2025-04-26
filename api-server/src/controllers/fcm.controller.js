const notificationService = require('../services/notification.service');

class FCMController {
  /**
   * Save a FCM token for the authenticated user
   */
  async saveToken(req, res) {
    try {
      const userId = req.user.id;
      const { token } = req.body;

      if (!token) {
        return res.status(400).json({
          success: false,
          message: 'FCM token is required'
        });
      }

      const success = await notificationService.saveFcmToken(userId, token);

      if (success) {
        return res.status(200).json({
          success: true,
          message: 'FCM token saved successfully'
        });
      } else {
        return res.status(500).json({
          success: false,
          message: 'Failed to save FCM token'
        });
      }
    } catch (error) {
      console.error('Error saving FCM token:', error);
      return res.status(500).json({
        success: false,
        message: 'Error saving FCM token',
        error: error.message
      });
    }
  }

  /**
   * Test sending a notification to the authenticated user
   */
  async testNotification(req, res) {
    try {
      const userId = req.user.id;
      const { title, body } = req.body;

      if (!title || !body) {
        return res.status(400).json({
          success: false,
          message: 'Title and body are required'
        });
      }

      const success = await notificationService.sendNotification(
        userId, 
        title, 
        body, 
        { type: 'test' }
      );

      if (success) {
        return res.status(200).json({
          success: true,
          message: 'Test notification sent successfully'
        });
      } else {
        return res.status(500).json({
          success: false,
          message: 'Failed to send test notification'
        });
      }
    } catch (error) {
      console.error('Error sending test notification:', error);
      return res.status(500).json({
        success: false,
        message: 'Error sending test notification',
        error: error.message
      });
    }
  }
}

module.exports = new FCMController();
