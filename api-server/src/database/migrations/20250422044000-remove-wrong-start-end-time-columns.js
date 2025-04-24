"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove incorrectly named columns if they exist
    try {
      await queryInterface.removeColumn("Services", "startTime");
    } catch (e) {}
    try {
      await queryInterface.removeColumn("Services", "endTime");
    } catch (e) {}
  },
  down: async (queryInterface, Sequelize) => {
    // Optionally add them back (not required for your case)
  }
};
