const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const bodyParser = require('body-parser');

require('dotenv').config();

const app = express();
const upload = multer({ dest: 'uploads/' });

// Import routes
const authRoutes = require('./src/routes/auth.routes');
const serviceRoutes = require('./src/routes/service.routes');
const bookingRoutes = require('./src/routes/booking.routes');
const paymentRoutes = require('./src/routes/payment.routes');
const reviewRoutes = require('./src/routes/review.routes');
const categoryRoutes = require('./src/routes/category.routes');
const cityRoutes = require('./src/routes/city.routes');

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Enable query parameter logging
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url} - Query:`, req.query);
  next();
});

// Remove trailing slashes from URLs
app.use((req, res, next) => {
  if (req.url.endsWith('/')) {
    req.url = req.url.slice(0, -1);
  }
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/service', serviceRoutes);
app.use('/api/bookings', bookingRoutes); // Main endpoint (plural)
app.use('/api/booking', bookingRoutes);  // Alias for client compatibility (singular)
app.use('/api/payments', paymentRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/category', categoryRoutes);
app.use('/api/city', cityRoutes);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
