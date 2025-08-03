const EventEmitter = require('events');

class LoggingService extends EventEmitter {
  constructor() {
    super();
    this.logs = [];
    this.maxLogs = 1000; // Keep last 1000 logs in memory
  }

  log(type, category, data) {
    const logEntry = {
      id: Date.now() + '_' + Math.random().toString(36).substr(2, 9),
      timestamp: new Date().toISOString(),
      type, // 'info', 'error', 'debug', 'openai', 'vector', 'system'
      category, // 'request', 'response', 'embedding', 'search', etc.
      data,
      // Add request context if available
      userId: data.userId || null,
      sessionId: data.sessionId || null
    };

    // Add to in-memory store
    this.logs.unshift(logEntry);
    if (this.logs.length > this.maxLogs) {
      this.logs = this.logs.slice(0, this.maxLogs);
    }

    // Emit event for real-time streaming
    this.emit('log', logEntry);

    // Also log to console in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`[${type.toUpperCase()}] ${category}:`, data);
    }

    return logEntry;
  }

  // Log OpenAI interactions
  logOpenAI(action, details) {
    return this.log('openai', action, {
      ...details,
      timestamp: new Date().toISOString()
    });
  }

  // Log Vector DB operations
  logVector(action, details) {
    return this.log('vector', action, {
      ...details,
      timestamp: new Date().toISOString()
    });
  }

  // Log system events
  logSystem(action, details) {
    return this.log('system', action, {
      ...details,
      timestamp: new Date().toISOString()
    });
  }

  // Get logs with filtering
  getLogs(filters = {}) {
    let filteredLogs = [...this.logs];

    if (filters.type) {
      filteredLogs = filteredLogs.filter(log => log.type === filters.type);
    }

    if (filters.category) {
      filteredLogs = filteredLogs.filter(log => log.category === filters.category);
    }

    if (filters.startTime) {
      filteredLogs = filteredLogs.filter(log => 
        new Date(log.timestamp) >= new Date(filters.startTime)
      );
    }

    if (filters.endTime) {
      filteredLogs = filteredLogs.filter(log => 
        new Date(log.timestamp) <= new Date(filters.endTime)
      );
    }

    if (filters.limit) {
      filteredLogs = filteredLogs.slice(0, filters.limit);
    }

    return filteredLogs;
  }

  // Clear logs
  clearLogs() {
    this.logs = [];
    this.emit('cleared');
  }

  // Get statistics
  getStats() {
    const stats = {
      total: this.logs.length,
      byType: {},
      byCategory: {},
      errors: 0,
      openaiCalls: 0,
      vectorOperations: 0
    };

    this.logs.forEach(log => {
      // Count by type
      stats.byType[log.type] = (stats.byType[log.type] || 0) + 1;
      
      // Count by category
      stats.byCategory[log.category] = (stats.byCategory[log.category] || 0) + 1;
      
      // Count specific types
      if (log.type === 'error') stats.errors++;
      if (log.type === 'openai') stats.openaiCalls++;
      if (log.type === 'vector') stats.vectorOperations++;
    });

    return stats;
  }
}

module.exports = new LoggingService();