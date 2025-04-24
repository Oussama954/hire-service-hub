const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class UserRole extends Model {}

  UserRole.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false
    },
    role_id: {
      type: DataTypes.UUID,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'UserRole',
    tableName: 'UserRoles'
  });

  return UserRole;
};
