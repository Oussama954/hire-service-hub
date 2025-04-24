const sequelize = require('../config/database');

// Import model functions
const User = require('./User');
const Role = require('./Role');
const UserRole = require('./UserRole');
const Service = require('./Service');
const Category = require('./Category');
const Booking = require('./Booking');
const Review = require('./Review');
const Payment = require('./Payment');
const City = require('./City');

// Initialize models
const models = {
  User: User(sequelize),
  Role: Role(sequelize),
  UserRole: UserRole(sequelize),
  Service: Service(sequelize),
  Category: Category(sequelize),
  Booking: Booking(sequelize),
  Review: Review(sequelize),
  Payment: Payment(sequelize),
  City: City(sequelize)
};

// Set up associations
const db = {
  sequelize,
  ...models
};

if (Service.associate) Service.associate(db);
if (City.associate) City.associate(db);

Object.values(models).forEach(model => {
  if (typeof model.associate === 'function' && model !== Service && model !== City) {
    model.associate(models);
  }
});

module.exports = db;
