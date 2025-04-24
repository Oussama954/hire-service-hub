'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add 'id' column as UUID primary key
    await queryInterface.addColumn('UserRoles', 'id', {
      type: Sequelize.UUID,
      defaultValue: Sequelize.literal('gen_random_uuid()'),
      allowNull: false,
      primaryKey: true
    });

    // Remove composite primary key if exists (Postgres only)
    // You may need to manually drop the old PK constraint if Sequelize cannot do it
    // Example: await queryInterface.removeConstraint('UserRoles', 'UserRoles_pkey');
    // Then add new PK:
    // await queryInterface.addConstraint('UserRoles', ['id'], { type: 'primary key', name: 'UserRoles_pkey' });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('UserRoles', 'id');
    // Optionally, re-add composite PK here if needed
  }
};
