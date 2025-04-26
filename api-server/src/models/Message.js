const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Message extends Model {
    static associate({ User, Conversation }) {
      // A message belongs to a conversation
      this.belongsTo(Conversation, { 
        foreignKey: 'conversation_id',
        as: 'conversation'
      });
      
      // A message belongs to a sender (user)
      this.belongsTo(User, { 
        foreignKey: 'sender_id',
        as: 'sender'
      });
    }
  }

  Message.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    text: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    is_read: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Message',
    tableName: 'Messages',
    underscored: true,
    timestamps: true,
  });

  return Message;
};
