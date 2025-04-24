const express = require('express');
const { body, query } = require('express-validator');
const paymentController = require('../controllers/payment.controller');
const { verifyToken, requireRole } = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const initiatePaymentValidation = [
  body('booking_id').notEmpty().withMessage('Booking ID is required'),
  body('payment_method').isIn(['cod', 'card', 'wallet']).withMessage('Invalid payment method')
];

const listPaymentsValidation = [
  query('role').optional().isIn(['customer', 'provider']).withMessage('Invalid role'),
  query('status').optional().isIn(['pending', 'initiated', 'completed', 'failed']).withMessage('Invalid status'),
  query('start_date').optional().isDate().withMessage('Invalid start date'),
  query('end_date').optional().isDate().withMessage('Invalid end date'),
  query('page').optional().isInt({ min: 1 }).withMessage('Invalid page number'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Invalid limit')
];

// Routes
router.post(
  '/initiate',
  verifyToken,
  requireRole(['customer']),
  initiatePaymentValidation,
  paymentController.initiatePayment
);

router.post(
  '/:booking_id/confirm',
  verifyToken,
  requireRole(['service_provider']),
  paymentController.confirmPayment
);

router.get(
  '/:booking_id',
  verifyToken,
  paymentController.getPaymentDetails
);

router.get(
  '/',
  verifyToken,
  listPaymentsValidation,
  paymentController.listPayments
);

module.exports = router;
