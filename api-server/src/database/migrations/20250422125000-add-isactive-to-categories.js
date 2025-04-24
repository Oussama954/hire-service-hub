'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Check if the column already exists before adding
    const tableDesc = await queryInterface.describeTable('Categories');
    if (!tableDesc['is_active']) {
      await queryInterface.addColumn('Categories', 'is_active', {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false
      });
    } else {
      console.log('Column is_active already exists in Categories. Skipping addColumn.');
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Categories', 'is_active');
  }
};
