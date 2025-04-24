const { City } = require('../models');

class CityController {
  async listCities(req, res) {
    try {
      const cities = await City.findAll({ attributes: ['id', 'name'] });
      res.json({ success: true, data: cities });
    } catch (error) {
      res.status(500).json({ success: false, message: 'Error fetching cities', error: error.message });
    }
  }
}

module.exports = new CityController();
