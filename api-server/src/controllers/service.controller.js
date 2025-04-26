const { Op } = require('sequelize');
const { Service, User, Category, Review, City } = require('../models');
const { validationResult } = require('express-validator');
const businessNotificationService = require('../services/business-notification.service');

// References to store socket.io instance and connected users
let io;
let connectedUsers = [];

// Function to initialize socket references
function setSocketReferences(socketIo, users) {
  io = socketIo;
  connectedUsers = users;
  console.log('Socket references set in ServiceController');
}

class ServiceController {
  async createService(req, res) {
    try {
      console.log('Create Service Payload:', req.body);

      // Accept legacy Flutter fields
      const normalized = {
        title: req.body.title || req.body.service_name || '',
        description: req.body.description,
        price: req.body.price,
        category_id: req.body.category_id,
        availability: req.body.availability || {
          days: [],
          hours: []
        },
        location: req.body.location || {},
        images: req.body.images && req.body.images.length > 0
          ? req.body.images
          : (req.body.cover_photo ? [req.body.cover_photo] : []),
        is_available: req.body.is_available,
        startTime: req.body.start_time || '00:00',
        endTime: req.body.end_time || '23:59',
        city_id: req.body.city_id
      };
      console.log('Normalized Service Payload:', normalized);

     

      // Only include model fields
      const serviceFields = {
        title: normalized.title,
        description: normalized.description,
        price: normalized.price,
        category_id: normalized.category_id,
        cityId: normalized.city_id, // Map from city_id to cityId for the database
        provider_id: req.user.id,
        availability: normalized.availability,
        location: normalized.location,
        images: normalized.images,
        status: 'pending',
        startTime: normalized.startTime,
        endTime: normalized.endTime,
        is_active: normalized.is_available !== undefined ? normalized.is_available : true
      };
      
      console.log('Creating service with cityId:', normalized.city_id);

      let service;
      try {
        service = await Service.create(serviceFields);
      } catch (err) {
        return res.status(500).json({ success: false, message: 'Error creating service', error: err.message });
      }

      // Get service with relations
      let createdService;
      try {
        createdService = await Service.findByPk(service.id, {
          include: [
            {
              model: User,
              as: 'provider',
              attributes: ['id', 'name', 'email', 'phone', 'avatar']
            },
            {
              model: Category,
              attributes: ['id', 'name', 'icon']
            },
            {
              model: City,
              as: 'city',
              attributes: ['id', 'name']
            }
          ]
        });
      } catch (err) {
        return res.status(500).json({ success: false, message: 'Error fetching created service', error: err.message });
      }

      // Fix price type/format as before
      let cleanService = createdService && createdService.toJSON ? createdService.toJSON() : createdService;
      if (cleanService && typeof cleanService.price === 'number') {
        cleanService.price = Number.isInteger(cleanService.price)
          ? cleanService.price.toString()
          : cleanService.price.toFixed(2);
      } else if (cleanService && typeof cleanService.price === 'string') {
        const parsed = parseFloat(cleanService.price);
        cleanService.price = Number.isInteger(parsed)
          ? parsed.toString()
          : parsed.toFixed(2);
      }
      cleanService.service_name = cleanService.title;
      delete cleanService.city;
      res.json({
        success: true,
        data: {data:[cleanService]}
      });
    } catch (error) {
      console.error('Create service error:', error);
      res.status(500).json({ success: false, message: 'Error creating service', error: error.message, stack: error.stack });
    }
  }

