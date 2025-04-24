const { Review, Booking, Service, User } = require('../models');
const { validationResult } = require('express-validator');
const { Op } = require('sequelize');

class ReviewController {
  async createReview(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { booking_id, rating, comment } = req.body;

      // Get booking details
      const booking = await Booking.findByPk(booking_id, {
        include: [{
          model: Service,
          include: [{
            model: User,
            as: 'provider'
          }]
        }]
      });

      if (!booking) {
        return res.status(404).json({ success: false, message: 'Booking not found' });
      }

      // Verify that the user is the customer of this booking
      if (booking.customer_id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'Unauthorized' });
      }

      // Check if booking is completed
      if (booking.status !== 'completed') {
        return res.status(400).json({
          success: false,
          message: 'Cannot review an incomplete booking'
        });
      }

      // Check if review already exists
      const existingReview = await Review.findOne({
        where: { booking_id }
      });

      if (existingReview) {
        return res.status(400).json({
          success: false,
          message: 'Review already exists for this booking'
        });
      }

      // Create review
      const review = await Review.create({
        booking_id,
        service_id: booking.service_id,
        customer_id: req.user.id,
        provider_id: booking.Service.provider_id,
        rating,
        comment
      });

      // Update service rating
      const serviceReviews = await Review.findAll({
        where: { service_id: booking.service_id }
      });

      const averageRating = serviceReviews.reduce((acc, curr) => acc + curr.rating, 0) / serviceReviews.length;

      await Service.update(
        { rating: averageRating },
        { where: { id: booking.service_id } }
      );

      // Update provider rating
      const providerReviews = await Review.findAll({
        where: { provider_id: booking.Service.provider_id }
      });

      const providerAverageRating = providerReviews.reduce((acc, curr) => acc + curr.rating, 0) / providerReviews.length;

      await User.update(
        { rating: providerAverageRating },
        { where: { id: booking.Service.provider_id } }
      );

      // Get review with relations
      const createdReview = await Review.findByPk(review.id, {
        include: [
          {
            model: Booking,
            include: [{
              model: Service,
              attributes: ['id', 'title']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'avatar']
          }
        ]
      });

      // TODO: Send notification to provider
      // if (booking.Service.provider.fcm_token) {
      //   await sendNotification(booking.Service.provider.fcm_token, {
      //     title: 'New Review',
      //     body: `You received a ${rating}-star review`
      //   });
      // }

      res.status(201).json({
        success: true,
        data: createdReview
      });
    } catch (error) {
      console.error('Create review error:', error);
      res.status(500).json({ success: false, message: 'Error creating review' });
    }
  }

  async updateReview(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { id } = req.params;
      const { rating, comment } = req.body;

      // Find review
      const review = await Review.findOne({
        where: {
          id,
          customer_id: req.user.id
        }
      });

      if (!review) {
        return res.status(404).json({ success: false, message: 'Review not found' });
      }

      // Update review
      await review.update({
        rating: rating || review.rating,
        comment: comment || review.comment
      });

      // Update service rating
      const serviceReviews = await Review.findAll({
        where: { service_id: review.service_id }
      });

      const averageRating = serviceReviews.reduce((acc, curr) => acc + curr.rating, 0) / serviceReviews.length;

      await Service.update(
        { rating: averageRating },
        { where: { id: review.service_id } }
      );

      // Update provider rating
      const providerReviews = await Review.findAll({
        where: { provider_id: review.provider_id }
      });

      const providerAverageRating = providerReviews.reduce((acc, curr) => acc + curr.rating, 0) / providerReviews.length;

      await User.update(
        { rating: providerAverageRating },
        { where: { id: review.provider_id } }
      );

      // Get updated review
      const updatedReview = await Review.findByPk(id, {
        include: [
          {
            model: Booking,
            include: [{
              model: Service,
              attributes: ['id', 'title']
            }]
          },
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'avatar']
          }
        ]
      });

      res.json({
        success: true,
        data: updatedReview
      });
    } catch (error) {
      console.error('Update review error:', error);
      res.status(500).json({ success: false, message: 'Error updating review' });
    }
  }

  async deleteReview(req, res) {
    try {
      const { id } = req.params;

      // Find review
      const review = await Review.findOne({
        where: {
          id,
          customer_id: req.user.id
        }
      });

      if (!review) {
        return res.status(404).json({ success: false, message: 'Review not found' });
      }

      // Store IDs before deleting
      const { service_id, provider_id } = review;

      // Delete review
      await review.destroy();

      // Update service rating
      const serviceReviews = await Review.findAll({
        where: { service_id }
      });

      const averageRating = serviceReviews.length > 0
        ? serviceReviews.reduce((acc, curr) => acc + curr.rating, 0) / serviceReviews.length
        : 0;

      await Service.update(
        { rating: averageRating },
        { where: { id: service_id } }
      );

      // Update provider rating
      const providerReviews = await Review.findAll({
        where: { provider_id }
      });

      const providerAverageRating = providerReviews.length > 0
        ? providerReviews.reduce((acc, curr) => acc + curr.rating, 0) / providerReviews.length
        : 0;

      await User.update(
        { rating: providerAverageRating },
        { where: { id: provider_id } }
      );

      res.json({
        success: true,
        message: 'Review deleted successfully'
      });
    } catch (error) {
      console.error('Delete review error:', error);
      res.status(500).json({ success: false, message: 'Error deleting review' });
    }
  }

  async getServiceReviews(req, res) {
    try {
      const { service_id } = req.params;
      const { page = 1, limit = 10 } = req.query;

      // Calculate offset
      const offset = (page - 1) * limit;

      // Get reviews
      const { count, rows: reviews } = await Review.findAndCountAll({
        where: { service_id },
        include: [
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'avatar']
          },
          {
            model: Booking,
            attributes: ['id', 'booking_date']
          }
        ],
        order: [['created_at', 'DESC']],
        limit,
        offset
      });

      // Get service rating stats
      const ratings = await Review.findAll({
        where: { service_id },
        attributes: [
          'rating',
          [Review.sequelize.fn('COUNT', Review.sequelize.col('rating')), 'count']
        ],
        group: ['rating']
      });

      const ratingStats = {
        1: 0, 2: 0, 3: 0, 4: 0, 5: 0
      };

      ratings.forEach(r => {
        ratingStats[r.rating] = parseInt(r.get('count'));
      });

      res.json({
        success: true,
        data: {
          reviews,
          stats: {
            rating_counts: ratingStats,
            total_reviews: count
          },
          pagination: {
            total: count,
            current_page: page,
            total_pages: Math.ceil(count / limit),
            per_page: limit
          }
        }
      });
    } catch (error) {
      console.error('Get service reviews error:', error);
      res.status(500).json({ success: false, message: 'Error fetching reviews' });
    }
  }

  async getProviderReviews(req, res) {
    try {
      const { provider_id } = req.params;
      const { page = 1, limit = 10 } = req.query;

      // Calculate offset
      const offset = (page - 1) * limit;

      // Get reviews
      const { count, rows: reviews } = await Review.findAndCountAll({
        where: { provider_id },
        include: [
          {
            model: User,
            as: 'customer',
            attributes: ['id', 'name', 'avatar']
          },
          {
            model: Service,
            attributes: ['id', 'title']
          },
          {
            model: Booking,
            attributes: ['id', 'booking_date']
          }
        ],
        order: [['created_at', 'DESC']],
        limit,
        offset
      });

      // Get provider rating stats
      const ratings = await Review.findAll({
        where: { provider_id },
        attributes: [
          'rating',
          [Review.sequelize.fn('COUNT', Review.sequelize.col('rating')), 'count']
        ],
        group: ['rating']
      });

      const ratingStats = {
        1: 0, 2: 0, 3: 0, 4: 0, 5: 0
      };

      ratings.forEach(r => {
        ratingStats[r.rating] = parseInt(r.get('count'));
      });

      res.json({
        success: true,
        data: {
          reviews,
          stats: {
            rating_counts: ratingStats,
            total_reviews: count
          },
          pagination: {
            total: count,
            current_page: page,
            total_pages: Math.ceil(count / limit),
            per_page: limit
          }
        }
      });
    } catch (error) {
      console.error('Get provider reviews error:', error);
      res.status(500).json({ success: false, message: 'Error fetching reviews' });
    }
  }
}

module.exports = new ReviewController();
