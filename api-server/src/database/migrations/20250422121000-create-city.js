'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.sequelize.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');
    await queryInterface.createTable('Cities', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.literal('uuid_generate_v4()')
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Cities');
  }
};
