'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Roles', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      name: {
        type: Sequelize.ENUM('customer', 'service_provider', 'admin'),
        allowNull: false
      },
      permissions: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    });

    // Add unique constraint on name
    await queryInterface.addIndex('Roles', ['name'], {
      unique: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Roles');
  }
};
