'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Bookings', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      service_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Services',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      customer_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
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
      booking_date: {
        type: Sequelize.DATEONLY,
        allowNull: false
      },
      start_time: {
        type: Sequelize.TIME,
        allowNull: false
      },
      end_time: {
        type: Sequelize.TIME,
        allowNull: false
      },
      status: {
        type: Sequelize.ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled'),
        defaultValue: 'pending'
      },
      amount: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false
      },
      location: {
        type: Sequelize.JSONB
      },
      special_instructions: {
        type: Sequelize.TEXT
      },
      cancellation_reason: {
        type: Sequelize.TEXT
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    await queryInterface.addIndex('Bookings', ['service_id']);
    await queryInterface.addIndex('Bookings', ['customer_id']);
    await queryInterface.addIndex('Bookings', ['provider_id']);
    await queryInterface.addIndex('Bookings', ['booking_date']);
    await queryInterface.addIndex('Bookings', ['status']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Bookings');
  }
};
