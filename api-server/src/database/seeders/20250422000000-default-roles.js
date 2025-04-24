'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const roles = [
      {
        id: '11111111-1111-1111-1111-111111111111',
        name: 'customer',
        permissions: JSON.stringify({
          services: ['view'],
          bookings: ['create', 'view', 'cancel'],
          reviews: ['create', 'view']
        }),
        created_at: now,
        updated_at: now
      },
      {
        id: '22222222-2222-2222-2222-222222222222',
        name: 'service_provider',
        permissions: JSON.stringify({
          services: ['create', 'view', 'update', 'delete'],
          bookings: ['view', 'update'],
          reviews: ['view', 'respond']
        }),
        created_at: now,
        updated_at: now
      },
      {
        id: '33333333-3333-3333-3333-333333333333',
        name: 'admin',
        permissions: JSON.stringify({
          users: ['view', 'update', 'delete'],
          services: ['view', 'update', 'delete'],
          categories: ['create', 'view', 'update', 'delete'],
          bookings: ['view', 'update'],
          reviews: ['view', 'delete']
        }),
        created_at: now,
        updated_at: now
      }
    ];
    for (const role of roles) {
      const [existing] = await queryInterface.sequelize.query(
        'SELECT id FROM "Roles" WHERE id = :id',
        { replacements: { id: role.id } }
      );
      if (!existing.length) {
        await queryInterface.bulkInsert('Roles', [role]);
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Roles', null, {});
  }
};
