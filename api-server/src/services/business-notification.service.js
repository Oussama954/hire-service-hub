const db = require('../models');
const notificationService = require('./notification.service');

/**
 * Specialized notification service for business-related notifications
 * such as bookings, services, and other business operations
 */
class BusinessNotificationService {
  /**
   * Send a booking status update notification to a user
   * 
   * @param {string} bookingId - The booking ID
   * @param {string} recipientId - The user ID to notify
   * @param {string} status - The new booking status
   * @param {Object} io - The Socket.io instance
   * @param {Array} users - Connected users array
   * @returns {Promise<boolean>} Success status
   */
  async sendBookingStatusNotification(bookingId, recipientId, status, io, users) {
    try {
      // Get booking and related information
      const Booking = db.Booking;
      const Service = db.Service;
      const User = db.User;

      const booking = await Booking.findByPk(bookingId, {
        include: [
          {
            model: Service,
            attributes: ['id', 'title']
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'first_name', 'last_name']
          },
          {
            model: User,
            as: 'provider',
            attributes: ['id', 'name', 'first_name', 'last_name']
          }
        ]
      });

      if (!booking) {
        console.error(`Booking ${bookingId} not found for notification`);
        return false;
      }

      // Get service name and format status for notification
      const serviceName = booking.Service?.title || 'Service';
      const statusFormatted = status.charAt(0).toUpperCase() + status.slice(1);
      
      // Craft appropriate title and message based on status
      let title, message;
      
      switch(status) {
        case 'accepted':
          title = `Booking Accepted`;
          message = `Your booking for ${serviceName} has been accepted!`;
          break;
        case 'rejected':
          title = `Booking Declined`;
          message = `Your booking for ${serviceName} has been declined.`;
          break;
        case 'completed':
          title = `Service Completed`;
          message = `Your booking for ${serviceName} has been marked as completed.`;
          break;
        case 'cancelled':
          title = `Booking Cancelled`;
          message = `Your booking for ${serviceName} has been cancelled.`;
          break;
        case 'in_progress':
          title = `Service In Progress`;
          message = `Your booking for ${serviceName} is now in progress.`;
          break;
        default:
          title = `Booking Update`;
          message = `Your booking for ${serviceName} status changed to ${statusFormatted}.`;
      }

      const notificationData = {
        type: 'booking',
        booking_id: bookingId,
        status: status,
        service_id: booking.Service?.id,
        title,
        body: message,
        click_action: 'BOOKING_UPDATE'
      };

      // Create message structure for socket delivery
      const socketMessage = {
        senderId: 'system',
        recipientId,
        notification: {
          title,
          body: message
        },
        data: notificationData
      };

      // Try to deliver via socket.io first for real-time experience
      let delivered = false;
      
      if (io && users) {
        delivered = notificationService.deliverMessage(
          'system',
          recipientId,
          JSON.stringify(notificationData),
          io,
          users
        );
        
        if (delivered) {
          console.log(`Booking notification delivered via socket to user ${recipientId}`);
        }
      }

      return delivered;
    } catch (error) {
      console.error('Error sending booking notification:', error);
      return false;
    }
  }

  /**
   * Send a service status update notification to a service provider
   * 
   * @param {string} serviceId - The service ID
   * @param {string} status - The new service status
   * @param {Object} io - The Socket.io instance
   * @param {Array} users - Connected users array
   * @returns {Promise<boolean>} Success status
   */
  async sendServiceStatusNotification(serviceId, status, io, users) {
    try {
      // Get service and provider information
      const Service = db.Service;
      const User = db.User;

      const service = await Service.findByPk(serviceId, {
        include: [{
          model: User,
          as: 'provider',
          attributes: ['id', 'name', 'first_name', 'last_name']
        }]
      });

      if (!service || !service.provider) {
        console.error(`Service ${serviceId} or provider not found for notification`);
        return false;
      }

      const providerId = service.provider.id;
      const serviceName = service.title || 'Your service';
      const statusFormatted = status.charAt(0).toUpperCase() + status.slice(1);
      
      // Craft notification based on status
      let title, message;
      
      switch(status) {
        case 'approved':
          title = 'Service Approved';
          message = `${serviceName} has been approved and is now live!`;
          break;
        case 'rejected':
          title = 'Service Needs Updates';
          message = `${serviceName} has been rejected. Please review and update.`;
          break;
        case 'suspended':
          title = 'Service Suspended';
          message = `${serviceName} has been temporarily suspended.`;
          break;
        default:
          title = 'Service Status Update';
          message = `${serviceName} status changed to ${statusFormatted}.`;
      }

      const notificationData = {
        type: 'service',
        service_id: serviceId,
        status,
        title,
        body: message,
        click_action: 'SERVICE_UPDATE'
      };
      
      // Try to deliver via socket.io for real-time experience
      let delivered = false;
      
      if (io && users) {
        delivered = notificationService.deliverMessage(
          'system',
          providerId,
          JSON.stringify(notificationData),
          io,
          users
        );
        
        if (delivered) {
          console.log(`Service notification delivered via socket to provider ${providerId}`);
        }
      }

      return delivered;
    } catch (error) {
      console.error('Error sending service notification:', error);
      return false;
    }
  }

  /**
   * Send a notification about a new booking to a service provider
   * 
   * @param {string} bookingId - The booking ID
   * @param {Object} io - The Socket.io instance
   * @param {Array} users - Connected users array
   * @returns {Promise<boolean>} Success status
   */
  async sendNewBookingNotification(bookingId, io, users) {
    try {
      // Get booking details
      const Booking = db.Booking;
      const Service = db.Service;
      const User = db.User;

      const booking = await Booking.findByPk(bookingId, {
        include: [
          {
            model: Service,
            attributes: ['id', 'title']
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'first_name', 'last_name']
          },
          {
            model: User,
            as: 'provider',
            attributes: ['id', 'name', 'first_name', 'last_name']
          }
        ]
      });

      if (!booking) {
        console.error(`Booking ${bookingId} not found for new booking notification`);
        return false;
      }

      const providerId = booking.provider_id;
      const customerName = booking.customer.name || 
        `${booking.customer.first_name || ''} ${booking.customer.last_name || ''}`.trim() || 
        'A customer';
      const serviceName = booking.Service?.title || 'your service';

      const title = 'New Booking Request';
      const message = `${customerName} placed a new booking for ${serviceName}`;

      const notificationData = {
        type: 'new_booking',
        booking_id: bookingId,
        service_id: booking.Service?.id,
        title,
        body: message,
        click_action: 'NEW_BOOKING'
      };
      
      // Try to deliver via socket.io first
      let delivered = false;
      
      if (io && users) {
        delivered = notificationService.deliverMessage(
          'system',
          providerId,
          JSON.stringify(notificationData),
          io,
          users
        );
        
        if (delivered) {
          console.log(`New booking notification delivered via socket to provider ${providerId}`);
        }
      }

      return delivered;
    } catch (error) {
      console.error('Error sending new booking notification:', error);
      return false;
    }
  }
}

module.exports = new BusinessNotificationService();
