'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Add the 'description' column to 'Roles' table
    return queryInterface.addColumn('Roles', 'description', {
      type: Sequelize.TEXT,
      allowNull: true
    });
  },

  async down (queryInterface, Sequelize) {
    // Remove the 'description' column from 'Roles' table
    return queryInterface.removeColumn('Roles', 'description');
  }
};
