
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const app = express();
app.use(cors());
app.use(express.json());

// Fake data
const users = [];
const services = [];
const categories = [
  { id: "1", name: "Cleaning" },
  { id: "2", name: "Plumbing" },
  { id: "3", name: "Electrical" }
];
const orders = [];
const reviews = [];
const conversations = [];
const messages = [];

// Auth routes
app.post('/api/auth/register', (req, res) => {
  const user = { id: Date.now().toString(), ...req.body };
  users.push(user);
  res.json({ success: true, data: user });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email);
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

// Category routes
app.get('/api/category', (req, res) => {
  res.json({ success: true, data: categories });
});

// Service routes
app.get('/api/service', (req, res) => {
  res.json({ success: true, data: services });
});

app.post('/api/service', (req, res) => {
  const service = { id: Date.now().toString(), ...req.body };
  services.push(service);
  res.json({ success: true, data: service });
});

// Order routes
app.post('/api/order', (req, res) => {
  const order = { id: Date.now().toString(), ...req.body };
  orders.push(order);
  res.json({ success: true, data: order });
});

app.get('/api/order', (req, res) => {
  res.json({ success: true, data: orders });
});

// Review routes
app.post('/api/review', (req, res) => {
  const review = { id: Date.now().toString(), ...req.body };
  reviews.push(review);
  res.json({ success: true, data: review });
});

// Chat routes
app.post('/api/conversation', (req, res) => {
  const conversation = { id: Date.now().toString(), ...req.body };
  conversations.push(conversation);
  res.json({ success: true, data: conversation });
});

app.get('/api/message/:conversationId', (req, res) => {
  const conversationMessages = messages.filter(
    m => m.conversation_id === req.params.conversationId
  );
  res.json({ success: true, data: conversationMessages });
});

const PORT = 4000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
