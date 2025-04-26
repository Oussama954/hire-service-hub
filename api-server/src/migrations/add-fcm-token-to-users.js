'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('Users', 'fcm_token', {
      type: Sequelize.STRING,
      allowNull: true,
    });
    
    console.log('Added fcm_token column to Users table');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Users', 'fcm_token');
    console.log('Removed fcm_token column from Users table');
  }
};