  async updateService(req, res) {
    try {
      console.log('🔄 UPDATE SERVICE REQUEST:');
      console.log('🔹 Service ID:', req.params.id);
      console.log('🔹 User ID:', req.user.id);
      console.log('🔹 Request Body:', JSON.stringify(req.body));
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('❌ Validation errors:', errors.array());
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { id } = req.params;
      const {
        title,
        description,
        price,
        category_id,
        city_id,
        availability,
        location,
        images,
        is_active,
        start_time,
        end_time
      } = req.body;

      // Find service
      const service = await Service.findOne({
        where: {
          id,
          provider_id: req.user.id
        }
      });

      if (!service) {
        return res.status(404).json({ success: false, message: 'Service not found' });
      }

      // Log all update fields for debugging
      console.log('\ud83d\udd39 Updating service fields:');
      console.log('title:', title);
      console.log('description:', description);
      console.log('price:', price);
      console.log('category_id:', category_id);
      console.log('city_id:', city_id);
      console.log('is_active:', is_active);
      console.log('start_time:', start_time);
      console.log('end_time:', end_time);
      
      // Update service
      const updateData = {
        title,
        description,
        price,
        category_id,
        cityId: city_id,
        availability,
        location,
        images: images || service.images,
        is_active: typeof is_active === 'boolean' ? is_active : service.is_active,
        startTime: start_time || service.startTime,
        endTime: end_time || service.endTime,
        status: status || service.status
      };

      // Store the previous status before update
      const previousStatus = service.status;
      
      await service.update(updateData);
      console.log('Service updated:', { id: service.id, ...updateData });
      
      // If status was updated, send notification to the service provider
      if (updateData.status && previousStatus !== updateData.status) {
        try {
          if (io && connectedUsers) {
            await businessNotificationService.sendServiceStatusNotification(
              service.id,
              updateData.status,
              io,
              connectedUsers
            );
            console.log(`Service status notification sent to provider ${service.provider_id} for status ${updateData.status}`);
          }
        } catch (notificationError) {
          console.error('Failed to send service status notification:', notificationError);
          // Continue execution - notification failure shouldn't prevent service update
        }
      }

      // Get updated service with relations
      const updatedService = await Service.findByPk(service.id, {
        include: [
          {
            model: User,
            as: 'provider',
            attributes: ['id', 'name', 'email', 'phone', 'avatar']
          },
          {
            model: Category,
            attributes: ['id', 'name', 'icon']
          }
        ]
      });

      // Format the response to match other API endpoints
      let cleanService = updatedService && updatedService.toJSON ? updatedService.toJSON() : updatedService;
      if (cleanService && typeof cleanService.price === 'number') {
        cleanService.price = Number.isInteger(cleanService.price)
          ? cleanService.price.toString()
          : cleanService.price.toFixed(2);
      } else if (cleanService && typeof cleanService.price === 'string') {
        const parsed = parseFloat(cleanService.price);
        cleanService.price = Number.isInteger(parsed)
          ? parsed.toString()
          : parsed.toFixed(2);
      }
      
      // Map backend fields to match frontend expectations
      cleanService.service_name = cleanService.title || '';
      cleanService.user_id = cleanService.provider_id;
      cleanService.is_available = cleanService.is_active !== undefined ? cleanService.is_active : true;
      
      res.json({
        success: true,
        data: [cleanService] // Use array format to match other endpoints
      });
    } catch (error) {
      console.error('Update service error:', error);
      res.status(500).json({ success: false, message: 'Error updating service' });
    }
  }

  async deleteService(req, res) {
    try {
      const { id } = req.params;

      // Find service
      const service = await Service.findOne({
        where: {
          id,
          provider_id: req.user.id
        }
      });

      if (!service) {
        return res.status(404).json({ success: false, message: 'Service not found' });
      }

      // Delete service
      await service.destroy();

      res.json({
        success: true,
        message: 'Service deleted successfully'
      });
    } catch (error) {
      console.error('Delete service error:', error);
      res.status(500).json({ success: false, message: 'Error deleting service' });
    }
  }

