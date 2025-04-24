'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Services', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      title: {
        type: Sequelize.STRING,
        allowNull: false
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false
      },
      images: {
        type: Sequelize.ARRAY(Sequelize.STRING),
        defaultValue: []
      },
      availability: {
        type: Sequelize.JSONB,
        allowNull: false,
        defaultValue: {
          days: [],
          hours: []
        }
      },
      location: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      rating: {
        type: Sequelize.DECIMAL(2, 1),
        defaultValue: 0
      },
      total_reviews: {
        type: Sequelize.INTEGER,
        defaultValue: 0
      },
      provider_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Categories',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      is_available: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      status: {
        type: Sequelize.ENUM('pending', 'approved', 'rejected'),
        defaultValue: 'pending'
      },
      service_name: {
        type: Sequelize.STRING,
        allowNull: true
      },
      cover_photo: {
        type: Sequelize.STRING,
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false
      }
    });

    // Add indexes
    await queryInterface.addIndex('Services', ['provider_id']);
    await queryInterface.addIndex('Services', ['category_id']);
    await queryInterface.addIndex('Services', ['status']);
    await queryInterface.addIndex('Services', ['is_active']);
    await queryInterface.addIndex('Services', ['is_available']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Services');
  }
};
