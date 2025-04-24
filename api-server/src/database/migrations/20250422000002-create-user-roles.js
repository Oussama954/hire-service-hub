'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('UserRoles', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      role_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Roles',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    await queryInterface.addIndex('UserRoles', ['user_id']);
    await queryInterface.addIndex('UserRoles', ['role_id']);
    await queryInterface.addIndex('UserRoles', ['user_id', 'role_id'], {
      unique: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('UserRoles');
  }
};
