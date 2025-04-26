const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Booking extends Model {
    static associate({ Service, User, Payment, Review }) {
      this.belongsTo(Service, { 
        foreignKey: 'service_id' 
      });
      this.belongsTo(User, { 
        as: 'customer', 
        foreignKey: 'customer_id' 
      });
      this.belongsTo(User, { 
        as: 'provider', 
        foreignKey: 'provider_id' 
      });
      this.hasOne(Payment, { 
        foreignKey: 'booking_id' 
      });
      this.hasOne(Review, { 
        foreignKey: 'booking_id' 
      });
    }
  }

  Booking.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    booking_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    start_time: {
      type: DataTypes.TIME,
      allowNull: false
    },
    end_time: {
      type: DataTypes.TIME,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'accepted', 'rejected', 'processing', 'completed', 'cancelled'),
      defaultValue: 'pending',
      allowNull: false
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    special_instructions: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    completion_date: {
      type: DataTypes.DATE,
      allowNull: true
    },
    service_start_time: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'The actual date and time when the service is scheduled to start'
    },
    service_end_time: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'The actual date and time when the service is scheduled to end'
    },
    cancellation_reason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    customer_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    provider_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    service_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Services',
        key: 'id'
      }
    }
  }, {
    sequelize,
    modelName: 'Booking',
    tableName: 'Bookings',
    underscored: true
  });

  return Booking;
};
