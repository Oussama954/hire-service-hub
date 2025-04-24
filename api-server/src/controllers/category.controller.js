const { Category } = require('../models');

class CategoryController {
  async listCategories(req, res) {
    try {
      const categories = await Category.findAll({ where: { is_active: true } });
      console.log('Fetched categories:', categories);
      const formatted = categories.map(cat => ({
        id: cat.id,
        title: cat.name,
        icon: cat.icon || '',
        isAvailable: cat.is_active !== false
      }));
      res.json({ success: true, data: formatted });
    } catch (error) {
      console.error('Category fetch error:', error);
      res.status(500).json({ success: false, message: 'Error fetching categories', error: error.message });
    }
  }
}

module.exports = new CategoryController();
