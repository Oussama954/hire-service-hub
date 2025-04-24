const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const switchRole = require('../controllers/auth/switchRole');
const { verifyToken } = require('../middlewares/auth');

const router = express.Router();

// Validation middleware
const registerValidation = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  body('phone').optional().isMobilePhone().withMessage('Valid phone number is required'),
  body('role').optional().isIn(['customer', 'service_provider']).withMessage('Invalid role')
];

const loginValidation = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required')
];

const profileUpdateValidation = [
  body('name').optional().trim().notEmpty().withMessage('Name cannot be empty'),
  body('phone').optional().isMobilePhone().withMessage('Valid phone number is required'),
  body('gender').optional().isIn(['male', 'female', 'other']).withMessage('Invalid gender'),
  body('bio').optional().trim(),
  body('cnic').optional().trim().notEmpty().withMessage('CNIC cannot be empty'),
  body('address').optional().isObject().withMessage('Address must be an object')
];

// Routes
router.post('/register', registerValidation, authController.register);
router.post('/login', loginValidation, authController.login);
router.get('/profile', verifyToken, authController.getProfile);
router.put('/profile', verifyToken, profileUpdateValidation, authController.updateProfile);
router.patch('/complete-profile', verifyToken, profileUpdateValidation, authController.updateProfile);
router.post('/update-fcm-token', verifyToken, authController.updateFcmToken);
router.put('/upsert-fcm-token', verifyToken, authController.upsertFcmToken);
router.patch('/switch-role', verifyToken, switchRole);
router.post('/calculate-profile-completion', verifyToken, authController.calculateProfileCompletion);

module.exports = router;
