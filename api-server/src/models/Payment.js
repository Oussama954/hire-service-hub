const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Payment extends Model {
    static associate({ Booking, User }) {
      this.belongsTo(Booking, { 
        foreignKey: 'booking_id' 
      });
      this.belongsTo(User, { 
        as: 'payer', 
        foreignKey: 'payer_id' 
      });
    }
  }

  Payment.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    currency: {
      type: DataTypes.STRING,
      defaultValue: 'MAD'
    },
    payment_method: {
      type: DataTypes.ENUM('online', 'cash', 'cod'),
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'),
      defaultValue: 'pending'
    },
    transaction_id: {
      type: DataTypes.STRING,
      allowNull: true
    },
    payment_details: {
      type: DataTypes.JSONB,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'Payment',
    tableName: 'Payments'
  });

  return Payment;
};
