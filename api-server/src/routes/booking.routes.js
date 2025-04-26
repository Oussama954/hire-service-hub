const express = require('express');
const { body, query } = require('express-validator');
const { controller: bookingController } = require('../controllers/booking.controller');
const { verifyToken, requireRole } = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const createBookingValidation = [
  body('service_id').notEmpty().withMessage('Service ID is required'),
  body('booking_date').notEmpty().withMessage('Valid booking date is required'),
  body('location').optional(),  // Make location optional
  body('special_instructions').optional().trim(),
  body('payment_method').isIn(['cod', 'jazzcash', 'easypaisa']).withMessage('Invalid payment method')
];

const updateBookingStatusValidation = [
  body('order_status').isIn(['accepted', 'rejected', 'processing', 'completed', 'cancelled']).withMessage('Invalid status'),
  body('cancellation_reason').optional().trim().notEmpty().withMessage('Cancellation reason is required when cancelling')
];

const listBookingsValidation = [
  query('role').optional().isIn(['customer', 'provider']).withMessage('Invalid role'),
  query('status').optional().isIn(['pending', 'accepted', 'rejected', 'processing', 'completed', 'cancelled']).withMessage('Invalid status'),
  query('start_date').optional().isDate().withMessage('Invalid start date'),
  query('end_date').optional().isDate().withMessage('Invalid end date'),
  query('page').optional().isInt({ min: 1 }).withMessage('Invalid page number'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Invalid limit')
];

// Routes
router.post(
  '/',
  verifyToken,
  requireRole(['customer']),
  createBookingValidation,
  bookingController.createBooking
);

// Update booking status
router.patch(
  '/service-provider/:id',
  verifyToken,
  requireRole(['service_provider']),
  updateBookingStatusValidation,
  bookingController.updateBookingStatus
);

router.get(
  '/:id',
  verifyToken,
  bookingController.getBooking
);

router.get(
  '/',
  verifyToken,
  listBookingsValidation,
  bookingController.listBookings
);

module.exports = router;
