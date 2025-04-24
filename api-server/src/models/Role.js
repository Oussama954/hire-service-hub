const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/database');

module.exports = (sequelize) => {
  class Role extends Model {
    static associate({ User }) {
      this.belongsToMany(User, {
        through: 'UserRoles',
        foreignKey: 'role_id',
        as: 'users'
      });
    }
  }

  Role.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'Role',
    tableName: 'Roles'
  });

  return Role;
};
