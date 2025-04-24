const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize({
  database: process.env.DB_NAME || 'hire_service_hub',
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  dialect: 'postgres',
  logging: false,
  define: {
    timestamps: true,
    underscored: true
  }
});

module.exports = sequelize;
