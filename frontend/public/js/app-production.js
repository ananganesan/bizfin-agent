// API Configuration
const API_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:3001/api' 
  : '/api'; // Use relative path in production
let authToken = localStorage.getItem('authToken');
let currentUser = null;
let uploadedData = null;

// Check authentication on load
window.addEventListener('load', async () => {
    if (!authToken) {
        window.location.href = '/login.html';
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/auth/me`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (!response.ok) {
            throw new Error('Authentication failed');
        }
        
        const data = await response.json();
        currentUser = data.user;
        
        // Hide loading screen and show app
        document.getElementById('authLoading').style.display = 'none';
        document.getElementById('appContainer').style.display = 'block';
        
        updateUI();
        loadCapabilities();
    } catch (error) {
        console.error('Auth check failed:', error);
        localStorage.removeItem('authToken');
        window.location.href = '/login.html';
    }
});

// Update UI with user info
function updateUI() {
    document.getElementById('username').textContent = currentUser.username;
    document.getElementById('userRole').textContent = currentUser.role;
    updateToolsList();
}

// Load role capabilities
async function loadCapabilities() {
    try {
        const response = await fetch(`${API_URL}/analysis/capabilities/${currentUser.role}`);
        const capabilities = await response.json();
        
        const capabilitiesDiv = document.getElementById('capabilities');
        capabilitiesDiv.innerHTML = `
            <div class="capability-level">Level: ${capabilities.level}</div>
            <div class="features">
                <strong>Features:</strong>
                <ul>${capabilities.features.map(f => `<li>${f}</li>`).join('')}</ul>
            </div>
            ${capabilities.restrictions.length > 0 ? `
                <div class="restrictions">
                    <strong>Restrictions:</strong>
                    <ul>${capabilities.restrictions.map(r => `<li>${r}</li>`).join('')}</ul>
                </div>
            ` : ''}
        `;
    } catch (error) {
        console.error('Failed to load capabilities:', error);
    }
}

// Update tools list based on role
function updateToolsList() {
    const tools = {
        'Junior Staff': ['Basic Calculator', 'Ratio Explainer'],
        'Intermediate Staff': ['Cash Flow Simulator', 'Ratio Analysis', 'Benchmarking Tool', 'Scenario Planner'],
        'Departmental Head': ['Multi-Agent Orchestration', 'Predictive Analytics', 'Autonomous Planning', 'Strategic Optimizer']
    };
    
    const toolsList = document.getElementById('toolsList');
    const userTools = tools[currentUser.role] || [];
    
    toolsList.innerHTML = userTools.map(tool => 
        `<div class="tool-chip">${tool}</div>`
    ).join('');
}

// File upload handling
document.getElementById('uploadBtn').addEventListener('click', async () => {
    const fileInput = document.getElementById('fileInput');
    const file = fileInput.files[0];
    
    if (!file) {
        alert('Please select a file to upload');
        return;
    }
    
    const formData = new FormData();
    formData.append('file', file);
    
    const uploadStatus = document.getElementById('uploadStatus');
    uploadStatus.textContent = 'Uploading...';
    uploadStatus.style.color = '#667eea';
    
    try {
        const response = await fetch(`${API_URL}/upload/financial-data`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`
            },
            body: formData
        });
        
        if (!response.ok) {
            throw new Error('Upload failed');
        }
        
        const result = await response.json();
        uploadedData = result.data.financialData;
        
        uploadStatus.textContent = 'File uploaded successfully!';
        uploadStatus.style.color = '#48bb78';
        
        // Add system message
        addMessage('system', `Financial data from "${file.name}" has been loaded. You can now ask questions about the data.`);
        
        // Auto-generate initial analysis
        setTimeout(() => {
            sendQuery('Please provide an initial overview of the financial data.');
        }, 1000);
        
    } catch (error) {
        console.error('Upload error:', error);
        uploadStatus.textContent = 'Upload failed. Please try again.';
        uploadStatus.style.color = '#e53e3e';
    }
});

// Chat functionality
document.getElementById('sendBtn').addEventListener('click', () => {
    const input = document.getElementById('chatInput');
    const query = input.value.trim();
    
    if (query) {
        sendQuery(query);
        input.value = '';
    }
});

document.getElementById('chatInput').addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        document.getElementById('sendBtn').click();
    }
});

async function sendQuery(query) {
    if (!uploadedData) {
        addMessage('system', 'Please upload financial data first.');
        return;
    }
    
    // Add user message
    addMessage('user', query);
    
    try {
        const response = await fetch(`${API_URL}/analysis/query`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({
                query,
                financialData: uploadedData,
                userRole: currentUser.role
            })
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Analysis failed');
        }
        
        const result = await response.json();
        
        // Add AI response
        addMessage('ai', result.data.content, result.data.insights);
        
    } catch (error) {
        console.error('Query error:', error);
        addMessage('system', error.message || 'Failed to analyze query. Please try again.');
    }
}

function addMessage(type, content, insights = []) {
    const messagesDiv = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}`;
    
    let roleLabel = '';
    if (type === 'user') {
        roleLabel = `<div class="message-role">${currentUser.role}</div>`;
    } else if (type === 'ai') {
        roleLabel = '<div class="message-role">AI Assistant</div>';
    }
    
    messageDiv.innerHTML = `
        <div class="message-content">
            ${roleLabel}
            ${content}
            ${insights.length > 0 ? `
                <div class="insights-list">
                    <h4>Key Insights:</h4>
                    <ul>${insights.map(i => `<li>${i}</li>`).join('')}</ul>
                </div>
            ` : ''}
        </div>
    `;
    
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

// Generate report
document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.key === 'r') {
        e.preventDefault();
        generateReport();
    }
});

async function generateReport() {
    if (!uploadedData) {
        alert('Please upload financial data first.');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/analysis/report`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({
                financialData: uploadedData,
                userRole: currentUser.role
            })
        });
        
        if (!response.ok) {
            throw new Error('Report generation failed');
        }
        
        const result = await response.json();
        showReportModal(result.data.report);
        
    } catch (error) {
        console.error('Report generation error:', error);
        alert('Failed to generate report. Please try again.');
    }
}

function showReportModal(reportContent) {
    const modal = document.getElementById('reportModal');
    const reportDiv = document.getElementById('reportContent');
    
    reportDiv.textContent = reportContent;
    modal.style.display = 'block';
}

// Modal controls
document.querySelector('.close').addEventListener('click', () => {
    document.getElementById('reportModal').style.display = 'none';
});

window.addEventListener('click', (e) => {
    const modal = document.getElementById('reportModal');
    if (e.target === modal) {
        modal.style.display = 'none';
    }
});

document.getElementById('downloadReport').addEventListener('click', () => {
    const reportContent = document.getElementById('reportContent').textContent;
    const blob = new Blob([reportContent], { type: 'text/plain' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `financial-report-${new Date().toISOString().split('T')[0]}.txt`;
    a.click();
    window.URL.revokeObjectURL(url);
});

// Logout
document.getElementById('logoutBtn').addEventListener('click', () => {
    localStorage.removeItem('authToken');
    window.location.href = '/login.html';
});