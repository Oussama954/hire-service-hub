'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const categories = [
      {
        id: '550e8400-e29b-41d4-a716-446655440002',
        name: 'Cleaning',
        description: 'House and office cleaning services',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440003',
        name: 'Plumbing',
        description: 'Plumbing repairs and maintenance',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440004',
        name: 'Window Cleaning',
        description: 'Professional window washing',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440005',
        name: 'Gardening',
        description: 'Garden and outdoor maintenance',
        created_at: new Date(),
        updated_at: new Date()
      }
    ];
    for (const category of categories) {
      const [existing] = await queryInterface.sequelize.query(
        'SELECT id FROM "Categories" WHERE id = :id OR name = :name',
        { replacements: { id: category.id, name: category.name } }
      );
      if (!existing.length) {
        await queryInterface.bulkInsert('Categories', [category]);
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Categories', {
      id: [
        '550e8400-e29b-41d4-a716-446655440002',
        '550e8400-e29b-41d4-a716-446655440003',
        '550e8400-e29b-41d4-a716-446655440004',
        '550e8400-e29b-41d4-a716-446655440005'
      ]
    });
  }
};
