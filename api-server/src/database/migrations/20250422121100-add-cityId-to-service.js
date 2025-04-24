'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('Services', 'cityId', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'Cities',
        key: 'id',
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL',
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Services', 'cityId');
  }
};
