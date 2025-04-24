'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Remove the unused city_id column from Services
    await queryInterface.removeColumn("Services", "city_id");
  },

  async down (queryInterface, Sequelize) {
    // Add the city_id column back if needed (for rollback)
    await queryInterface.addColumn("Services", "city_id", {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: "Cities",
        key: "id"
      }
    });
  }
};
