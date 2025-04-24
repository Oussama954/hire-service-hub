const jwt = require('jsonwebtoken');
const { User, Role } = require('../models');

const verifyToken = async (req, res, next) => {
  try {
    console.log('--- JWT Verification Middleware ---');
    console.log('Request URL:', req.originalUrl);
    console.log('Headers:', req.headers);
    
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      console.log('No authorization header provided');
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      console.log('Invalid token format (no token after Bearer)');
      return res.status(401).json({ success: false, message: 'Invalid token format' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded JWT:', decoded);
    
    const userId = decoded.userId || decoded.id;
    console.log('UserID from token:', userId);

    if (!userId) {
      console.log('No userId in token payload');
      return res.status(401).json({ success: false, message: 'Invalid token payload' });
    }

    // Get user with roles
    const user = await User.findByPk(userId, {
      include: [{
        model: Role,
        as: 'roles',  // Lowercase 'roles' - this is the actual alias used in the association
        through: { attributes: [] } // Exclude junction table attributes
      }]
    });

    console.log('User found:', !!user);
    if (user) {
      console.log('User data:', {
        id: user.id,
        email: user.email,
        is_active: user.is_active,
        roles: user.roles ? user.roles.map(role => role.name) : []
      });
    }

    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    if (!user.is_active) {
      return res.status(401).json({ success: false, message: 'User account is inactive' });
    }

    // Add user and roles to request object
    req.user = user;
    req.roles = user.roles.map(role => role.name);
    console.log('--- JWT Verification Success ---');
    next();
  } catch (error) {
    console.error('JWT Verification Error:', error.name, error.message);
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expired' });
    }
    return res.status(401).json({ success: false, message: 'Invalid token', error: error.message });
  }
};

const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.roles) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const hasRequiredRole = req.roles.some(role => roles.includes(role));
    if (!hasRequiredRole) {
      return res.status(403).json({ success: false, message: 'Insufficient permissions' });
    }

    next();
  };
};

module.exports = {
  verifyToken,
  requireRole
};
