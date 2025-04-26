const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/database');
const bcrypt = require('bcryptjs');

module.exports = (sequelize) => {
  class User extends Model {
    static associate({ Address, Service, Review, Role, Booking, Conversation, Message }) {
      User.belongsToMany(Role, {
        through: 'UserRoles',
        foreignKey: 'user_id',
        as: 'roles'
      });
      User.hasMany(Service, {
        foreignKey: 'provider_id',
        as: 'services'
      });
      User.hasMany(Booking, {
        foreignKey: 'customer_id',
        as: 'bookings'
      });
      User.hasMany(Booking, {
        foreignKey: 'provider_id',
        as: 'provider_bookings'
      });
      User.hasMany(Review, {
        foreignKey: 'customer_id',
        as: 'reviews_given'
      });
      User.hasMany(Review, {
        foreignKey: 'provider_id',
        as: 'reviews_received'
      });
      
      // Conversations - many-to-many relationship
      User.belongsToMany(Conversation, {
        through: 'ConversationMembers',
        foreignKey: 'user_id',
        as: 'conversations'
      });
      
      // Messages - one-to-many relationship
      User.hasMany(Message, {
        foreignKey: 'sender_id',
        as: 'sent_messages'
      });
    }

    async comparePassword(candidatePassword) {
      return await bcrypt.compare(candidatePassword, this.password);
    }

    toJSON() {
      const values = { ...this.get() };
      delete values.password;
      return values;
    }
  }

  User.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: DataTypes.STRING,
    gender: DataTypes.ENUM('male', 'female', 'other'),
    bio: DataTypes.TEXT,
    cnic: DataTypes.STRING,
    avatar: DataTypes.STRING,
    rating: {
      type: DataTypes.FLOAT,
      defaultValue: 0
    },
    address: DataTypes.JSONB,
    fcm_token: DataTypes.STRING,
    device_id: DataTypes.STRING,
    device_name: DataTypes.STRING,
    last_login: DataTypes.DATE,
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'User',
    tableName: 'Users',
    underscored: true,
    hooks: {
      beforeCreate: async (user) => {
        if (user.password) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      }
    }
  });

  return User;
};
