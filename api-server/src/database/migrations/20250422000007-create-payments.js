'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Payments', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      booking_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Bookings',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      payer_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      amount: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false
      },
      currency: {
        type: Sequelize.STRING,
        defaultValue: 'MAD'
      },
      payment_method: {
        type: Sequelize.ENUM('online', 'cash', 'cod'),
        allowNull: false
      },
      status: {
        type: Sequelize.ENUM('pending', 'completed', 'failed', 'refunded'),
        defaultValue: 'pending'
      },
      transaction_id: {
        type: Sequelize.STRING,
        allowNull: true
      },
      payment_details: {
        type: Sequelize.JSONB,
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
    await queryInterface.addIndex('Payments', ['booking_id']);
    await queryInterface.addIndex('Payments', ['payer_id']);
    await queryInterface.addIndex('Payments', ['status']);
    await queryInterface.addIndex('Payments', ['transaction_id']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Payments');
  }
};
