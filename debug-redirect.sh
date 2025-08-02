#!/bin/bash

# Debug redirect issue for bizfin.texra.in
echo "🔍 Debugging redirect issue for bizfin.texra.in..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    REDIRECT DEBUGGING FOR BIZFIN.TEXRA.IN${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. Check DNS resolution
echo -e "${YELLOW}1. 🌐 Checking DNS resolution...${NC}"
echo -n "DNS lookup for bizfin.texra.in: "
if nslookup bizfin.texra.in > /dev/null 2>&1; then
    nslookup bizfin.texra.in | grep "Address:" | tail -1
else
    echo -e "${RED}❌ DNS resolution failed${NC}"
fi
echo ""

# 2. Check if subdomain exists in DNS
echo -e "${YELLOW}2. 🔍 Checking A record...${NC}"
dig +short bizfin.texra.in A
echo ""

# 3. Test direct server access
echo -e "${YELLOW}3. 🎯 Testing direct server access...${NC}"
echo "Testing HTTP request to server with Host header:"
curl -s -I -H "Host: bizfin.texra.in" localhost | head -5
echo ""

# 4. Check nginx configuration
echo -e "${YELLOW}4. ⚙️  Checking nginx configuration...${NC}"
echo "Active nginx sites:"
ls -la /etc/nginx/sites-enabled/ | grep texra
echo ""

echo "Checking for wildcard server configurations:"
sudo grep -r "server_name.*\*.*texra.in" /etc/nginx/sites-enabled/ || echo "No wildcard configs found"
echo ""

# 5. Check for redirects in nginx
echo -e "${YELLOW}5. 🔄 Checking for redirect rules...${NC}"
echo "Searching for redirect rules in nginx configs:"
sudo grep -r -i "return.*301\|return.*302\|redirect" /etc/nginx/sites-enabled/ | grep -i texra || echo "No redirect rules found in nginx"
echo ""

# 6. Check application status
echo -e "${YELLOW}6. 📱 Checking application status...${NC}"
if command -v pm2 &> /dev/null; then
    pm2 list | grep bizfin || echo "bizfin-agent not found in PM2"
    echo ""
    echo "Port 3005 status:"
    netstat -tlnp | grep :3005 || echo "Port 3005 not listening"
else
    echo "PM2 not installed"
fi
echo ""

# 7. Test with different methods
echo -e "${YELLOW}7. 🧪 Testing different access methods...${NC}"

echo "Method 1 - Direct HTTP to localhost:3005:"
curl -s -I http://localhost:3005/health | head -3 || echo "Failed to connect to port 3005"
echo ""

echo "Method 2 - HTTP to domain (should show redirect):"
curl -s -I http://bizfin.texra.in | head -5 || echo "Failed to connect to bizfin.texra.in"
echo ""

echo "Method 3 - HTTPS to domain:"
curl -s -I https://bizfin.texra.in | head -5 || echo "Failed to connect to https://bizfin.texra.in"
echo ""

# 8. Check for external redirects
echo -e "${YELLOW}8. 🌍 Checking for external redirect sources...${NC}"
echo "Checking if this is a DNS-level redirect:"
echo "Trace route to bizfin.texra.in:"
ping -c 1 bizfin.texra.in 2>/dev/null | head -1 || echo "Ping failed"
echo ""

# 9. Suggestions
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            DIAGNOSIS & SOLUTIONS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

echo -e "${GREEN}💡 Possible causes and solutions:${NC}"
echo ""
echo -e "${YELLOW}A. DNS Issue:${NC}"
echo "   - bizfin.texra.in might not have an A record"
echo "   - Solution: Add A record: bizfin.texra.in → your_server_ip"
echo ""
echo -e "${YELLOW}B. Cloudflare/CDN Redirect:${NC}"
echo "   - Cloudflare page rules might redirect *.texra.in → texra.in"
echo "   - Solution: Check Cloudflare Page Rules and DNS settings"
echo ""
echo -e "${YELLOW}C. Wildcard SSL/Redirect:${NC}"
echo "   - SSL cert or redirect rule catches all *.texra.in"
echo "   - Solution: Add specific rule for bizfin.texra.in"
echo ""
echo -e "${YELLOW}D. Alternative Access:${NC}"
echo "   - Use direct port access: http://texra.in:3005"
echo "   - Use different subdomain or path: texra.in/bizfin"
echo ""

echo -e "${GREEN}🔧 Quick fixes to try:${NC}"
echo "1. Add DNS A record: bizfin.texra.in → $(curl -s ifconfig.me)"
echo "2. Test direct: http://$(curl -s ifconfig.me):3005"
echo "3. Check Cloudflare settings for *.texra.in redirects"
echo "4. Create path-based routing: texra.in/bizfin-agent"
echo ""