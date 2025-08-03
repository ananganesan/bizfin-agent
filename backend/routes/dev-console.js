const express = require('express');
const router = express.Router();
const loggingService = require('../services/logging-service');
const { authenticateToken } = require('../middleware/auth');

// Middleware to check if user is admin/developer
const requireDeveloper = (req, res, next) => {
  // For now, allow departmental heads to access dev console
  // In production, you might want a separate developer role
  if (req.user && req.user.role === 'Departmental Head') {
    next();
  } else {
    res.status(403).json({ error: 'Developer access required' });
  }
};

// Get logs with filtering
router.get('/logs', authenticateToken, requireDeveloper, (req, res) => {
  const filters = {
    type: req.query.type,
    category: req.query.category,
    startTime: req.query.startTime,
    endTime: req.query.endTime,
    limit: parseInt(req.query.limit) || 100
  };

  const logs = loggingService.getLogs(filters);
  res.json({
    success: true,
    data: logs,
    count: logs.length,
    total: loggingService.logs.length
  });
});

// Get statistics
router.get('/stats', authenticateToken, requireDeveloper, (req, res) => {
  const stats = loggingService.getStats();
  res.json({
    success: true,
    data: stats
  });
});

// Clear logs
router.delete('/logs', authenticateToken, requireDeveloper, (req, res) => {
  loggingService.clearLogs();
  res.json({
    success: true,
    message: 'Logs cleared'
  });
});

// Server-Sent Events for real-time logs
router.get('/stream', (req, res) => {
  // Manual token verification for SSE
  const token = req.query.token || req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret');
    
    // Check if user is developer
    if (decoded.role !== 'Departmental Head') {
      return res.status(403).json({ error: 'Developer access required' });
    }
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  });

  // Send initial connection message
  res.write(`data: ${JSON.stringify({ type: 'connected', timestamp: new Date().toISOString() })}\n\n`);

  // Function to send logs
  const sendLog = (log) => {
    res.write(`data: ${JSON.stringify(log)}\n\n`);
  };

  // Listen for new logs
  loggingService.on('log', sendLog);

  // Clean up on client disconnect
  req.on('close', () => {
    loggingService.removeListener('log', sendLog);
  });
});

module.exports = router;