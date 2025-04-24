'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const cities = [
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e01', name: 'Tunis' },
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e02', name: 'Sfax' },
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e03', name: 'Sousse' },
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e04', name: 'Gabes' },
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e05', name: 'Kairouan' },
      { id: 'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e10', name: 'Monastir' }
    ];
    for (const city of cities) {
      const [existing] = await queryInterface.sequelize.query(
        'SELECT id FROM "Cities" WHERE id = :id OR name = :name',
        { replacements: { id: city.id, name: city.name } }
      );
      if (!existing.length) {
        await queryInterface.bulkInsert('Cities', [city]);
      }
    }
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Cities', {
      id: [
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e01',
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e02',
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e03',
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e04',
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e05',
        'b1d1e1e1-e1e1-4e1e-8e1e-1e1e1e1e1e10'
      ]
    });
  }
};
