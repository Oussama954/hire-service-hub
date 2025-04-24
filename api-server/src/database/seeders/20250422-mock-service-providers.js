'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const users = [
      {
        id: '550e8400-e29b-41d4-a716-446655440001',
        name: 'Alice Smith',
        email: 'alice.smith@example.com',
        password: '$2b$10$abcdefghijklmnopqrstuv', // mock hash
        phone: '1234567890',
        gender: 'female',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440002',
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com',
        password: '$2b$10$abcdefghijklmnopqrstuv', // mock hash
        phone: '0987654321',
        gender: 'male',
        created_at: new Date(),
        updated_at: new Date()
      }
    ];
    for (const user of users) {
      const [existing] = await queryInterface.sequelize.query(
        'SELECT id FROM "Users" WHERE id = :id OR email = :email',
        { replacements: { id: user.id, email: user.email } }
      );
      if (!existing.length) {
        await queryInterface.bulkInsert('Users', [user]);
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Users', {
      id: [
        '550e8400-e29b-41d4-a716-446655440001',
        '550e8400-e29b-41d4-a716-446655440002'
      ]
    });
  }
};
