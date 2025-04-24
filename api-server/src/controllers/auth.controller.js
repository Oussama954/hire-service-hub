const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User, Role, UserRole } = require('../models');
const { validationResult } = require('express-validator');

class AuthController {
  async register(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { name, email, password, phone, role = 'customer' } = req.body;

      // Check if user exists
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ success: false, message: 'Email already registered' });
      }

      // Create user
      const user = await User.create({
        name,
        email,
        password, // Will be hashed by model hook
        phone
      });

      // Get role
      const userRole = await Role.findOne({ where: { name: role } });
      if (!userRole) {
        await user.destroy();
        return res.status(400).json({ success: false, message: 'Invalid role specified' });
      }

      // Assign role
      await UserRole.create({
        user_id: user.id,
        role_id: userRole.id
      });

      // Generate token
      const token = jwt.sign(
        { userId: user.id, email: user.email, role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      // Return user data without password
      const userData = user.toJSON();
      delete userData.password;

      res.status(201).json({
        success: true,
        data: {
          userData: [{ ...userData, token }],
          token
        }
      });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ success: false, message: 'Error creating user' });
    }
  }

  async login(req, res) {
    console.log('LOGIN endpoint hit', req.body);
    try {
      const errors = validationResult(req);

      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { email, password } = req.body;

      // Find user with roles
      const user = await User.findOne({
        where: { email },
        include: [{
          model: Role,
          as: 'roles',
          through: { attributes: [] }
        }]
      });

      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
      }

      // Check password
      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
      }

      if (!user.is_active) {
        return res.status(401).json({ success: false, message: 'Account is inactive' });
      }

      // After successful login, build the response as requested
      const userNameParts = user.name ? user.name.split(' ') : ['',''];
      const userRoles = user.roles.map(role => ({ id: role.id, name: role.name }));
      const primaryRole = userRoles[0] ? userRoles[0].name : '';
      const primaryRoleObj = userRoles[0] || null;
      const tokenVersion = Date.now();
      const token = jwt.sign({ userId: user.id, email: user.email, role: primaryRole, tokenVersion }, process.env.JWT_SECRET, { expiresIn: '1h' });
      const refreshToken = jwt.sign({ userId: user.id, tokenVersion }, process.env.JWT_SECRET, { expiresIn: '7d' });

      res.json({
        success: true,
        data: {
          userData: [{
            users: {
              id: user.id,
              email: user.email,
              phone: user.phone,
              first_name: userNameParts[0],
              last_name: userNameParts[1] || '',
              gender: user.gender || '',
              bio: user.bio || '',
              profile_picture: user.avatar || '',
              cnic: user.cnic || '',
              address: {
                street_no: 0,
                city: user.address?.city || '',
                state: user.address?.state || '',
                postal_code: user.address?.postal_code || '',
                country: user.address?.country || '',
                location: user.address?.location || ''
              },
              is_admin: user.is_admin || false,
              is_verified: user.is_verified || true,
              is_complete: user.is_complete || true,
              role: primaryRoleObj ? { id: primaryRoleObj.id, title: primaryRoleObj.name } : null
            },
            roles: primaryRoleObj ? { id: primaryRoleObj.id, title: primaryRoleObj.name } : null
          }],
          token,
          refreshToken,
          tokenVersion
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ success: false, message: 'Error during login' });
    }
  }

  async getProfile(req, res) {
    try {
      const user = await User.findByPk(req.user.id, {
        include: [{
          model: Role,
          as: 'roles',
          through: { attributes: [] }
        }],
        attributes: { exclude: ['password'] }
      });

      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      const userData = user.toJSON();
      userData.roles = user.roles.map(role => role.name);

      res.json({
        success: true,
        data: { userData: [userData] }
      });
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({ success: false, message: 'Error fetching profile' });
    }
  }

  async updateProfile(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        name,
        phone,
        gender,
        bio,
        cnic,
        address,
        password
      } = req.body;

      const user = await User.findByPk(req.user.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      // Prepare update fields
      const updateFields = {
        name: name || user.name,
        phone: phone || user.phone,
        gender: gender || user.gender,
        bio: bio || user.bio,
        cnic: cnic || user.cnic,
        address: address || user.address
      };

      // If password is provided, hash and update it
      if (password) {
        const salt = await bcrypt.genSalt(10);
        updateFields.password = await bcrypt.hash(password, salt);
      }

      // Update user fields
      await user.update(updateFields);

      // Get updated user with roles
      const updatedUser = await User.findByPk(user.id, {
        include: [{
          model: Role,
          as: 'roles',
          through: { attributes: [] }
        }],
        attributes: { exclude: ['password'] }
      });

      const userData = updatedUser.toJSON();
      userData.roles = updatedUser.roles.map(role => role.name);

      res.json({
        success: true,
        data: { userData: [userData] }
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({ success: false, message: 'Error updating profile' });
    }
  }

  async completeProfile(req, res) {
    // Alias for updateProfile to support PATCH
    return this.updateProfile(req, res);
  }

  async updateFcmToken(req, res) {
    try {
      const { fcm_token, device_id, device_name } = req.body;

      if (!fcm_token) {
        return res.status(400).json({ success: false, message: 'FCM token is required' });
      }

      const user = await User.findByPk(req.user.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      await user.update({
        fcm_token,
        device_id: device_id || null,
        device_name: device_name || null
      });

      res.json({
        success: true,
        message: 'FCM token updated successfully'
      });
    } catch (error) {
      console.error('Update FCM token error:', error);
      res.status(500).json({ success: false, message: 'Error updating FCM token' });
    }
  }

  async upsertFcmToken(req, res) {
    try {
      // Add base64 padding if needed
      const addBase64Padding = (str) => {
        if (str && typeof str === 'string') {
          while (str.length % 4) {
            str += '=';
          }
        }
        return str;
      };

      const userId = req.user.id; // Use authenticated user's id
      const { fcm_token, device_id, device_name } = req.body;

      // Add padding to FCM token if needed
      const paddedFcmToken = addBase64Padding(fcm_token);

      if (!fcm_token) {
        return res.status(400).json({ success: false, message: 'FCM token is required' });
      }

      // Find user and update
      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      await user.update({
        fcm_token: paddedFcmToken,
        device_id,
        device_name,
        last_fcm_update: new Date()
      });

      res.json({
        success: true,
        message: 'FCM token updated successfully',
        data: {
          user_id: userId,
          fcm_token: paddedFcmToken,
          device_id,
          device_name
        }
      });
    } catch (error) {
      console.error('FCM token update error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error while updating FCM token'
      });
    }
  }

  async switchRole(req, res) {
    try {
      const { role } = req.body;

      if (!role) {
        return res.status(400).json({ success: false, message: 'Role is required' });
      }

      // Check if user has the requested role
      const userRole = await UserRole.findOne({
        include: [{
          model: Role,
          as: 'roles',
          where: { name: role }
        }],
        where: { user_id: req.user.id }
      });

      if (!userRole) {
        return res.status(403).json({ success: false, message: 'User does not have this role' });
      }

      // Generate new token with new role
      const token = jwt.sign(
        {
          userId: req.user.id,
          email: req.user.email,
          role,
          tokenVersion: Date.now()
        },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      // Get user data with roles
      const user = await User.findByPk(req.user.id, {
        include: [{
          model: Role,
          as: 'roles',
          through: { attributes: [] }
        }],
        attributes: { exclude: ['password'] }
      });

      const userData = user.toJSON();
      userData.roles = user.roles.map(r => r.name);

      res.json({
        success: true,
        data: {
          userData: [{ ...userData, token }],
          token
        }
      });
    } catch (error) {
      console.error('Switch role error:', error);
      res.status(500).json({ success: false, message: 'Error switching role' });
    }
  }

  async calculateProfileCompletion(req, res) {
    try {
      const user = req.user;
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      // Fields to check
      const requiredFields = [
        'name', 'email', 'phone', 'gender', 'bio', 'cnic', 'avatar', 'address'
      ];
      const addressFields = ['street_no', 'city', 'state', 'postal_code', 'country', 'location'];

      let completedFields = 0;
      let totalFields = requiredFields.length + addressFields.length;

      // Check main fields
      requiredFields.forEach(field => {
        if (user[field] && user[field] !== '') {
          completedFields++;
        }
      });

      // Check address fields
      if (user.address) {
        addressFields.forEach(field => {
          if (user.address[field] && user.address[field] !== '') {
            completedFields++;
          }
        });
      }

      const userCompletionPercentage = Math.round((completedFields / totalFields) * 100);

      res.json({
        success: true,
        data: { userCompletionPercentage }
      });
    } catch (error) {
      res.status(500).json({ success: false, message: 'Internal server error while calculating profile completion' });
    }
  }
}

module.exports = new AuthController();
