
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const app = express();
app.use(cors());
app.use(express.json());

// Fake data
const users = [
  {
    id: "1",
    name: "John Doe",
    email: "john@example.com",
    password: "password123",
    phone: "+1234567890",
    role: "provider",
    avatar: "default-user.jpg",
    rating: 4.5,
    location: "New York"
  },
  {
    id: "2",
    name: "Jane Smith",
    email: "jane@example.com",
    password: "password123",
    phone: "+1987654321",
    role: "customer",
    avatar: "default-user.jpg",
    rating: 4.8,
    location: "Los Angeles"
  }
];

const services = [
  {
    id: "1",
    title: "Professional House Cleaning",
    description: "Complete house cleaning service with professional equipment",
    price: 80,
    category_id: "1",
    provider_id: "1",
    rating: 4.7,
    images: ["cleaning1.jpg", "cleaning2.jpg"],
    location: "New York"
  },
  {
    id: "2",
    title: "Emergency Plumbing Service",
    description: "24/7 emergency plumbing repairs and maintenance",
    price: 120,
    category_id: "2",
    provider_id: "1",
    rating: 4.5,
    images: ["plumbing1.jpg"],
    location: "New York"
  }
];

const categories = [
  { id: "1", name: "Cleaning", icon: "cleaning.svg" },
  { id: "2", name: "Plumbing", icon: "plumbing.svg" },
  { id: "3", name: "Electrical", icon: "electrical.svg" },
  { id: "4", name: "Gardening", icon: "gardening.svg" },
  { id: "5", name: "Carpentry", icon: "carpentry.svg" }
];

const orders = [
  {
    id: "1",
    service_id: "1",
    customer_id: "2",
    provider_id: "1",
    status: "completed",
    price: 80,
    date: "2024-01-20",
    payment_method: "cod",
    location: "123 Main St, New York"
  }
];

const reviews = [
  {
    id: "1",
    order_id: "1",
    service_id: "1",
    customer_id: "2",
    provider_id: "1",
    rating: 5,
    comment: "Excellent service, very professional!",
    date: "2024-01-21"
  }
];

const conversations = [
  {
    id: "1",
    customer_id: "2",
    provider_id: "1",
    service_id: "1",
    last_message: "What time can you arrive?",
    updated_at: "2024-01-19T10:00:00Z"
  }
];

const messages = [
  {
    id: "1",
    conversation_id: "1",
    sender_id: "2",
    content: "What time can you arrive?",
    created_at: "2024-01-19T10:00:00Z"
  },
  {
    id: "2",
    conversation_id: "1",
    sender_id: "1",
    content: "I can be there at 2 PM",
    created_at: "2024-01-19T10:05:00Z"
  }
];

// Auth routes
app.post('/api/auth/register', (req, res) => {
  const user = { id: Date.now().toString(), ...req.body };
  users.push(user);
  res.json({ success: true, data: user });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (user) {
    res.json({
      success: true,
      data: {
        user,
        tokens: {
          access_token: 'fake_access_token',
          refresh_token: 'fake_refresh_token'
        }
      }
    });
  } else {
    res.status(401).json({ success: false, message: 'Invalid credentials' });
  }
});

// User routes
app.get('/api/user/profile', (req, res) => {
  const userId = req.headers['user-id'];
  const user = users.find(u => u.id === userId);
  res.json({ success: true, data: user });
});

app.put('/api/user/profile', (req, res) => {
  const userId = req.headers['user-id'];
  const userIndex = users.findIndex(u => u.id === userId);
  if (userIndex !== -1) {
    users[userIndex] = { ...users[userIndex], ...req.body };
    res.json({ success: true, data: users[userIndex] });
  } else {
    res.status(404).json({ success: false, message: 'User not found' });
  }
});

// Category routes
app.get('/api/category', (req, res) => {
  res.json({ success: true, data: categories });
});

// Service routes
app.get('/api/service', (req, res) => {
  const { category_id, search } = req.query;
  let filteredServices = services;
  
  if (category_id) {
    filteredServices = filteredServices.filter(s => s.category_id === category_id);
  }
  
  if (search) {
    filteredServices = filteredServices.filter(s => 
      s.title.toLowerCase().includes(search.toLowerCase()) ||
      s.description.toLowerCase().includes(search.toLowerCase())
    );
  }
  
  res.json({ success: true, data: filteredServices });
});

app.get('/api/service/:id', (req, res) => {
  const service = services.find(s => s.id === req.params.id);
  if (service) {
    res.json({ success: true, data: service });
  } else {
    res.status(404).json({ success: false, message: 'Service not found' });
  }
});

app.post('/api/service', (req, res) => {
  const service = { id: Date.now().toString(), ...req.body };
  services.push(service);
  res.json({ success: true, data: service });
});

// Order routes
app.post('/api/order', (req, res) => {
  const order = { id: Date.now().toString(), ...req.body, status: 'pending' };
  orders.push(order);
  res.json({ success: true, data: order });
});

app.get('/api/order', (req, res) => {
  const userId = req.headers['user-id'];
  const userOrders = orders.filter(o => 
    o.customer_id === userId || o.provider_id === userId
  );
  res.json({ success: true, data: userOrders });
});

app.put('/api/order/:id/status', (req, res) => {
  const orderIndex = orders.findIndex(o => o.id === req.params.id);
  if (orderIndex !== -1) {
    orders[orderIndex] = { ...orders[orderIndex], status: req.body.status };
    res.json({ success: true, data: orders[orderIndex] });
  } else {
    res.status(404).json({ success: false, message: 'Order not found' });
  }
});

// Review routes
app.post('/api/review', (req, res) => {
  const review = { id: Date.now().toString(), ...req.body, date: new Date().toISOString() };
  reviews.push(review);
  res.json({ success: true, data: review });
});

app.get('/api/review/service/:serviceId', (req, res) => {
  const serviceReviews = reviews.filter(r => r.service_id === req.params.serviceId);
  res.json({ success: true, data: serviceReviews });
});

// Chat routes
app.post('/api/conversation', (req, res) => {
  const conversation = { 
    id: Date.now().toString(), 
    ...req.body,
    last_message: "",
    updated_at: new Date().toISOString()
  };
  conversations.push(conversation);
  res.json({ success: true, data: conversation });
});

app.get('/api/conversation', (req, res) => {
  const userId = req.headers['user-id'];
  const userConversations = conversations.filter(c => 
    c.customer_id === userId || c.provider_id === userId
  );
  res.json({ success: true, data: userConversations });
});

app.get('/api/message/:conversationId', (req, res) => {
  const conversationMessages = messages.filter(
    m => m.conversation_id === req.params.conversationId
  );
  res.json({ success: true, data: conversationMessages });
});

app.post('/api/message', (req, res) => {
  const message = {
    id: Date.now().toString(),
    ...req.body,
    created_at: new Date().toISOString()
  };
  messages.push(message);
  
  // Update conversation's last message
  const conversationIndex = conversations.findIndex(c => c.id === req.body.conversation_id);
  if (conversationIndex !== -1) {
    conversations[conversationIndex] = {
      ...conversations[conversationIndex],
      last_message: req.body.content,
      updated_at: new Date().toISOString()
    };
  }
  
  res.json({ success: true, data: message });
});

const PORT = 4000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
