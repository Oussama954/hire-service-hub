'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Bookings', 'completion_date', {
      type: Sequelize.DATE,
      allowNull: true
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('Bookings', 'completion_date');
  }
};
