#!/bin/bash

# Create alternative access methods for the Finance Advisory Agent
echo "🔧 Setting up alternative access methods..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME="bizfin-agent"
PORT="3005"

# Method 1: Path-based routing on main domain
echo -e "${YELLOW}📍 Method 1: Setting up path-based routing${NC}"
echo "Creating nginx config for texra.in/bizfin-agent..."

# Create path-based config
cat > /tmp/bizfin-path.conf << 'EOF'
# Add this location block to your main texra.in nginx config
location /bizfin-agent {
    alias /var/www/bizfin-agent/frontend/public;
    index index.html;
    try_files $uri $uri/ /bizfin-agent/index.html;
    
    # Handle API requests
    location /bizfin-agent/api {
        rewrite ^/bizfin-agent/api(.*)$ /api$1 break;
        proxy_pass http://localhost:3005;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

echo "Path-based config created at: /tmp/bizfin-path.conf"
echo "Add this to your main texra.in nginx config"
echo ""

# Method 2: Port-based access
echo -e "${YELLOW}🔌 Method 2: Setting up port-based access${NC}"
echo "Creating nginx config for direct port access..."

cat > /tmp/bizfin-port.conf << EOF
# Port-based access configuration
server {
    listen 8080;
    server_name texra.in *.texra.in;
    
    location / {
        root /var/www/bizfin-agent/frontend/public;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:3005;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    client_max_body_size 10M;
}
EOF

echo "Port-based config created at: /tmp/bizfin-port.conf"
echo ""

# Method 3: Update frontend for path-based routing
echo -e "${YELLOW}🌐 Method 3: Creating path-aware frontend${NC}"

# Update the API URL in the frontend for path-based access
if [ -f "/var/www/$APP_NAME/frontend/public/js/app.js" ]; then
    cp /var/www/$APP_NAME/frontend/public/js/app.js /var/www/$APP_NAME/frontend/public/js/app.js.bak
    
    # Create path-aware version
    sed 's|const API_URL = .*|const API_URL = window.location.pathname.includes("/bizfin-agent") ? "/bizfin-agent/api" : "http://localhost:3001/api";|g' \
        /var/www/$APP_NAME/frontend/public/js/app.js.bak > /tmp/app-path-aware.js
    
    echo "Path-aware app.js created at: /tmp/app-path-aware.js"
fi

echo ""
echo -e "${GREEN}🚀 Alternative Access Methods Setup Complete!${NC}"
echo ""
echo -e "${BLUE}Choose one of these access methods:${NC}"
echo ""
echo -e "${GREEN}Option A: Path-based (Recommended)${NC}"
echo "1. Add the content of /tmp/bizfin-path.conf to your main texra.in nginx config"
echo "2. Reload nginx: sudo systemctl reload nginx"
echo "3. Access: https://texra.in/bizfin-agent"
echo ""
echo -e "${GREEN}Option B: Port-based${NC}"
echo "1. sudo cp /tmp/bizfin-port.conf /etc/nginx/sites-available/bizfin-port"
echo "2. sudo ln -s /etc/nginx/sites-available/bizfin-port /etc/nginx/sites-enabled/"
echo "3. sudo systemctl reload nginx"
echo "4. Access: https://texra.in:8080"
echo ""
echo -e "${GREEN}Option C: Direct port access${NC}"
echo "Access directly: http://$(curl -s ifconfig.me):3005"
echo "(May need to open port 3005 in firewall)"
echo ""
echo -e "${YELLOW}💡 To implement path-based routing:${NC}"
echo "cat /tmp/bizfin-path.conf"
echo ""

# Show the current server IP
echo -e "${BLUE}Current server IP: $(curl -s ifconfig.me)${NC}"
echo -e "${BLUE}App should be running on: $(curl -s ifconfig.me):3005${NC}"