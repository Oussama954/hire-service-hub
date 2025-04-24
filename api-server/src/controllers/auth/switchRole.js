const { User, Role, UserRole } = require('../../models');

// PATCH /api/auth/switch-role
module.exports = async function switchRole(req, res) {
  try {
    const userId = req.user.id; // Use authenticated user from verifyToken
    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID missing in token' });
    }
    const user = await User.findByPk(userId, {
      include: [{ model: Role, as: 'roles', through: { attributes: [] } }]
    });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    // Assume user has one primary role
    let currentRole = user.roles && user.roles.length > 0 ? user.roles[0] : null;
    // Dynamically fetch role IDs from DB
    const customerRole = await Role.findOne({ where: { name: 'customer' } });
    const providerRole = await Role.findOne({ where: { name: 'service_provider' } });
    let newRoleName, newRoleId;
    if (currentRole && currentRole.name === 'customer') {
      newRoleName = 'service_provider';
      newRoleId = providerRole ? providerRole.id : null;
    } else {
      newRoleName = 'customer';
      newRoleId = customerRole ? customerRole.id : null;
    }
    if (!newRoleId) {
      return res.status(500).json({ success: false, message: 'Role not found in database.' });
    }
    // Remove all current roles for this user in UserRoles (workaround for composite PK)
    await UserRole.destroy({ where: { user_id: userId } });
    // Add new role
    await UserRole.create({ user_id: userId, role_id: newRoleId });
    // Fetch updated user with new role
    const updatedUser = await User.findByPk(userId, {
      include: [{ model: Role, as: 'roles', through: { attributes: [] } }]
    });
    const updatedRole = updatedUser.roles[0];

    // Generate new JWT token with new role
    const jwt = require('jsonwebtoken');
    const tokenPayload = {
      userId: updatedUser.id,
      email: updatedUser.email,
      role: updatedRole ? updatedRole.name : null,
      tokenVersion: Date.now()
    };
    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET || 'secret', {
      expiresIn: '1h'
    });

    // Compose response
    res.json({
      success: true,
      message: `Role switched to ${updatedRole ? updatedRole.name : 'unknown'}`,
      newRole: updatedRole ? updatedRole.name : null,
      token
    });
  } catch (err) {
    console.error('Switch role error:', err);
    res.status(500).json({ success: false, message: 'Internal server error switching role' });
  }
};
