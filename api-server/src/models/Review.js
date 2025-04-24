const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Review extends Model {
    static associate({ User, Service, Booking }) {
      this.belongsTo(User, { 
        as: 'customer', 
        foreignKey: 'customer_id' 
      });
      this.belongsTo(User, { 
        as: 'provider', 
        foreignKey: 'provider_id' 
      });
      this.belongsTo(Service, { 
        foreignKey: 'service_id' 
      });
      this.belongsTo(Booking, { 
        foreignKey: 'booking_id' 
      });
    }
  }

  Review.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    images: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: []
    },
    is_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Review',
    tableName: 'Reviews'
  });

  return Review;
};
