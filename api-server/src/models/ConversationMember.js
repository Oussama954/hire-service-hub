const { DataTypes, Model } = require('sequelize');

module.exports = (sequelize) => {
  class ConversationMember extends Model {
    static associate({ User, Conversation }) {
      // This is just a join table, no direct associations needed
    }
  }

  ConversationMember.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    conversation_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Conversations',
        key: 'id'
      }
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    }
  }, {
    sequelize,
    modelName: 'ConversationMember',
    tableName: 'ConversationMembers',
    underscored: true
  });

  return ConversationMember;
};
