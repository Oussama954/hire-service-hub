const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Service extends Model {
    static associate({ User, Category, Booking, Review, City }) {
      this.belongsTo(User, { 
        as: 'provider', 
        foreignKey: 'provider_id' 
      });
      this.belongsTo(Category, { 
        foreignKey: 'category_id' 
      });
      this.belongsTo(City, {
        foreignKey: 'cityId',
        as: 'city'
      });
      this.hasMany(Booking, { 
        foreignKey: 'service_id' 
      });
      this.hasMany(Review, { 
        foreignKey: 'service_id' 
      });
    }
  }

  Service.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    images: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: []
    },
    cityId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'cityId',
      references: {
        model: 'Cities',
        key: 'id',
      }
    },
    availability: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {
        days: [],
        hours: []
      }
    },
    location: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    rating: {
      type: DataTypes.DECIMAL(2, 1),
      defaultValue: 0
    },
    total_reviews: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    status: {
      type: DataTypes.ENUM('pending', 'approved', 'rejected'),
      defaultValue: 'pending'
    },
    service_name: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    cover_photo: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    is_available: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    start_time: {
      type: DataTypes.STRING,
      allowNull: true
    },
    end_time: {
      type: DataTypes.STRING,
      allowNull: true
    },
    startTime: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: '00:00',
      field: 'start_time'
    },
    endTime: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: '23:59',
      field: 'end_time'
    }
  }, {
    sequelize,
    modelName: 'Service',
    tableName: 'Services'
  });

  return Service;
};
