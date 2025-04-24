module.exports = {
  up: async (queryInterface, Sequelize) => {
    const categories = [
      {
        id: '550e8400-e29b-41d4-a716-446655440002',
        name: 'Cleaning',
        description: 'Professional cleaning services for homes and offices',
        icon: 'https://cdn-icons-png.flaticon.com/512/1046/1046857.png',
        is_active: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440003',
        name: 'Plumbing',
        description: 'Expert plumbing services and repairs',
        icon: 'https://cdn-icons-png.flaticon.com/512/2933/2933188.png',
        is_active: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440004',
        name: 'Electrical',
        description: 'Professional electrical installation and repairs',
        icon: 'https://cdn-icons-png.flaticon.com/512/1046/1046859.png',
        is_active: true,
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
    await queryInterface.bulkDelete('Categories', null, {});
  }
};
