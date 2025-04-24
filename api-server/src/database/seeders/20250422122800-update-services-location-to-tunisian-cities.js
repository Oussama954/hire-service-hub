'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Map of service IDs to Tunisian city names
    const serviceCityMap = {
      '550e8400-e29b-41d4-a716-446655440005': 'Tunis',
      '550e8400-e29b-41d4-a716-446655440006': 'Sfax',
    };
    // Get city ids
    const [cities] = await queryInterface.sequelize.query('SELECT id, name FROM "Cities";');
    const cityMap = {};
    cities.forEach(city => { cityMap[city.name.toLowerCase()] = city.id; });

    for (const [serviceId, cityName] of Object.entries(serviceCityMap)) {
      const cityId = cityMap[cityName.toLowerCase()];
      if (cityId) {
        await queryInterface.bulkUpdate(
          'Services',
          {
            location: JSON.stringify({ city: cityName, state: '', country: 'Tunisia' }),
            city_id: cityId
          },
          { id: serviceId }
        );
      }
    }
  },
  down: async (queryInterface, Sequelize) => {
    // Optionally revert to old location/cityId
  }
};
