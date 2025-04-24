'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Clean up any leftover columns
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" DROP COLUMN IF EXISTS old_status;
        ALTER TABLE "Bookings" DROP COLUMN IF EXISTS temp_status;
        ALTER TABLE "Bookings" DROP COLUMN IF EXISTS new_status;
      `);

      // Add completion_date column
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" ADD COLUMN IF NOT EXISTS completion_date TIMESTAMP;
      `);

      // Convert status to text temporarily
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" ALTER COLUMN status TYPE TEXT;
      `);

      // Update the values
      await queryInterface.sequelize.query(`
        UPDATE "Bookings" 
        SET status = 
          CASE status 
            WHEN 'confirmed' THEN 'processing'
            WHEN 'pending' THEN 'pending'
            WHEN 'completed' THEN 'completed'
            WHEN 'cancelled' THEN 'cancelled'
            ELSE 'pending'
          END;
      `);

      // Drop the old enum type
      await queryInterface.sequelize.query(`
        DROP TYPE IF EXISTS "enum_bookings_status";
      `);

      // Create the new enum type
      await queryInterface.sequelize.query(`
        CREATE TYPE "enum_bookings_status" AS ENUM ('pending', 'accepted', 'rejected', 'processing', 'completed', 'cancelled');
      `);

      // Convert the column back to enum
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" ALTER COLUMN status TYPE "enum_bookings_status" USING status::enum_bookings_status;
      `);

    } catch (error) {
      console.error('Migration error:', error);
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    try {
      // Convert status to text temporarily
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" ALTER COLUMN status TYPE TEXT;
      `);

      // Update the values back
      await queryInterface.sequelize.query(`
        UPDATE "Bookings" 
        SET status = 
          CASE status 
            WHEN 'accepted' THEN 'confirmed'
            WHEN 'rejected' THEN 'cancelled'
            WHEN 'processing' THEN 'confirmed'
            WHEN 'pending' THEN 'pending'
            WHEN 'completed' THEN 'completed'
            WHEN 'cancelled' THEN 'cancelled'
            ELSE 'pending'
          END;
      `);

      // Drop the new enum type
      await queryInterface.sequelize.query(`
        DROP TYPE IF EXISTS "enum_bookings_status";
      `);

      // Create the old enum type
      await queryInterface.sequelize.query(`
        CREATE TYPE "enum_bookings_status" AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
      `);

      // Convert the column back to the old enum
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" ALTER COLUMN status TYPE "enum_bookings_status" USING status::enum_bookings_status;
      `);

      // Drop completion_date column
      await queryInterface.sequelize.query(`
        ALTER TABLE "Bookings" DROP COLUMN IF EXISTS completion_date;
      `);

    } catch (error) {
      console.error('Migration error:', error);
      throw error;
    }
  }
};
