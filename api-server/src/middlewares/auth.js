const jwt = require('jsonwebtoken');
const { User, Role } = require('../models');

const verifyToken = async (req, res, next) => {
  console.log('--- JWT Verification Middleware ---');
  console.log('Request URL:', req.originalUrl);
  console.log('Headers:', req.headers);
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    console.log('No Authorization header');
    return res.status(401).json({ success: false, message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    console.log('No token after Bearer');
    return res.status(401).json({ success: false, message: 'Invalid token format' });
  }

  let decoded;
  try {
    decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded JWT:', decoded);
  } catch (err) {
    console.error('JWT verification failed:', err);
    console.error('JWT_SECRET used:', process.env.JWT_SECRET);
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
  const userId = decoded.userId || decoded.id;
  console.log('UserID from token:', userId);
  if (!userId) {
    console.log('No userId in token');
    return res.status(401).json({ success: false, message: 'Invalid token payload' });
  }
  // Set user ID in headers for downstream middleware/routes
  req.headers['user-id'] = userId.toString();

  // Use the correct alias for Role association
  const user = await User.findByPk(userId, {
    include: [{
      model: Role,
      as: 'roles', // <-- match your User.belongsToMany(Role, { as: 'roles' })
      through: { attributes: [] }
    }]
  });
  console.log('User found:', !!user);
  if (user) {
    console.log('User data:', {
      id: user.id,
      email: user.email,
      is_active: user.is_active,
      roles: user.roles ? user.roles.map(r => r.name) : []
    });
  }

  if (!user) {
    console.log('User not found in database');
    return res.status(401).json({ success: false, message: 'User not found' });
  }

  if (!user.is_active) {
    console.log('User account is inactive');
    return res.status(401).json({ success: false, message: 'User account is inactive' });
  }

  req.user = user;
  req.roles = user.roles.map(role => role.name);
  console.log('--- JWT Verification Success ---');
  next();
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
