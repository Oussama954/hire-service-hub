'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add city_id if it does not exist
    const table = await queryInterface.describeTable('Services');
    if (!table.city_id) {
      await queryInterface.addColumn('Services', 'city_id', {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'Cities',
          key: 'id',
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      });
    }
  },
  down: async (queryInterface, Sequelize) => {
    // Remove city_id if exists
    const table = await queryInterface.describeTable('Services');
    if (table.city_id) {
      await queryInterface.removeColumn('Services', 'city_id');
    }
  }
};
