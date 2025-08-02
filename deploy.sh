#!/bin/bash

# Production deployment script for bizfin-agent
echo "🚀 Deploying Business Finance Advisory Agent to production..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're on the server
if [ ! -d "/var/www" ]; then
    echo -e "${RED}❌ This script should be run on the production server${NC}"
    exit 1
fi

# App configuration
APP_NAME="bizfin-agent"
APP_DIR="/var/www/$APP_NAME"
DOMAIN="bizfin.texra.in"
PORT="3005"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  App: $APP_NAME"
echo "  Directory: $APP_DIR"
echo "  Domain: $DOMAIN"
echo "  Port: $PORT"
echo ""

# Create app directory if it doesn't exist
if [ ! -d "$APP_DIR" ]; then
    echo -e "${YELLOW}📁 Creating app directory...${NC}"
    sudo mkdir -p $APP_DIR
    sudo chown -R $USER:$USER $APP_DIR
fi

# Clone or update repository
cd $APP_DIR
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Cloning repository...${NC}"
    git clone https://github.com/yourusername/bizfin-agent.git .
else
    echo -e "${YELLOW}🔄 Updating repository...${NC}"
    git pull origin main
fi

# Install Node.js 18 if not installed
if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    echo -e "${YELLOW}📦 Installing Node.js 18...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 if not installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}📦 Installing PM2...${NC}"
    sudo npm install -g pm2
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
cd backend && npm install --production
cd ../frontend && npm install --production
cd ..

# Create uploads directory
mkdir -p backend/uploads
chmod 755 backend/uploads

# Set up environment file
echo -e "${YELLOW}⚙️  Setting up environment...${NC}"
if [ ! -f "backend/.env" ]; then
    echo -e "${RED}❌ Please create backend/.env with your production settings${NC}"
    echo "Example:"
    echo "PORT=3005"
    echo "NODE_ENV=production"
    echo "ANTHROPIC_API_KEY=your_api_key"
    echo "JWT_SECRET=your_jwt_secret"
    echo "UPLOAD_DIR=./uploads"
    echo "MAX_FILE_SIZE=10485760"
    echo "CORS_ORIGIN=https://bizfin.texra.in"
    exit 1
fi

# Start/restart with PM2
echo -e "${YELLOW}🔄 Starting application with PM2...${NC}"
pm2 stop $APP_NAME 2>/dev/null || true
pm2 delete $APP_NAME 2>/dev/null || true
pm2 start backend/server.js --name $APP_NAME --env production

# Set up Nginx configuration with priority
echo -e "${YELLOW}🌐 Configuring Nginx...${NC}"
sudo rm -f /etc/nginx/sites-enabled/bizfin.texra.in
sudo rm -f /etc/nginx/sites-available/bizfin.texra.in
sudo cp deploy/nginx-priority.conf /etc/nginx/sites-available/$DOMAIN
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/00-$DOMAIN

# Test Nginx configuration
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
    sudo systemctl reload nginx
else
    echo -e "${RED}❌ Nginx configuration error${NC}"
    exit 1
fi

# Set up SSL with Let's Encrypt (optional)
if command -v certbot &> /dev/null; then
    echo -e "${YELLOW}🔒 Setting up SSL certificate...${NC}"
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@texra.in
fi

# Save PM2 configuration
pm2 save
pm2 startup | tail -1 | sudo bash

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo -e "${GREEN}🌐 Your app is now available at:${NC}"
echo "   HTTP:  http://$DOMAIN"
echo "   HTTPS: https://$DOMAIN (if SSL is configured)"
echo ""
echo -e "${GREEN}📊 Monitoring:${NC}"
echo "   PM2 Status: pm2 status"
echo "   PM2 Logs:   pm2 logs $APP_NAME"
echo "   PM2 Restart: pm2 restart $APP_NAME"
echo ""
echo -e "${GREEN}🎯 Demo Users:${NC}"
echo "   Junior Staff: junior_user / junior123"
echo "   Intermediate Staff: intermediate_user / junior123"
echo "   Department Head: department_head / junior123"