  async getService(req, res) {
    try {
      const { id } = req.params;

      // Get service with relations
      const service = await Service.findByPk(id, {
        include: [
          {
            model: User,
            as: 'provider',
            attributes: ['id', 'name', 'email', 'phone', 'avatar', 'bio', 'rating']
          },
          {
            model: Category,
            attributes: ['id', 'name', 'icon']
          },
          {
            model: City,
            as: 'city',
            attributes: ['id', 'name']
          },
          {
            model: Review,
            include: [
              { model: User, as: 'customer' },
              { model: User, as: 'provider' }
            ]
          }
        ]
      });
      if (!service) {
        return res.status(404).json({ success: false, message: 'Service not found' });
      }

      const serviceData = service.toJSON();
      console.log(serviceData);

      // Replace provider with user and avatar with profilePicture
      if (serviceData.provider) {
        serviceData.user = {
          ...serviceData.provider,
          profilePicture: serviceData.provider.avatar
        };
        delete serviceData.user.avatar;
        delete serviceData.provider;
      }
      serviceData.coverPhoto = serviceData.cover_photo;
      // Add city name
      serviceData.city = serviceData.city ? serviceData.city.name : null;
      serviceData.reviews = service.Reviews;
      serviceData.startTime = service.startTime;
      serviceData.endTime = service.endTime;
      serviceData.isAvailable = service.is_active;
      serviceData.service_name = service.title;
      serviceData.userId = serviceData.provider_id;
      delete serviceData.provider_id;
      res.json({
        success: true,
        data: {
          specificService: serviceData,
          averageRating: serviceData.reviews?.length > 0 ? serviceData.reviews.reduce((acc, review) => acc + review.rating, 0) / serviceData.reviews.length : 0
        }
      });
    } catch (error) {
      console.error('Get service error:', error);
      res.status(500).json({ success: false, message: 'Error fetching service' });
    }
  }

  async listServices(req, res) {
    try {
      const {
        category_id,
        search,
        min_price,
        max_price,
        rating,
        sort_by = 'created_at',
        sort_order = 'DESC',
        page = 1,
        limit = 10
      } = req.query;

      // Build where clause
      const where = { is_active: true };
      // Accept both category_id and categoryId for filtering
      const categoryIdParam = req.query.category_id || req.query.categoryId;
      if (categoryIdParam) {
        // Check if category exists before filtering
        const categoryExists = await Category.findOne({ where: { id: categoryIdParam.toString() } });
        if (!categoryExists) {
          return res.json({
            success: true,
            data: [],
            pagination: {
              total: 0,
              page: Number(page),
              limit: Number(limit),
              totalPages: 0
            }
          });
        }
        where.category_id = categoryIdParam.toString();
      }
      if (min_price) where.price = { ...where.price, [Op.gte]: min_price };
      if (max_price) where.price = { ...where.price, [Op.lte]: max_price };
      if (rating) where.rating = { [Op.gte]: rating };
      if (search) {
        where[Op.or] = [
          { title: { [Op.iLike]: `%${search}%` } },
          { description: { [Op.iLike]: `%${search}%` } }
        ];
      }
      // Allow filtering by city ID or name
      let cityInclude = {
        model: City,
        as: 'city',
        attributes: ['id', 'name']
      };
      if (req.query.city_id) {
        console.log('Filtering by city_id:', req.query.city_id);
        // Match the field name exactly as defined in the Service model
        where.cityId = req.query.city_id;
      } else if (req.query.city) {
        cityInclude.where = { name: { [Op.iLike]: req.query.city } };
      }

      // Calculate offset
      const offset = (page - 1) * limit;

      // Defensive: ensure limit and offset are numbers
      const parsedLimit = Number(limit) || 10;
      const parsedOffset = Number(offset) || 0;

      // Get services
      const { count, rows: services } = await Service.findAndCountAll({
        where,
        include: [
          {
            model: User,
            as: 'provider',
            attributes: ['id', 'name', 'avatar', 'rating']
          },
          {
            model: Category,
            attributes: ['id', 'name', 'icon']
          },
          cityInclude,
          {
            model: Review,
            attributes: ['id', 'rating', 'comment', 'created_at', 'customer_id'],
            include: [
              {
                model: User,
                as: 'customer',
                attributes: ['id', 'name', 'avatar']
              }
            ]
          }
        ],
        order: [[sort_by, sort_order]],
        limit: parsedLimit,
        offset: parsedOffset
      });

      // Format service data
      const formatted = services.map(service => {
        const serviceData = service.toJSON();
        // Map backend fields to match frontend expectations
        serviceData.service_name = serviceData.title || '';
        serviceData.user_id = serviceData.provider_id;
        serviceData.category_id = serviceData.category_id;
        serviceData.is_available = serviceData.is_available !== undefined ? serviceData.is_available : true;
        serviceData.coverPhoto = serviceData.cover_photo;
        // Optionally add base URL if needed for cover_photo
        // if (serviceData.cover_photo && !serviceData.cover_photo.startsWith('http')) {
        //   serviceData.cover_photo = `${process.env.BASE_URL || ''}/${serviceData.cover_photo}`;
        // }
        serviceData.city = serviceData.city ? serviceData.city.name : null;
        serviceData.user = serviceData.provider;
        delete serviceData.title;
        delete serviceData.provider;
        delete serviceData.images;
        delete serviceData.Reviews;
        delete serviceData.provider_id;
        return serviceData;
      });

      res.json({
        success: true,
        data: formatted,
        pagination: {
          total: count,
          page: Number(page),
          limit: parsedLimit,
          totalPages: Math.ceil(count / parsedLimit)
        }
      });
    } catch (error) {
      console.error('List services error:', error);
      res.status(500).json({ success: false, message: 'Error fetching services' });
    }
  }

