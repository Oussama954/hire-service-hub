const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const hashedPassword = await bcrypt.hash('Password@123', 10);
    
    const users = [
      {
        id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'John Doe',
        email: 'john@example.com',
        password: hashedPassword,
        phone: '+1234567890',
        gender: 'male',
        bio: 'Professional service provider with 5 years of experience',
        avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.5,
        is_active: true,
        address: JSON.stringify({
          street_no: '123',
          city: 'New York',
          state: 'NY',
          postal_code: '10001',
          country: 'USA'
        }),
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440001',
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: hashedPassword,
        phone: '+1987654321',
        gender: 'female',
        avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
        is_active: true,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: '550e8400-e29b-41d4-a716-446655440002',
        name: 'Alice Smith',
        email: 'alice.smith@example.com',
        password: hashedPassword,
        phone: '+1122334455',
        gender: 'female',
        avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
        is_active: true,
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
    // Assign roles: John/Jane = service_provider, Alice = customer
    const providerRoleId = '22222222-2222-2222-2222-222222222222';
    const customerRoleId = '11111111-1111-1111-1111-111111111111';
    const [userRoles] = await queryInterface.sequelize.query('SELECT user_id, role_id FROM "UserRoles";');
    const toInsert = [];
    // John - service_provider
    if (!userRoles.find(ur => ur.user_id === users[0].id && ur.role_id === providerRoleId)) {
      toInsert.push({
        id: uuidv4(),
        user_id: users[0].id,
        role_id: providerRoleId,
        created_at: new Date(),
        updated_at: new Date()
      });
    }
    // Jane - service_provider
    if (!userRoles.find(ur => ur.user_id === users[1].id && ur.role_id === providerRoleId)) {
      toInsert.push({
        id: uuidv4(),
        user_id: users[1].id,
        role_id: providerRoleId,
        created_at: new Date(),
        updated_at: new Date()
      });
    }
    // Alice - customer
    if (!userRoles.find(ur => ur.user_id === users[2].id && ur.role_id === customerRoleId)) {
      toInsert.push({
        id: uuidv4(),
        user_id: users[2].id,
        role_id: customerRoleId,
        created_at: new Date(),
        updated_at: new Date()
      });
    }
    if (toInsert.length) {
      await queryInterface.bulkInsert('UserRoles', toInsert);
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Users', {
      id: [
        '550e8400-e29b-41d4-a716-446655440000',
        '550e8400-e29b-41d4-a716-446655440001',
        '550e8400-e29b-41d4-a716-446655440002'
      ]
    });
    await queryInterface.bulkDelete('UserRoles', null, {});
  }
};
