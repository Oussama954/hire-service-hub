'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Users', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false
      },
      phone: {
        type: Sequelize.STRING
      },
      gender: {
        type: Sequelize.ENUM('male', 'female', 'other')
      },
      bio: {
        type: Sequelize.TEXT
      },
      cnic: {
        type: Sequelize.STRING
      },
      avatar: {
        type: Sequelize.STRING
      },
      rating: {
        type: Sequelize.FLOAT,
        defaultValue: 0
      },
      address: {
        type: Sequelize.JSONB
      },
      fcm_token: {
        type: Sequelize.STRING
      },
      device_id: {
        type: Sequelize.STRING
      },
      device_name: {
        type: Sequelize.STRING
      },
      last_login: {
        type: Sequelize.DATE
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
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

    await queryInterface.addIndex('Users', ['email']);
    await queryInterface.addIndex('Users', ['phone']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Users');
  }
};
