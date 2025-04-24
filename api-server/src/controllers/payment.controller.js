const { Payment, Booking, Service, User } = require('../models');
const { validationResult } = require('express-validator');

class PaymentController {
  async initiatePayment(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { booking_id, payment_method } = req.body;

      // Get booking details
      const booking = await Booking.findByPk(booking_id, {
        include: [
          {
            model: Service,
            include: [{
              model: User,
              as: 'provider'
            }]
          },
          {
            model: User,
            as: 'customer'
          }
        ]
      });

      if (!booking) {
        return res.status(404).json({ success: false, message: 'Booking not found' });
      }

      if (booking.customer_id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
      }

      // Check if payment already exists
      const existingPayment = await Payment.findOne({
        where: { booking_id }
      });

      if (existingPayment) {
        return res.status(400).json({
          success: false,
          message: 'Payment already initiated for this booking'
        });
      }

      let paymentData = {
        booking_id,
        amount: booking.amount,
        payment_method,
        status: payment_method === 'cod' ? 'pending' : 'initiated',
        currency: 'USD' // You might want to make this configurable
      };

      // If online payment, create payment intent with payment provider
      if (payment_method !== 'cod') {
        try {
          // TODO: Implement payment gateway integration
          // const paymentIntent = await stripe.paymentIntents.create({
          //   amount: booking.amount * 100, // Convert to cents
          //   currency: 'usd',
          //   customer: req.user.stripe_customer_id,
          //   metadata: {
          //     booking_id: booking.id,
          //     service_id: booking.service_id
          //   }
          // });
          // paymentData.payment_intent_id = paymentIntent.id;
        } catch (error) {
          console.error('Payment gateway error:', error);
          return res.status(500).json({
            success: false,
            message: 'Error creating payment intent'
          });
        }
      }

      // Create payment record
      const payment = await Payment.create(paymentData);

      // Get payment with relations
      const createdPayment = await Payment.findByPk(payment.id, {
        include: [{
          model: Booking,
          include: [
            {
              model: Service,
              include: [{
                model: User,
                as: 'provider',
                attributes: ['id', 'name', 'email']
              }]
            },
            {
              model: User,
              as: 'customer',
              attributes: ['id', 'name', 'email']
            }
          ]
        }]
      });

      res.status(201).json({
        success: true,
        data: createdPayment
      });
    } catch (error) {
      console.error('Initiate payment error:', error);
      res.status(500).json({ success: false, message: 'Error initiating payment' });
    }
  }

  async confirmPayment(req, res) {
    try {
      const { booking_id } = req.params;

      // Get payment details
      const payment = await Payment.findOne({
        where: { booking_id },
        include: [{
          model: Booking,
          include: [
            {
              model: Service,
              include: [{
                model: User,
                as: 'provider'
              }]
            },
            {
              model: User,
              as: 'customer'
            }
          ]
        }]
      });

      if (!payment) {
        return res.status(404).json({ success: false, message: 'Payment not found' });
      }

      if (payment.Booking.provider_id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
      }

      // Update payment status
      await payment.update({ status: 'completed' });

      // Update booking status
      await payment.Booking.update({ status: 'completed' });

      // Get updated payment
      const updatedPayment = await Payment.findByPk(payment.id, {
        include: [{
          model: Booking,
          include: [
            {
              model: Service,
              include: [{
                model: User,
                as: 'provider',
                attributes: ['id', 'name', 'email']
              }]
            },
            {
              model: User,
              as: 'customer',
              attributes: ['id', 'name', 'email']
            }
          ]
        }]
      });

      // TODO: Send notification to customer
      // if (payment.Booking.customer.fcm_token) {
      //   await sendNotification(payment.Booking.customer.fcm_token, {
      //     title: 'Payment Confirmed',
      //     body: 'Your payment has been confirmed by the service provider'
      //   });
      // }

      res.json({
        success: true,
        data: updatedPayment
      });
    } catch (error) {
      console.error('Confirm payment error:', error);
      res.status(500).json({ success: false, message: 'Error confirming payment' });
    }
  }

  async getPaymentDetails(req, res) {
    try {
      const { booking_id } = req.params;

      const payment = await Payment.findOne({
        where: { booking_id },
        include: [{
          model: Booking,
          include: [
            {
              model: Service,
              include: [{
                model: User,
                as: 'provider',
                attributes: ['id', 'name', 'email']
              }]
            },
            {
              model: User,
              as: 'customer',
              attributes: ['id', 'name', 'email']
            }
          ]
        }]
      });

      if (!payment) {
        return res.status(404).json({ success: false, message: 'Payment not found' });
      }

      // Check permissions
      const isProvider = payment.Booking.provider_id === req.user.id;
      const isCustomer = payment.Booking.customer_id === req.user.id;

      if (!isProvider && !isCustomer) {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
      }

      res.json({
        success: true,
        data: payment
      });
    } catch (error) {
      console.error('Get payment details error:', error);
      res.status(500).json({ success: false, message: 'Error fetching payment details' });
    }
  }

  async listPayments(req, res) {
    try {
      const {
        role = 'customer',
        status,
        start_date,
        end_date,
        page = 1,
        limit = 10
      } = req.query;

      const offset = (page - 1) * limit;

      // Build where clause for bookings
      const bookingWhere = {};
      if (role === 'provider') {
        bookingWhere.provider_id = req.user.id;
      } else {
        bookingWhere.customer_id = req.user.id;
      }

      // Build where clause for payments
      const paymentWhere = {};
      if (status) paymentWhere.status = status;
      if (start_date && end_date) {
        paymentWhere.created_at = {
          [Op.between]: [start_date, end_date]
        };
      }

      const { count, rows: payments } = await Payment.findAndCountAll({
        where: paymentWhere,
        include: [{
          model: Booking,
          where: bookingWhere,
          include: [
            {
              model: Service,
              include: [{
                model: User,
                as: 'provider',
                attributes: ['id', 'name', 'avatar']
              }]
            },
            {
              model: User,
              as: 'customer',
              attributes: ['id', 'name', 'avatar']
            }
          ]
        }],
        order: [['created_at', 'DESC']],
        limit,
        offset
      });

      res.json({
        success: true,
        data: {
          payments,
          pagination: {
            total: count,
            current_page: page,
            total_pages: Math.ceil(count / limit),
            per_page: limit
          }
        }
      });
    } catch (error) {
      console.error('List payments error:', error);
      res.status(500).json({ success: false, message: 'Error fetching payments' });
    }
  }
}

module.exports = new PaymentController();
