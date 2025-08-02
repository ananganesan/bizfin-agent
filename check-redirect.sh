#!/bin/bash

# Check redirect behavior for bizfin.texra.in
echo "🔍 Checking redirect behavior for bizfin.texra.in..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    REDIRECT ANALYSIS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Test redirect chain
echo -e "${YELLOW}1. 🔄 Testing Redirect Chain${NC}"
echo "Following redirects for http://bizfin.texra.in:"
curl -v -L http://bizfin.texra.in 2>&1 | grep -E "(HTTP|Location:|Host:)" | head -10
echo ""

echo "Testing without following redirects:"
curl -s -I http://bizfin.texra.in | head -5
echo ""

# Check nginx configuration
echo -e "${YELLOW}2. ⚙️  Checking Nginx Configuration${NC}"
echo "Looking for bizfin.texra.in in nginx configs:"
if [ -d "/etc/nginx" ]; then
    sudo find /etc/nginx -name "*.conf" -exec grep -l "bizfin" {} \; 2>/dev/null || echo "No bizfin configuration found"
    
    echo ""
    echo "Active nginx sites with texra:"
    ls -la /etc/nginx/sites-enabled/ | grep texra || echo "No texra sites found"
    echo ""
    
    echo "Checking for default catch-all configurations:"
    sudo grep -r "server_name.*texra.in" /etc/nginx/sites-enabled/ 2>/dev/null || echo "No texra.in server blocks found"
else
    echo "Nginx directory not accessible"
fi
echo ""

# Check what's actually serving the content
echo -e "${YELLOW}3. 🌐 Testing Direct Server Response${NC}"
echo "Testing with Host header on local server:"
curl -s -I -H "Host: bizfin.texra.in" localhost | head -5
echo ""

echo "Testing port 3005 directly:"
curl -s -I http://localhost:3005 | head -5 2>/dev/null || echo "Port 3005 not responding"
echo ""

# Check application status
echo -e "${YELLOW}4. 📱 Application Status Check${NC}"
echo "Checking what's running on the server:"
if command -v pm2 &> /dev/null; then
    pm2 list 2>/dev/null || echo "PM2 not running or no processes"
else
    echo "PM2 not available, checking processes:"
    ps aux | grep -E "(node|bizfin)" | grep -v grep || echo "No Node.js processes found"
fi
echo ""

echo "Checking port usage:"
netstat -tlnp 2>/dev/null | grep -E ":(80|443|3005|3000)" || echo "No relevant ports listening"
echo ""

# Test different approaches
echo -e "${YELLOW}5. 🧪 Testing Different Access Methods${NC}"
echo "Method 1 - Direct domain:"
curl -s -o /dev/null -w "Status: %{http_code}, Redirect: %{redirect_url}\n" http://bizfin.texra.in

echo "Method 2 - With www:"
curl -s -o /dev/null -w "Status: %{http_code}, Redirect: %{redirect_url}\n" http://www.bizfin.texra.in

echo "Method 3 - HTTPS:"
curl -s -o /dev/null -w "Status: %{http_code}, Redirect: %{redirect_url}\n" https://bizfin.texra.in 2>/dev/null || echo "HTTPS failed"
echo ""

# Solution suggestions
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            DIAGNOSIS & SOLUTION${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

echo -e "${YELLOW}🔍 Analysis:${NC}"
echo "The redirect to texra.in/login suggests:"
echo "1. 🎯 bizfin.texra.in is being caught by the main texra.in nginx config"
echo "2. 🔄 The main site has a redirect rule to /login"
echo "3. ⚙️  Our specific bizfin.texra.in config isn't being used"
echo ""

echo -e "${GREEN}💡 Solutions:${NC}"
echo ""
echo -e "${YELLOW}Quick Fix 1 - Check nginx config priority:${NC}"
echo "sudo ls -la /etc/nginx/sites-enabled/"
echo "sudo nginx -T | grep -A 10 -B 5 'server_name.*texra'"
echo ""
echo -e "${YELLOW}Quick Fix 2 - Ensure our config is loaded first:${NC}"
echo "sudo rm /etc/nginx/sites-enabled/bizfin.texra.in"
echo "sudo ln -sf /etc/nginx/sites-available/bizfin.texra.in /etc/nginx/sites-enabled/00-bizfin.texra.in"
echo "sudo nginx -t && sudo systemctl reload nginx"
echo ""
echo -e "${YELLOW}Quick Fix 3 - Restart application:${NC}"
echo "cd /var/www/bizfin-agent"
echo "pm2 restart bizfin-agent || pm2 start backend/server.js --name bizfin-agent"
echo ""
echo -e "${YELLOW}Alternative - Use path-based (guaranteed to work):${NC}"
echo "./alternative-access.sh  # Sets up texra.in/bizfin-agent"
echo ""