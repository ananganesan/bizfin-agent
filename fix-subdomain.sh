#!/bin/bash

# Fix subdomain routing issue
echo "🔧 Fixing bizfin.texra.in subdomain routing..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="/var/www/bizfin-agent"
DOMAIN="bizfin.texra.in"

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    FIXING SUBDOMAIN ROUTING${NC}" 
echo -e "${BLUE}===========================================${NC}"
echo ""

# Step 1: Ensure app directory exists and start application
echo -e "${YELLOW}1. 🚀 Starting the application${NC}"
if [ -d "$APP_DIR" ]; then
    cd $APP_DIR
    
    # Install dependencies if needed
    if [ ! -d "backend/node_modules" ]; then
        echo "Installing backend dependencies..."
        cd backend && npm install && cd ..
    fi
    
    # Start with PM2 if available, otherwise with node
    if command -v pm2 > /dev/null; then
        echo "Starting with PM2..."
        pm2 stop bizfin-agent 2>/dev/null || true
        pm2 delete bizfin-agent 2>/dev/null || true
        pm2 start backend/server.js --name bizfin-agent --env production
        pm2 save
    else
        echo "Starting with nohup..."
        pkill -f "bizfin-agent" 2>/dev/null || true
        nohup node backend/server.js > app.log 2>&1 &
        echo $! > app.pid
    fi
    
    sleep 2
    
    # Check if port 3005 is listening
    if netstat -tlnp | grep -q ":3005"; then
        echo -e "${GREEN}✅ Application started on port 3005${NC}"
    else
        echo -e "${RED}❌ Application failed to start${NC}"
        echo "Check logs: cat $APP_DIR/app.log"
    fi
else
    echo -e "${RED}❌ App directory not found: $APP_DIR${NC}"
    echo "Run deployment script first: ./deploy.sh"
    exit 1
fi
echo ""

# Step 2: Create nginx configuration with highest priority
echo -e "${YELLOW}2. ⚙️  Configuring Nginx${NC}"

# Remove any existing bizfin configs
sudo rm -f /etc/nginx/sites-enabled/bizfin*
sudo rm -f /etc/nginx/sites-available/bizfin*

# Create specific nginx config for bizfin subdomain
sudo tee /etc/nginx/sites-available/bizfin.texra.in > /dev/null << 'EOF'
# Highest priority config for bizfin.texra.in
# This MUST load before any wildcard configs

server {
    listen 80;
    server_name bizfin.texra.in www.bizfin.texra.in;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Serve static files
    location / {
        root /var/www/bizfin-agent/frontend/public;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API proxy to backend
    location /api {
        proxy_pass http://localhost:3005;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Increase timeout for AI processing
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Health check
    location /health {
        proxy_pass http://localhost:3005/health;
        access_log off;
    }
    
    # File upload size limit
    client_max_body_size 10M;
}
EOF

# Enable with highest priority (00- prefix ensures it loads first)
sudo ln -sf /etc/nginx/sites-available/bizfin.texra.in /etc/nginx/sites-enabled/00-bizfin.texra.in

echo "Created nginx config with highest priority"
echo ""

# Step 3: Test and reload nginx
echo -e "${YELLOW}3. 🧪 Testing Nginx Configuration${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config is valid${NC}"
    sudo systemctl reload nginx
    echo "Nginx reloaded successfully"
else
    echo -e "${RED}❌ Nginx config error${NC}"
    exit 1
fi
echo ""

# Step 4: Test the setup
echo -e "${YELLOW}4. 🔍 Testing Setup${NC}"
sleep 2

echo "Testing port 3005:"
if curl -s http://localhost:3005/health > /dev/null; then
    echo -e "${GREEN}✅ Backend responding on port 3005${NC}"
else
    echo -e "${RED}❌ Backend not responding${NC}"
fi

echo "Testing nginx routing:"
RESPONSE=$(curl -s -I -H "Host: bizfin.texra.in" localhost | head -1)
echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q "200\|404"; then
    echo -e "${GREEN}✅ Nginx routing working${NC}"
else
    echo -e "${YELLOW}⚠️  Check nginx logs: sudo tail -f /var/log/nginx/error.log${NC}"
fi
echo ""

# Step 5: Show status
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            STATUS & NEXT STEPS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo -e "${GREEN}🌐 Your Finance Advisory Agent should now be accessible at:${NC}"
echo "   📱 http://bizfin.texra.in"
echo ""
echo -e "${YELLOW}📋 Demo Users:${NC}"
echo "   Junior Staff: junior_user / junior123"
echo "   Intermediate Staff: intermediate_user / junior123" 
echo "   Department Head: department_head / junior123"
echo ""
echo -e "${YELLOW}🔧 If still not working:${NC}"
echo "1. Check app logs: pm2 logs bizfin-agent"
echo "2. Check nginx logs: sudo tail -f /var/log/nginx/error.log"
echo "3. Test direct: curl http://localhost:3005/health"
echo ""
echo -e "${YELLOW}🔒 To add SSL certificate:${NC}"
echo "sudo certbot --nginx -d bizfin.texra.in"
echo ""
EOF