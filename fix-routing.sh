#!/bin/bash

# Fix routing issue for bizfin.texra.in
echo "🔧 Fixing routing for bizfin.texra.in..."

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

APP_NAME="bizfin-agent"
DOMAIN="bizfin.texra.in"

echo -e "${YELLOW}🔍 Checking current nginx configuration...${NC}"

# Remove any existing configuration for this domain
sudo rm -f /etc/nginx/sites-enabled/bizfin.texra.in
sudo rm -f /etc/nginx/sites-available/bizfin.texra.in

# Create the nginx configuration with high priority
echo -e "${YELLOW}📝 Creating nginx configuration...${NC}"
sudo cp /var/www/$APP_NAME/deploy/nginx-priority.conf /etc/nginx/sites-available/bizfin.texra.in

# Enable the site with high priority (rename to ensure it loads first)
sudo ln -sf /etc/nginx/sites-available/bizfin.texra.in /etc/nginx/sites-enabled/00-bizfin.texra.in

# Test nginx configuration
echo -e "${YELLOW}🧪 Testing nginx configuration...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
    sudo systemctl reload nginx
else
    echo -e "${RED}❌ Nginx configuration error${NC}"
    exit 1
fi

# Check if the app is running
echo -e "${YELLOW}🔍 Checking application status...${NC}"
if pm2 list | grep -q "$APP_NAME"; then
    echo -e "${GREEN}✅ Application is running${NC}"
    pm2 restart $APP_NAME
else
    echo -e "${YELLOW}⚠️  Starting application...${NC}"
    cd /var/www/$APP_NAME
    pm2 start backend/server.js --name $APP_NAME --env production
fi

# Check if port 3005 is listening
echo -e "${YELLOW}🔍 Checking if port 3005 is listening...${NC}"
if netstat -tlnp | grep -q ":3005"; then
    echo -e "${GREEN}✅ Port 3005 is listening${NC}"
else
    echo -e "${RED}❌ Port 3005 is not listening${NC}"
    echo "Check application logs: pm2 logs $APP_NAME"
fi

# Show nginx sites order
echo -e "${YELLOW}📋 Current nginx sites order:${NC}"
ls -la /etc/nginx/sites-enabled/

echo ""
echo -e "${GREEN}✅ Routing fix completed!${NC}"
echo ""
echo -e "${GREEN}🌐 Your app should now be available at:${NC}"
echo "   http://bizfin.texra.in"
echo "   https://bizfin.texra.in (if SSL is configured)"
echo ""
echo -e "${GREEN}🔧 Debugging commands:${NC}"
echo "   Check app: pm2 status"
echo "   Check logs: pm2 logs $APP_NAME"
echo "   Check nginx: sudo nginx -t"
echo "   Reload nginx: sudo systemctl reload nginx"
echo ""
echo -e "${YELLOW}💡 If still redirecting, check:${NC}"
echo "   1. DNS settings for bizfin.texra.in"
echo "   2. Other nginx configurations that might conflict"
echo "   3. Cloudflare or CDN settings"