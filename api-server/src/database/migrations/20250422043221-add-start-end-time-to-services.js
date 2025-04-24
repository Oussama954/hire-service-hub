"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("Services", "start_time", {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: "00:00"
    });
    await queryInterface.addColumn("Services", "end_time", {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: "23:59"
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("Services", "start_time");
    await queryInterface.removeColumn("Services", "end_time");
  }
};
