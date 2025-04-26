'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Bookings', 'service_start_time', {
      type: Sequelize.DATE,
      allowNull: true,
      comment: 'The actual date and time when the service is scheduled to start'
    });
    
    await queryInterface.addColumn('Bookings', 'service_end_time', {
      type: Sequelize.DATE,
      allowNull: true,
      comment: 'The actual date and time when the service is scheduled to end'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('Bookings', 'service_start_time');
    await queryInterface.removeColumn('Bookings', 'service_end_time');
  }
};
