const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Category extends Model {
    static associate({ Service }) {
      this.hasMany(Service, { 
        foreignKey: 'category_id' 
      });
    }
  }

  Category.init({
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
    },
    // image: {
    //   type: DataTypes.STRING,
    //   allowNull: true
    // },
    icon: {
      type: DataTypes.STRING,
      allowNull: true
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'Category',
    tableName: 'Categories'
  });

  return Category;
};
