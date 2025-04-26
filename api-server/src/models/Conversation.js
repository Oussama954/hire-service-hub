const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class Conversation extends Model {
    static associate({ User, Message }) {
      // A conversation belongs to multiple users (members)
      this.belongsToMany(User, {
        through: 'ConversationMembers',
        foreignKey: 'conversation_id',
        as: 'members'
      });
      
      // A conversation has many messages
      this.hasMany(Message, {
        foreignKey: 'conversation_id',
        as: 'messages'
      });
    }
  }

  Conversation.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    last_message: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    last_message_time: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'Conversation',
    tableName: 'Conversations',
    underscored: true,
    timestamps: true,
  });

  return Conversation;
};
