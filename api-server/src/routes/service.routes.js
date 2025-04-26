const express = require('express');
const { body, query, param } = require('express-validator');
const { controller: serviceController } = require('../controllers/service.controller');
const { verifyToken, requireRole } = require('../middlewares/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Validation middleware
const createServiceValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('description').trim().notEmpty().withMessage('Description is required'),
  body('price').isFloat({ min: 0 }).withMessage('Valid price is required'),
  body('category_id').notEmpty().withMessage('Category is required'),
  body('availability').optional().isObject().withMessage('Availability must be an object'),
  body('location').optional().isObject().withMessage('Location must be an object'),
  body('images').optional().isArray().withMessage('Images must be an array')
];

const updateServiceValidation = [
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('description').optional().trim().notEmpty().withMessage('Description cannot be empty'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Valid price is required'),
  body('category_id').optional().notEmpty().withMessage('Category cannot be empty'),
  body('availability').optional().isObject().withMessage('Availability must be an object'),
  body('location').optional().isObject().withMessage('Location must be an object'),
  body('images').optional().isArray().withMessage('Images must be an array'),
  body('is_active').optional().isBoolean().withMessage('is_active must be a boolean')
];

const listServicesValidation = [
  query('category_id').optional().isUUID().withMessage('Invalid category ID'),
  query('min_price').optional().isFloat({ min: 0 }).withMessage('Invalid minimum price'),
  query('max_price').optional().isFloat({ min: 0 }).withMessage('Invalid maximum price'),
  query('rating').optional().isFloat({ min: 0, max: 5 }).withMessage('Invalid rating'),
  query('sort_by').optional().isIn(['created_at', 'price', 'rating']).withMessage('Invalid sort field'),
  query('sort_order').optional().isIn(['ASC', 'DESC']).withMessage('Invalid sort order'),
  query('page').optional().isInt({ min: 1 }).withMessage('Invalid page number'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Invalid limit')
];

// Routes
router.post(
  '/',
  verifyToken,
  requireRole(['service_provider']),
  createServiceValidation,
  serviceController.createService
);

router.put(
  '/:id',
  verifyToken,
  requireRole(['service_provider']),
  updateServiceValidation,
  serviceController.updateService
);

// Add PATCH route to support the Flutter client
router.patch(
  '/:id',
  verifyToken,
  requireRole(['service_provider']),
  updateServiceValidation,
  serviceController.updateService
);

router.delete(
  '/:id',
  verifyToken,
  requireRole(['service_provider']),
  serviceController.deleteService
);

// Custom endpoints for Flutter app format
router.get('/filter', verifyToken, serviceController.listServices);
router.get('/myServices', verifyToken, requireRole(['service_provider']), serviceController.getProviderServices);
router.get('/', verifyToken, serviceController.listServices);
router.get('/:id', verifyToken, serviceController.getService);

router.get(
  '/provider/:provider_id',
  serviceController.getProviderServices
);

router.patch(
  '/cover-photo/:id',
  verifyToken,
  requireRole(['service_provider']),
  upload.single('cover_photo'),
  serviceController.uploadCoverPhoto
);

module.exports = router;
