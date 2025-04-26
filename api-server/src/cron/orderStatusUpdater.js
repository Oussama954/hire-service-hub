const cron = require('node-cron');
const { Op } = require('sequelize');

// Get the models - we'll get them dynamically in the schedule function 
// to ensure they're loaded when needed
const db = require('../models');

/**
 * Order Status Updater Cron Job
 * 
 * This cron job automatically updates order statuses based on service time:
 * - Changes orders from 'accepted' to 'processing' when the service start time is reached
 * 
 * Note: Order completion is handled manually by service providers, not by this cron job
 */

// Run every minute to check for orders that need status updates
const scheduleOrderStatusUpdates = () => {
  console.log('🕒 Order status updater cron job initialized');
  
  cron.schedule('* * * * *', async () => {
    try {
      // Get model references inside the scheduler to ensure they're loaded
      const Booking = db.Booking;
      const Service = db.Service;
      
      // Skip if models aren't properly loaded
      if (!Booking) {
        console.error('❌ Booking model not properly loaded. Skipping this cron job execution.');
        return;
      }

      const currentTime = new Date();
      console.log(`🔄 Running order status update check at ${currentTime.toISOString()}`);
      
      // Debug the Booking model
      console.log('🔹 Checking if Booking model is properly loaded:', !!Booking);
      console.log('🔹 Checking if Service model is properly loaded:', !!Service);
      
      try {
        // Find bookings that should be changed to 'processing' (accepted bookings where service start time has passed)
        const bookingsToProcess = await Booking.findAll({
          where: {
            status: 'accepted', // Status field in Booking model
            service_start_time: {
              [Op.lt]: currentTime
            }
          },
          // Don't use includes for now to simplify the query
          // We just need to update the status, we don't need related data
        });
        
        // Update bookings to 'processing'
        if (bookingsToProcess && bookingsToProcess.length > 0) {
          console.log(`📊 Found ${bookingsToProcess.length} bookings to mark as processing`);
          
          for (const booking of bookingsToProcess) {
            await booking.update({ status: 'processing' });
            console.log(`✅ Booking ${booking.id} updated from 'accepted' to 'processing'`);
          }
        } else {
          console.log('ℹ️ No bookings to update to processing at this time');
        }
      } catch (innerError) {
        console.error('❌ Error querying bookings:', innerError);
      }
      
    } catch (error) {
      console.error('❌ Error in order status updater cron job:', error);
    }
  });
};

module.exports = { scheduleOrderStatusUpdates };
