#!/bin/bash

# Test DNS propagation and subdomain access
echo "🧪 Testing DNS propagation for bizfin.texra.in..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    DNS PROPAGATION TEST${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Expected IP
EXPECTED_IP="37.27.216.55"

# Test DNS resolution
echo -e "${YELLOW}1. 🌐 Testing DNS Resolution${NC}"
echo -n "Checking bizfin.texra.in: "

RESOLVED_IP=$(dig +short bizfin.texra.in A | head -1)

if [ "$RESOLVED_IP" = "$EXPECTED_IP" ]; then
    echo -e "${GREEN}✅ SUCCESS - Resolved to $RESOLVED_IP${NC}"
    DNS_OK=true
else
    echo -e "${RED}❌ FAILED - Got: '$RESOLVED_IP' Expected: '$EXPECTED_IP'${NC}"
    DNS_OK=false
fi
echo ""

# Test with different DNS servers
echo -e "${YELLOW}2. 🔍 Testing Multiple DNS Servers${NC}"
echo "Google DNS (8.8.8.8):"
dig @8.8.8.8 +short bizfin.texra.in A | head -1 || echo "No response"

echo "Cloudflare DNS (1.1.1.1):"
dig @1.1.1.1 +short bizfin.texra.in A | head -1 || echo "No response"

echo "Local DNS:"
dig +short bizfin.texra.in A | head -1 || echo "No response"
echo ""

# Test HTTP access
echo -e "${YELLOW}3. 🌐 Testing HTTP Access${NC}"
if [ "$DNS_OK" = true ]; then
    echo "Testing HTTP connection to bizfin.texra.in:"
    
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 http://bizfin.texra.in)
    echo "HTTP Status: $HTTP_RESPONSE"
    
    if [ "$HTTP_RESPONSE" = "200" ] || [ "$HTTP_RESPONSE" = "301" ] || [ "$HTTP_RESPONSE" = "302" ]; then
        echo -e "${GREEN}✅ HTTP connection successful${NC}"
    else
        echo -e "${RED}❌ HTTP connection failed${NC}"
    fi
    
    echo ""
    echo "Testing HTTPS connection to bizfin.texra.in:"
    HTTPS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 https://bizfin.texra.in)
    echo "HTTPS Status: $HTTPS_RESPONSE"
    
    if [ "$HTTPS_RESPONSE" = "200" ] || [ "$HTTPS_RESPONSE" = "301" ] || [ "$HTTPS_RESPONSE" = "302" ]; then
        echo -e "${GREEN}✅ HTTPS connection successful${NC}"
    else
        echo -e "${RED}❌ HTTPS connection failed - SSL certificate may need setup${NC}"
    fi
else
    echo -e "${YELLOW}⏳ Skipping HTTP test - DNS not propagated yet${NC}"
fi
echo ""

# Check application status
echo -e "${YELLOW}4. 📱 Checking Application Status${NC}"
if command -v pm2 &> /dev/null; then
    echo "PM2 Status:"
    pm2 list | grep bizfin || echo "bizfin-agent not found in PM2"
    
    echo ""
    echo "Port 3005 Status:"
    if netstat -tlnp | grep -q ":3005"; then
        echo -e "${GREEN}✅ Port 3005 is listening${NC}"
    else
        echo -e "${RED}❌ Port 3005 is not listening${NC}"
        echo "Starting application..."
        cd /var/www/bizfin-agent 2>/dev/null && pm2 start backend/server.js --name bizfin-agent
    fi
else
    echo "PM2 not available"
fi
echo ""

# Summary and next steps
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            SUMMARY & NEXT STEPS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

if [ "$DNS_OK" = true ]; then
    echo -e "${GREEN}🎉 DNS propagation successful!${NC}"
    echo ""
    echo -e "${GREEN}✅ Your Finance Advisory Agent should be accessible at:${NC}"
    echo "   🌐 http://bizfin.texra.in"
    echo "   🔒 https://bizfin.texra.in (if SSL is configured)"
    echo ""
    echo -e "${YELLOW}📋 Demo Users:${NC}"
    echo "   Junior Staff: junior_user / junior123"
    echo "   Intermediate Staff: intermediate_user / junior123"
    echo "   Department Head: department_head / junior123"
    echo ""
    
    if [ "$HTTPS_RESPONSE" != "200" ]; then
        echo -e "${YELLOW}🔒 To setup SSL certificate:${NC}"
        echo "sudo certbot --nginx -d bizfin.texra.in"
    fi
else
    echo -e "${YELLOW}⏳ DNS propagation in progress...${NC}"
    echo ""
    echo "This can take 5-60 minutes. Check again with:"
    echo "nslookup bizfin.texra.in"
    echo ""
    echo -e "${GREEN}✅ Alternative access (works now):${NC}"
    echo "   🌐 https://texra.in/bizfin-agent (if path-based setup)"
    echo "   🔧 http://37.27.216.55:3005 (direct access)"
fi
echo ""