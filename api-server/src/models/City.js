const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class City extends Model {
    static associate(models) {
      City.hasMany(models.Service, { foreignKey: 'cityId', as: 'services' });
    }
  }
  City.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
      },
    },
    {
      sequelize,
      modelName: 'City',
      tableName: 'Cities',
      timestamps: false
    }
  );
  return City;
};
