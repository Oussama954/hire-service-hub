const express = require('express');
const { body, query } = require('express-validator');
const reviewController = require('../controllers/review.controller');
const { verifyToken, requireRole } = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const createReviewValidation = [
  body('booking_id').notEmpty().withMessage('Booking ID is required'),
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment').trim().notEmpty().withMessage('Comment is required')
];

const updateReviewValidation = [
  body('rating').optional().isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment').optional().trim().notEmpty().withMessage('Comment cannot be empty')
];

const listReviewsValidation = [
  query('page').optional().isInt({ min: 1 }).withMessage('Invalid page number'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Invalid limit')
];

// Routes
router.post(
  '/',
  verifyToken,
  requireRole(['customer']),
  createReviewValidation,
  reviewController.createReview
);

router.put(
  '/:id',
  verifyToken,
  requireRole(['customer']),
  updateReviewValidation,
  reviewController.updateReview
);

router.delete(
  '/:id',
  verifyToken,
  requireRole(['customer']),
  reviewController.deleteReview
);

router.get(
  '/service/:service_id',
  listReviewsValidation,
  reviewController.getServiceReviews
);

router.get(
  '/provider/:provider_id',
  listReviewsValidation,
  reviewController.getProviderReviews
);

module.exports = router;
