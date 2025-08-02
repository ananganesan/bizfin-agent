const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Mock user database (replace with real database in production)
const users = [
  {
    id: 1,
    username: 'junior_user',
    password: '$2a$10$XQqKV8.YKpFGHZlVeiPAOu7Jf8QLwzF8cKZU8XrtOOJ5xZ0n0W/8W', // password: junior123
    role: 'Junior Staff',
    department: 'Finance'
  },
  {
    id: 2,
    username: 'intermediate_user',
    password: '$2a$10$XQqKV8.YKpFGHZlVeiPAOu7Jf8QLwzF8cKZU8XrtOOJ5xZ0n0W/8W', // password: junior123
    role: 'Intermediate Staff',
    department: 'Sales'
  },
  {
    id: 3,
    username: 'department_head',
    password: '$2a$10$XQqKV8.YKpFGHZlVeiPAOu7Jf8QLwzF8cKZU8XrtOOJ5xZ0n0W/8W', // password: junior123
    role: 'Departmental Head',
    department: 'Management'
  }
];

// Login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    const user = users.find(u => u.username === username);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username, 
        role: user.role,
        department: user.department 
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        department: user.department
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Get current user
router.get('/me', (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    res.json({ user });
  });
});

module.exports = router;