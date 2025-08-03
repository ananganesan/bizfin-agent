// Developer Console JavaScript
const API_URL = window.location.protocol + '//' + window.location.hostname + '/api';
let eventSource = null;
let logs = [];

// Get auth token
function getAuthToken() {
    return localStorage.getItem('authToken');
}

// Check authentication
async function checkAuth() {
    const token = getAuthToken();
    if (!token) {
        window.location.href = '/login.html';
        return false;
    }

    try {
        const response = await fetch(`${API_URL}/auth/me`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            window.location.href = '/login.html';
            return false;
        }

        const data = await response.json();
        // Check if user has developer access (Departmental Head)
        if (data.role !== 'Departmental Head') {
            alert('Developer access required');
            window.location.href = '/';
            return false;
        }

        return true;
    } catch (error) {
        console.error('Auth check failed:', error);
        window.location.href = '/login.html';
        return false;
    }
}

// Format timestamp
function formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleTimeString() + '.' + date.getMilliseconds();
}

// Render log entry
function renderLog(log) {
    return `
        <div class="log-entry">
            <div class="log-header">
                <div>
                    <span class="log-type ${log.type}">${log.type.toUpperCase()}</span>
                    <span class="log-timestamp">${formatTimestamp(log.timestamp)}</span>
                </div>
            </div>
            <div class="log-category">${log.category}</div>
            <div class="log-data">${JSON.stringify(log.data, null, 2)}</div>
        </div>
    `;
}

// Update logs display
function updateLogsDisplay(logsToShow) {
    const container = document.getElementById('logsContainer');
    
    if (logsToShow.length === 0) {
        container.innerHTML = '<div class="empty-state">No logs match the current filters.</div>';
        return;
    }

    container.innerHTML = logsToShow.map(log => renderLog(log)).join('');
}

// Apply filters
function applyFilters() {
    const typeFilter = document.getElementById('typeFilter').value;
    const categoryFilter = document.getElementById('categoryFilter').value;

    let filteredLogs = logs;
    
    if (typeFilter) {
        filteredLogs = filteredLogs.filter(log => log.type === typeFilter);
    }
    
    if (categoryFilter) {
        filteredLogs = filteredLogs.filter(log => log.category === categoryFilter);
    }

    updateLogsDisplay(filteredLogs);
}

// Load initial logs
async function loadLogs() {
    try {
        const response = await fetch(`${API_URL}/dev-console/logs?limit=100`, {
            headers: {
                'Authorization': `Bearer ${getAuthToken()}`
            }
        });

        if (!response.ok) throw new Error('Failed to load logs');

        const data = await response.json();
        logs = data.data;
        updateLogsDisplay(logs);
        updateStats();
    } catch (error) {
        console.error('Failed to load logs:', error);
    }
}

// Update statistics
async function updateStats() {
    try {
        const response = await fetch(`${API_URL}/dev-console/stats`, {
            headers: {
                'Authorization': `Bearer ${getAuthToken()}`
            }
        });

        if (!response.ok) throw new Error('Failed to load stats');

        const data = await response.json();
        const stats = data.data;

        document.getElementById('totalLogs').textContent = stats.total;
        document.getElementById('openaiCalls').textContent = stats.openaiCalls;
        document.getElementById('vectorOps').textContent = stats.vectorOperations;
        document.getElementById('errorCount').textContent = stats.errors;
    } catch (error) {
        console.error('Failed to load stats:', error);
    }
}

// Clear logs
async function clearLogs() {
    if (!confirm('Are you sure you want to clear all logs?')) return;

    try {
        const response = await fetch(`${API_URL}/dev-console/logs`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${getAuthToken()}`
            }
        });

        if (!response.ok) throw new Error('Failed to clear logs');

        logs = [];
        updateLogsDisplay(logs);
        updateStats();
    } catch (error) {
        console.error('Failed to clear logs:', error);
    }
}

// Export logs
function exportLogs() {
    const dataStr = JSON.stringify(logs, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = `bizfin-logs-${new Date().toISOString()}.json`;
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
}

// Connect to real-time stream
function connectStream() {
    const token = getAuthToken();
    if (!token) return;

    eventSource = new EventSource(`${API_URL}/dev-console/stream?token=${encodeURIComponent(token)}`);
    
    eventSource.onopen = () => {
        document.getElementById('statusText').textContent = 'Connected';
        document.querySelector('.status-indicator').classList.remove('disconnected');
        document.querySelector('.status-indicator').classList.add('connected');
    };

    eventSource.onmessage = (event) => {
        try {
            const log = JSON.parse(event.data);
            
            if (log.type === 'connected') {
                console.log('Stream connected');
                return;
            }

            // Add new log to the beginning
            logs.unshift(log);
            if (logs.length > 1000) {
                logs = logs.slice(0, 1000);
            }

            // Apply filters and update display
            applyFilters();
            updateStats();
        } catch (error) {
            console.error('Failed to parse log:', error);
        }
    };

    eventSource.onerror = () => {
        document.getElementById('statusText').textContent = 'Disconnected';
        document.querySelector('.status-indicator').classList.remove('connected');
        document.querySelector('.status-indicator').classList.add('disconnected');
        
        // Reconnect after 5 seconds
        setTimeout(connectStream, 5000);
    };
}

// Initialize
async function init() {
    const isAuthenticated = await checkAuth();
    if (!isAuthenticated) return;

    // Load initial data
    await loadLogs();

    // Set up event listeners
    document.getElementById('typeFilter').addEventListener('change', applyFilters);
    document.getElementById('categoryFilter').addEventListener('change', applyFilters);
    document.getElementById('clearLogs').addEventListener('click', clearLogs);
    document.getElementById('exportLogs').addEventListener('click', exportLogs);

    // Connect to real-time stream
    connectStream();

    // Refresh stats every 5 seconds
    setInterval(updateStats, 5000);
}

// Start the app
init();