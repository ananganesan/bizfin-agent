#!/bin/bash

# Deployment script for bizfin-agent on Hetzner server (37.27.216.55)
echo "🚀 Deploying Business Finance Advisory Agent to Hetzner Server"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="bizfin-agent"
APP_DIR="/var/www/bizfin-agent"
DOMAIN="bizfin.texra.in"
PORT="3005"
REPO_URL="https://github.com/ananganesan/bizfin-agent.git"

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    BIZFIN-AGENT DEPLOYMENT${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""
echo "Server: 37.27.216.55 (Hetzner)"
echo "Domain: $DOMAIN"
echo "Port: $PORT"
echo ""

# Check if we're on the right server
SERVER_IP=$(curl -s ifconfig.me)
if [ "$SERVER_IP" != "37.27.216.55" ]; then
    echo -e "${RED}❌ Wrong server! Current IP: $SERVER_IP${NC}"
    echo "This script should be run on server 37.27.216.55"
    exit 1
fi

# STEP 1: Install dependencies
echo -e "${YELLOW}📦 STEP 1: Installing System Dependencies${NC}"
echo "----------------------------------------"

# Update system
sudo apt-get update

# Install Node.js 18 if not installed
if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    echo "Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 if not installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    sudo npm install -g pm2
fi

# Install nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    sudo apt-get install -y nginx
fi

# Install certbot if not installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot for SSL..."
    sudo apt-get install -y certbot python3-certbot-nginx
fi

echo -e "${GREEN}✅ System dependencies installed${NC}"
echo ""

# STEP 2: Clone/Update repository
echo -e "${YELLOW}📂 STEP 2: Setting Up Application${NC}"
echo "----------------------------------------"

# Create app directory
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR

cd $APP_DIR

# Clone or update repository
if [ ! -d ".git" ]; then
    echo "Cloning repository..."
    git clone $REPO_URL .
else
    echo "Updating repository..."
    git pull origin main
fi

# Copy files from local if repo not set
if [ ! -f "backend/server.js" ]; then
    echo -e "${YELLOW}Repository empty. Please upload files manually to $APP_DIR${NC}"
    echo "Use: scp -r * user@37.27.216.55:$APP_DIR/"
fi

echo -e "${GREEN}✅ Application files ready${NC}"
echo ""

# STEP 3: Install app dependencies
echo -e "${YELLOW}📦 STEP 3: Installing App Dependencies${NC}"
echo "----------------------------------------"

if [ -f "backend/package.json" ]; then
    cd backend && npm install --production
    cd ..
fi

if [ -f "frontend/package.json" ]; then
    cd frontend && npm install --production
    cd ..
fi

# Create uploads directory
mkdir -p backend/uploads
chmod 755 backend/uploads

echo -e "${GREEN}✅ App dependencies installed${NC}"
echo ""

# STEP 4: Setup environment
echo -e "${YELLOW}⚙️  STEP 4: Environment Configuration${NC}"
echo "----------------------------------------"

if [ ! -f "backend/.env" ]; then
    cat > backend/.env << EOF
PORT=3005
NODE_ENV=production
ANTHROPIC_API_KEY=your_anthropic_api_key_here
JWT_SECRET=$(openssl rand -base64 32)
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
CORS_ORIGIN=https://bizfin.texra.in
EOF
    echo -e "${YELLOW}⚠️  Created backend/.env - Please add your ANTHROPIC_API_KEY${NC}"
else
    echo "Using existing .env file"
fi

echo -e "${GREEN}✅ Environment configured${NC}"
echo ""

# STEP 5: Setup PM2
echo -e "${YELLOW}🚀 STEP 5: Starting Application with PM2${NC}"
echo "----------------------------------------"

cd $APP_DIR
pm2 stop $APP_NAME 2>/dev/null || true
pm2 delete $APP_NAME 2>/dev/null || true

if [ -f "backend/server.js" ]; then
    pm2 start backend/server.js --name $APP_NAME --env production
    pm2 save
    pm2 startup | grep "sudo" | bash
    
    # Check if running
    sleep 3
    if pm2 list | grep -q $APP_NAME; then
        echo -e "${GREEN}✅ Application started successfully${NC}"
    else
        echo -e "${RED}❌ Application failed to start${NC}"
        pm2 logs $APP_NAME --lines 20
    fi
else
    echo -e "${RED}❌ backend/server.js not found${NC}"
fi
echo ""

# STEP 6: Configure Nginx
echo -e "${YELLOW}🌐 STEP 6: Configuring Nginx${NC}"
echo "----------------------------------------"

# Remove old configs
sudo rm -f /etc/nginx/sites-enabled/bizfin*
sudo rm -f /etc/nginx/sites-available/bizfin*

# Create nginx config
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << 'EOF'
server {
    listen 80;
    server_name bizfin.texra.in www.bizfin.texra.in;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Frontend static files
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
    
    # API proxy
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
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Health check
    location /health {
        proxy_pass http://localhost:3005/health;
        access_log off;
    }
    
    client_max_body_size 10M;
}
EOF

# Enable site with priority
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/00-$DOMAIN

# Test and reload nginx
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx configured successfully${NC}"
else
    echo -e "${RED}❌ Nginx configuration error${NC}"
    sudo nginx -t
fi
echo ""

# STEP 7: Setup SSL
echo -e "${YELLOW}🔒 STEP 7: Setting up SSL Certificate${NC}"
echo "----------------------------------------"

if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "Obtaining SSL certificate..."
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN --redirect
    
    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        echo -e "${GREEN}✅ SSL certificate obtained${NC}"
    else
        echo -e "${YELLOW}⚠️  SSL setup failed - site will work on HTTP${NC}"
    fi
else
    echo -e "${GREEN}✅ SSL certificate already exists${NC}"
fi
echo ""

# STEP 8: Verification
echo -e "${YELLOW}🧪 STEP 8: Verification${NC}"
echo "----------------------------------------"

# Check port
if netstat -tlnp | grep -q ":$PORT"; then
    echo -e "${GREEN}✅ Port $PORT is listening${NC}"
else
    echo -e "${RED}❌ Port $PORT not listening${NC}"
fi

# Check health endpoint
if curl -s http://localhost:$PORT/health > /dev/null; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
fi

# Test nginx routing
RESPONSE=$(curl -s -I -H "Host: $DOMAIN" localhost | head -1)
if echo "$RESPONSE" | grep -q "200\|404"; then
    echo -e "${GREEN}✅ Nginx routing working${NC}"
else
    echo -e "${YELLOW}⚠️  Nginx routing issue${NC}"
fi
echo ""

# Final summary
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            DEPLOYMENT COMPLETE${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""
echo -e "${GREEN}🎉 Your Finance Advisory Agent is deployed!${NC}"
echo ""
echo -e "${GREEN}🌐 Access your application:${NC}"
echo "   HTTP:  http://$DOMAIN"
echo "   HTTPS: https://$DOMAIN"
echo ""
echo -e "${GREEN}📋 Demo Users:${NC}"
echo "   Junior Staff: junior_user / junior123"
echo "   Intermediate Staff: intermediate_user / junior123"
echo "   Department Head: department_head / junior123"
echo ""
echo -e "${GREEN}🔧 Management Commands:${NC}"
echo "   View logs: pm2 logs $APP_NAME"
echo "   Restart: pm2 restart $APP_NAME"
echo "   Status: pm2 status"
echo ""
echo -e "${YELLOW}⚠️  Don't forget to:${NC}"
echo "1. Add your ANTHROPIC_API_KEY to backend/.env"
echo "2. Update the repository URL in this script"
echo "3. Test all features"
echo ""