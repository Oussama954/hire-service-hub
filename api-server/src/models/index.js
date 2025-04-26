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
const Conversation = require('./Conversation');
const Message = require('./Message');
const ConversationMember = require('./ConversationMember');

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
  City: City(sequelize),
  Conversation: Conversation(sequelize),
  Message: Message(sequelize),
  ConversationMember: ConversationMember(sequelize)
};

// Set up associations
const db = {
  sequelize,
  ...models
};

// First process User model to ensure its associations are available early
if (models.User.associate) models.User.associate(db);

// Then Service model which depends on User
if (models.Service.associate) models.Service.associate(db);

// Process City model which might be referenced by other models
if (models.City.associate) models.City.associate(db);

// Process chat-related models in a specific order
if (models.ConversationMember.associate) models.ConversationMember.associate(db);
if (models.Conversation.associate) models.Conversation.associate(db);
if (models.Message.associate) models.Message.associate(db);

// Process all other remaining models
Object.values(models).forEach(model => {
  if (typeof model.associate === 'function' && 
      model !== models.User &&
      model !== models.Service && 
      model !== models.City && 
      model !== models.Conversation && 
      model !== models.Message && 
      model !== models.ConversationMember) {
    model.associate(db);
  }
});

module.exports = db;
