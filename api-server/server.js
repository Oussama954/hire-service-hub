const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const bodyParser = require('body-parser');
const http = require('http');
const socketIo = require('socket.io');

// Import cron job for order status updates
const { scheduleOrderStatusUpdates } = require('./src/cron/orderStatusUpdater');

require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*', // Allow all origins for development
    methods: ['GET', 'POST'],
    credentials: true
  }
});
const upload = multer({ dest: 'uploads/' });

// Import routes
const authRoutes = require('./src/routes/auth.routes');
const serviceRoutes = require('./src/routes/service.routes');
const bookingRoutes = require('./src/routes/booking.routes');
const paymentRoutes = require('./src/routes/payment.routes');
const reviewRoutes = require('./src/routes/review.routes');
const categoryRoutes = require('./src/routes/category.routes');
const cityRoutes = require('./src/routes/city.routes');
const conversationRoutes = require('./src/routes/conversation.routes');
const messageRoutes = require('./src/routes/message.routes');
const fcmRoutes = require('./src/routes/fcm.routes');

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
app.use('/api/conversation', conversationRoutes);
app.use('/api/message', messageRoutes);
app.use('/api/fcm', fcmRoutes);

// Import all controllers with socket integration
const { setSocketReferences: setMessageSocketRefs } = require('./src/controllers/message.controller');
const { setSocketReferences: setBookingSocketRefs } = require('./src/controllers/booking.controller');
const { setSocketReferences: setServiceSocketRefs } = require('./src/controllers/service.controller');

// Socket.io connection handling
let users = [];

const addUser = (userId, socketId) => {
  // If user already exists, update their socketId
  const existingUserIndex = users.findIndex((user) => user.userId === userId);
  if (existingUserIndex !== -1) {
    users[existingUserIndex].socketId = socketId;
    console.log(`Updated socket ID for user ${userId}: ${socketId}`);
  } else {
    users.push({ userId, socketId });
    console.log(`Added new user ${userId} with socket ID: ${socketId}`);
  }
  console.log('Current users:', JSON.stringify(users));
};

const removeUser = (socketId) => {
  const userToRemove = users.find(user => user.socketId === socketId);
  if (userToRemove) {
    console.log(`Removing user ${userToRemove.userId} with socket ID: ${socketId}`);
  }
  users = users.filter((user) => user.socketId !== socketId);
  console.log('Remaining users:', JSON.stringify(users));
};

const getUser = (userId) => {
  const user = users.find((user) => user.userId === userId);
  console.log(`Searching for user ${userId}:`, user ? 'Found' : 'Not found');
  return user;
};

io.on('connection', (socket) => {
  console.log('A user connected: ' + socket.id);
  
  // Get user ID from headers if available
  const userId = socket.handshake.headers.userid;
  if (userId) {
    console.log(`User ${userId} connected with socket ID: ${socket.id}`);
    // Auto-register user from headers
    addUser(userId, socket.id);
    io.emit('getUsers', users);
  }
  
  // Add user when they explicitly connect
  socket.on('addUser', (userId) => {
    if (!userId) {
      console.log('Warning: Received addUser event without userId');
      return;
    }
    console.log(`User ${userId} registered via addUser event`);
    addUser(userId, socket.id);
    io.emit('getUsers', users);
  });
  
  // Send and receive messages
  socket.on('sendMessage', ({ senderId, receiverId, text }) => {
    console.log(`Message from ${senderId} to ${receiverId}: ${text}`);
    
    // Check if both sender and receiver IDs are provided
    if (!senderId || !receiverId) {
      console.log('Missing sender or receiver ID in message');
      return;
    }
    
    // Find the receiver's socket
    const user = getUser(receiverId);
    if (user) {
      console.log(`Sending message to socket ${user.socketId}`);
      // Send to specific user
      io.to(user.socketId).emit('getMessage', {
        senderId,
        text,
      });
    } else {
      console.log(`Receiver ${receiverId} not found or not connected`);
      // Store message for offline delivery or notify sender
    }
  });
  
  // Handle disconnections
  socket.on('disconnect', () => {
    console.log('A user disconnected: ' + socket.id);
    removeUser(socket.id);
    io.emit('getUsers', users);
  });
});

const PORT = process.env.PORT || 4000;

// Initialize socket references in all controllers that need them
setMessageSocketRefs(io, users);
setBookingSocketRefs(io, users);
setServiceSocketRefs(io, users);
console.log('Socket references set in all controllers');

// Start the server
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  
  // Initialize the order status updater cron job
  scheduleOrderStatusUpdates();
  console.log('🔄 Automatic order status updater initialized');
  console.log('🔄 Socket.io server initialized for real-time messaging');
});
