'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Get city ids
    const [cities] = await queryInterface.sequelize.query('SELECT id, name FROM "Cities";');
    const cityMap = {};
    cities.forEach(city => { cityMap[city.name.toLowerCase()] = city.id; });

    // Update services based on location.city
    const [services] = await queryInterface.sequelize.query('SELECT id, location FROM "Services";');
    for (const service of services) {
      let cityName = null;
      try {
        const loc = typeof service.location === 'string' ? JSON.parse(service.location) : service.location;
        cityName = loc && loc.city ? loc.city.toLowerCase() : null;
      } catch (e) {}
      if (cityName && cityMap[cityName]) {
        // Use cityId with double quotes for case sensitivity
        await queryInterface.sequelize.query(`UPDATE "Services" SET "cityId" = '${cityMap[cityName]}' WHERE id = '${service.id}' AND "cityId" IS NULL`);
      }
    }
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.sequelize.query('UPDATE "Services" SET "cityId" = NULL;');
  }
};
