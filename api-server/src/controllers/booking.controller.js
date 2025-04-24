const { Op } = require('sequelize');
const { Booking, Service, User, Payment } = require('../models');
const { validationResult } = require('express-validator');

class BookingController {
  async createBooking(req, res) {
    try {
      console.log('Booking request body:', req.body);
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        service_id,
        booking_date: bookingDateStr,
        special_instructions = '',
        payment_method,
        location = {}
      } = req.body;
      
      // Parse the booking date
      const booking_date = bookingDateStr ? new Date(bookingDateStr) : null;
      
      // Extract time from the date string if needed
      const booking_time = booking_date ?
        booking_date.toTimeString().split(' ')[0].substring(0, 5) :
        '10:00'; // Default time
      
      // Calculate end time (1 hour after start time by default)
      let [hours, minutes] = booking_time.split(':').map(Number);
      hours += 1; // Add 1 hour
      if (hours >= 24) hours -= 24; // Handle day overflow
      const end_time = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
      
      console.log('Calculated times:', { booking_time, end_time });
      
      console.log('Parsed booking request:', {
        service_id,
        booking_date,
        booking_time,
        special_instructions,
        payment_method
      });

      // Get service details
      const service = await Service.findByPk(service_id, {
        include: [{
          model: User,
          as: 'provider',
          attributes: ['id', 'fcm_token']
        }]
      });

      if (!service) {
        return res.status(404).json({ success: false, message: 'Service not found' });
      }

      if (!service.is_active) {
        return res.status(400).json({ success: false, message: 'Service is not available' });
      }

      console.log('Service price:', service.price);
      
      if (!service.price) {
        return res.status(400).json({ success: false, message: 'Service price is missing' });
      }

      // Map payment methods from client to server for the Payment model
      // Payment model allows: 'online', 'cash', 'cod'
      const PAYMENT_METHOD_MAP = {
        'cod': 'cod',  // Keep cod as cod since it's a valid enum value
        'jazzcash': 'online',
        'easypaisa': 'online'
      };

      // Create booking with only fields that exist in the database
      const booking = await Booking.create({
        service_id,
        customer_id: req.user.id,
        provider_id: service.provider_id,
        booking_date,
        start_time: booking_time, // Using the extracted booking_time for start_time
        end_time: end_time, // Using the calculated end_time
        // time_slot removed - confirmed not in the actual database
        // service_location removed - confirmed not in the actual database
        special_instructions,
        status: 'pending',
        amount: service.price
        // total_amount removed - confirmed not in the actual database
      });

      console.log('Booking amount:', booking.amount);

      // Create payment record
      await Payment.create({
        booking_id: booking.id,
        amount: service.price,
        payment_method: PAYMENT_METHOD_MAP[payment_method] || 'cash',
        status: payment_method === 'cod' ? 'pending' : 'initiated',
        payer_id: req.user.id
      });

      // Get booking with relations
      const createdBooking = await Booking.findByPk(booking.id, {
        include: [
          {
            model: Service,
            include: [{
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Payment
          }
        ]
      });

      // TODO: Send notification to provider
      // if (service.provider.fcm_token) {
      //   await sendNotification(service.provider.fcm_token, {
      //     title: 'New Booking',
      //     body: `You have a new booking request for ${service.title}`
      //   });
      // }

      // Format response to match Flutter client expectations
      const responseData = {
        success: true,
        statusCode: 201,
        message: 'Booking created successfully',
        data: {
          data: [
            {
              id: createdBooking.id,
              customer_id: createdBooking.customer_id,
              service_id: createdBooking.service_id,
              service_provider_id: createdBooking.provider_id,
              placed_at: createdBooking.createdAt ? createdBooking.createdAt.toISOString() : new Date().toISOString(),
              order_date: createdBooking.booking_date ? createdBooking.booking_date.toString() : new Date().toISOString(),
              order_status: createdBooking.status,
              order_price: createdBooking.amount.toString(),
              payment_status: createdBooking.Payment ? createdBooking.Payment.status : 'pending',
              payment_method: createdBooking.Payment ? createdBooking.Payment.payment_method : 'cod',
              customer_address: {
                street_no: 123, // Default value since not in our data model
                city: 'Default City',
                state: 'Default State',
                postal_code: '12345',
                country: 'Default Country',
                location: 'Default Location'
              },
              additional_notes: createdBooking.special_instructions || '',
              order_completion_date: null,
              cancellation_reason: createdBooking.cancellation_reason
            }
          ]
        }
      };

      res.status(201).json(responseData);
    } catch (error) {
      console.error('Create booking error:', error);
      res.status(500).json({ success: false, message: 'Error creating booking' });
    }
  }

  async updateBookingStatus(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { id } = req.params;
      const status = req.body.order_status;
      const { cancellation_reason } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          message: 'Status is required'
        });
      }

      // Find booking
      const booking = await Booking.findByPk(id, {
        include: [
          {
            model: Service,
            attributes: ['id', 'title', 'description', 'price', 'cover_photo', 'is_active'],
            include: [{
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Payment
          }
        ]
      });

      if (!booking) {
        return res.status(404).json({
          success: false,
          message: 'Booking not found'
        });
      }

      // Check permissions
      const isProvider = booking.provider_id === req.user.id;
      const isCustomer = booking.customer_id === req.user.id;

      if (!isProvider && !isCustomer) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      // Validate status transition
      const validTransitions = {
        pending: ['accepted', 'rejected', 'cancelled'],
        accepted: ['processing', 'cancelled'],
        rejected: [],
        processing: ['completed', 'cancelled'],
        cancelled: [],
        completed: []
      };

      if (!validTransitions[booking.status].includes(status)) {
        return res.status(400).json({
          success: false,
          message: `Cannot transition from ${booking.status} to ${status}`
        });
      }

      // Update booking
      await booking.update({
        status,
        cancellation_reason: status === 'cancelled' ? cancellation_reason : null,
        completion_date: status === 'completed' ? new Date() : null
      });

      // Update payment status if booking is completed
      if (status === 'completed') {
        await Payment.update(
          { status: 'completed' },
          { where: { booking_id: booking.id } }
        );
      }

      // Get updated booking with all relations
      const updatedBooking = await Booking.findByPk(id, {
        include: [
          {
            model: Service,
            attributes: ['id', 'title', 'description', 'price', 'cover_photo', 'is_active'],
            include: [{
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Payment
          }
        ]
      });

      // Format response
      const responseData = {
        success: true,
        statusCode: 200,
        message: 'Booking status updated successfully',
        data: {
          data: [{
            id: updatedBooking.id,
            customer_id: updatedBooking.customer_id,
            service_id: updatedBooking.service_id,
            service_provider_id: updatedBooking.provider_id,
            placed_at: updatedBooking.createdAt ? updatedBooking.createdAt.toISOString() : new Date().toISOString(),
            order_date: updatedBooking.booking_date ? updatedBooking.booking_date.toString() : new Date().toISOString(),
            order_status: updatedBooking.status,
            order_price: updatedBooking.amount ? updatedBooking.amount.toString() : "0.00",
            payment_status: updatedBooking.Payment ? updatedBooking.Payment.status : 'pending',
            payment_method: updatedBooking.Payment ? updatedBooking.Payment.payment_method : 'cod',
            service: updatedBooking.Service ? {
              id: updatedBooking.Service.id,
              title: updatedBooking.Service.title,
              description: updatedBooking.Service.description,
              price: updatedBooking.Service.price,
              cover_photo: updatedBooking.Service.cover_photo,
              is_active: updatedBooking.Service.is_active,
              provider: updatedBooking.Service.provider ? {
                id: updatedBooking.Service.provider.id,
                name: updatedBooking.Service.provider.name,
                email: updatedBooking.Service.provider.email,
                phone: updatedBooking.Service.provider.phone,
                avatar: updatedBooking.Service.provider.avatar
              } : null
            } : null,
            customer: updatedBooking.customer ? {
              id: updatedBooking.customer.id,
              name: updatedBooking.customer.name,
              email: updatedBooking.customer.email,
              phone: updatedBooking.customer.phone,
              avatar: updatedBooking.customer.avatar
            } : null,
            customer_address: {
              street_no: 123,
              city: 'Default City',
              state: 'Default State',
              postal_code: '12345',
              country: 'Default Country',
              location: 'Default Location'
            },
            additional_notes: updatedBooking.special_instructions || '',
            order_completion_date: updatedBooking.completion_date ? updatedBooking.completion_date.toISOString() : null,
            cancellation_reason: updatedBooking.cancellation_reason || null
          }]
        }
      };

      res.json(responseData);
    } catch (error) {
      console.error('Update booking status error:', error);
      res.status(500).json({
        success: false,
        message: 'Error updating booking status',
        error: error.message
      });
    }
  }

  async getBooking(req, res) {
    try {
      const { id } = req.params;

      const booking = await Booking.findByPk(id, {
        include: [
          {
            model: Service,
            attributes: ['id', 'title', 'description', 'price', 'cover_photo', 'is_active'],
            include: [{
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Payment
          }
        ]
      });

      if (!booking) {
        return res.status(404).json({
          success: false,
          message: 'Booking not found'
        });
      }

      // Format response to match client expectations
      const responseData = {
        success: true,
        statusCode: 200,
        message: 'Booking retrieved successfully',
        data: {
          data: [{
            id: booking.id,
            customer_id: booking.customer_id,
            service_id: booking.service_id,
            service_provider_id: booking.provider_id,
            placed_at: booking.createdAt ? booking.createdAt.toISOString() : new Date().toISOString(),
            order_date: booking.booking_date ? booking.booking_date.toString() : new Date().toISOString(),
            order_status: booking.status,
            order_price: booking.amount ? booking.amount.toString() : "0.00",
            payment_status: booking.Payment ? booking.Payment.status : 'pending',
            payment_method: booking.Payment ? booking.Payment.payment_method : 'cod',
            service: booking.Service ? {
              id: booking.Service.id,
              title: booking.Service.title,
              description: booking.Service.description,
              price: booking.Service.price,
              cover_photo: booking.Service.cover_photo,
              is_active: booking.Service.is_active,
              provider: booking.Service.provider ? {
                id: booking.Service.provider.id,
                name: booking.Service.provider.name,
                email: booking.Service.provider.email,
                phone: booking.Service.provider.phone,
                avatar: booking.Service.provider.avatar
              } : null
            } : null,
            customer: booking.customer ? {
              id: booking.customer.id,
              name: booking.customer.name,
              email: booking.customer.email,
              phone: booking.customer.phone,
              avatar: booking.customer.avatar
            } : null,
            customer_address: {
              street_no: 123,
              city: 'Default City',
              state: 'Default State',
              postal_code: '12345',
              country: 'Default Country',
              location: 'Default Location'
            },
            additional_notes: booking.special_instructions || '',
            order_completion_date: booking.completion_date ? booking.completion_date.toISOString() : null,
            cancellation_reason: booking.cancellation_reason || null
          }]
        }
      };

      res.json(responseData);
    } catch (error) {
      console.error('Get booking error:', error);
      res.status(500).json({
        success: false,
        message: 'Error retrieving booking',
        error: error.message
      });
    }
  }

  async listBookings(req, res) {
    try {
      console.log('ListBookings request query:', req.query);
      console.log('User role from token:', req.user.role); // Log the exact role from token
      console.log('User roles array:', req.user.roles); // Log the roles array

      // FIXED: Check properly if user has service_provider role in the roles array of objects
      let hasProviderRole = false;
      if (req.user.roles && Array.isArray(req.user.roles)) {
        // Check if any role object has name 'service_provider'
        hasProviderRole = req.user.roles.some(role => 
          role.dataValues && role.dataValues.name === 'service_provider'
        );
      }
      
      console.log('Has provider role (correct check):', hasProviderRole);

      // Determine role for filtering: use 'provider' if user has service_provider role
      let role = hasProviderRole ? 'provider' : 'customer';
      
      console.log('Final role used for query:', role);

      const {
        status,
        start_date,
        end_date,
        page = 1,
        limit = 10
      } = req.query;

      // Build where clause
      const where = {};
      if (role === 'provider') {
        where.provider_id = req.user.id;
      } else {
        where.customer_id = req.user.id;
      }

      console.log('Where clause:', where);

      // Add status filter if provided
      if (status) where.status = status;
      
      // Add date range filter if provided
      if (start_date && end_date) {
        where.booking_date = {
          [Op.between]: [start_date, end_date]
        };
      }

      // Get bookings with relations
      const bookings = await Booking.findAll({
        where,
        include: [
          {
            model: Service,
            attributes: ['id', 'title', 'description', 'price', 'cover_photo', 'is_active'],
            include: [{
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Payment
          }
        ]
      });

      // Format bookings to match client expectations
      const formattedBookings = await Promise.all(bookings.map(booking => ({
        id: booking.id,
        customer_id: booking.customer_id,
        service_id: booking.service_id,
        service_provider_id: booking.provider_id,
        placed_at: booking.createdAt ? booking.createdAt.toISOString() : new Date().toISOString(),
        order_date: booking.booking_date ? booking.booking_date.toString() : new Date().toISOString(),
        order_status: booking.status,
        order_price: booking.amount ? booking.amount.toString() : "0.00",
        payment_status: booking.Payment ? booking.Payment.status : 'pending',
        payment_method: booking.Payment ? booking.Payment.payment_method : 'cod',
        service: booking.Service ? {
          id: booking.Service.id,
          title: booking.Service.title,
          description: booking.Service.description,
          price: booking.Service.price,
          cover_photo: booking.Service.cover_photo,
          is_active: booking.Service.is_active,
          provider: booking.Service.provider ? {
            id: booking.Service.provider.id,
            name: booking.Service.provider.name,
            email: booking.Service.provider.email,
            phone: booking.Service.provider.phone,
            avatar: booking.Service.provider.avatar
          } : null
        } : null,
        customer: booking.customer ? {
          id: booking.customer.id,
          name: booking.customer.name,
          email: booking.customer.email,
          phone: booking.customer.phone,
          avatar: booking.customer.avatar
        } : null,
        customer_address: {
          street_no: 123,
          city: 'Default City',
          state: 'Default State',
          postal_code: '12345',
          country: 'Default Country',
          location: 'Default Location'
        },
        additional_notes: booking.special_instructions || '',
        order_completion_date: booking.completion_date ? booking.completion_date.toISOString() : null,
        cancellation_reason: booking.cancellation_reason || null
      })));

      const response = {
        success: true,
        statusCode: 200,
        message: 'Bookings fetched successfully',
        data: formattedBookings
      };

      // Log the response structure
      console.log('API Response Structure:', JSON.stringify(response, null, 2).substring(0, 200) + '...');
      
      res.json(response);
    } catch (error) {
      console.error('List bookings error:', error);
      res.status(500).json({ success: false, message: 'Error fetching bookings' });
    }
  }
}

module.exports = new BookingController();