  async getProviderServices(req, res) {
    try {
      // Use authenticated user's id for provider_id
      const provider_id = req.user.id;
      const { status } = req.query;

      const where = { provider_id };
      if (status) where.status = status;

      const services = await Service.findAll({
        where,
        include: [
          {
            model: Category,
            attributes: ['id', 'name', 'icon']
          }
        ],
        order: [['created_at', 'DESC']]
      });

      res.json({
        success: true,
        data: services
      });
    } catch (error) {
      console.error('Get provider services error:', error);
      res.status(500).json({ success: false, message: 'Error fetching provider services' });
    }
  }

  async uploadCoverPhoto(req, res) {
    try {
      const { id } = req.params;
      if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file uploaded.' });
      }

      // Find the service
      const service = await Service.findByPk(id);
      if (!service) {
        return res.status(404).json({ success: false, message: 'Service not found.' });
      }

      // Upload to Cloudinary
      const cloudinary = require('../utils/cloudinary');
      const fs = require('fs');
      let result;
      try {
        result = await cloudinary.uploader.upload(req.file.path, { folder: 'service_covers' });
      } catch (cloudErr) {
        try { fs.unlinkSync(req.file.path); } catch (e) {}
        return res.status(500).json({ success: false, message: 'Cloudinary upload error', error: cloudErr.message });
      }

      // Remove local file after upload
      try { fs.unlinkSync(req.file.path); } catch (fsErr) {}

      // Update DB
      service.cover_photo = result.secure_url;
      await service.save();

      // Return updated service
      let cleanService = service.toJSON();
      if (typeof cleanService.price === 'number') {
        cleanService.price = Number.isInteger(cleanService.price)
          ? cleanService.price.toString()
          : cleanService.price.toFixed(2);
      } else if (typeof cleanService.price === 'string') {
        const parsed = parseFloat(cleanService.price);
        cleanService.price = Number.isInteger(parsed)
          ? parsed.toString()
          : parsed.toFixed(2);
      }
      cleanService.service_name = cleanService.title;

      res.json({
        success: true,
        data: [cleanService]
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Upload error', error: err.message });
    }
  }
}

const serviceController = new ServiceController();

module.exports = {
  controller: serviceController,
  setSocketReferences
};
