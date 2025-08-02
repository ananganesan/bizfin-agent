#!/bin/bash

# Step-by-step debugging for bizfin.texra.in
echo "🔍 Step-by-Step Debugging for bizfin.texra.in"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    STEP-BY-STEP DEBUG ANALYSIS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# STEP 1: Check DNS
echo -e "${YELLOW}STEP 1: 🌐 DNS Resolution Check${NC}"
echo "----------------------------------------"
echo -n "bizfin.texra.in resolves to: "
dig +short bizfin.texra.in A
echo -n "Expected: 37.27.216.55 | "
if [ "$(dig +short bizfin.texra.in A)" = "37.27.216.55" ]; then
    echo -e "${GREEN}✅ DNS OK${NC}"
    DNS_OK=true
else
    echo -e "${RED}❌ DNS FAILED${NC}"
    DNS_OK=false
fi
echo ""

# STEP 2: Check if we're on the right server
echo -e "${YELLOW}STEP 2: 🖥️  Server Identity Check${NC}"
echo "----------------------------------------"
echo -n "Current server IP: "
curl -s ifconfig.me 2>/dev/null || echo "Unable to detect"
echo -n "Expected: 37.27.216.55 | "
if [ "$(curl -s ifconfig.me)" = "37.27.216.55" ]; then
    echo -e "${GREEN}✅ Correct Server${NC}"
    SERVER_OK=true
else
    echo -e "${RED}❌ Wrong Server or IP changed${NC}"
    SERVER_OK=false
fi
echo ""

# STEP 3: Check if app exists
echo -e "${YELLOW}STEP 3: 📁 Application Files Check${NC}"
echo "----------------------------------------"
if [ -d "/var/www/bizfin-agent" ]; then
    echo -e "${GREEN}✅ App directory exists${NC}"
    echo "Contents:"
    ls -la /var/www/bizfin-agent/ | head -5
    
    if [ -f "/var/www/bizfin-agent/backend/server.js" ]; then
        echo -e "${GREEN}✅ Server.js exists${NC}"
        APP_EXISTS=true
    else
        echo -e "${RED}❌ server.js missing${NC}"
        APP_EXISTS=false
    fi
else
    echo -e "${RED}❌ App directory missing${NC}"
    APP_EXISTS=false
fi
echo ""

# STEP 4: Check if app is running
echo -e "${YELLOW}STEP 4: 🚀 Application Process Check${NC}"
echo "----------------------------------------"
echo "Checking for Node.js processes:"
NODE_PROCESSES=$(ps aux | grep -E "(node.*server\.js|bizfin)" | grep -v grep)
if [ ! -z "$NODE_PROCESSES" ]; then
    echo -e "${GREEN}✅ Node processes found:${NC}"
    echo "$NODE_PROCESSES"
    APP_RUNNING=true
else
    echo -e "${RED}❌ No Node processes running${NC}"
    APP_RUNNING=false
fi

echo ""
echo "Checking PM2:"
if command -v pm2 &> /dev/null; then
    PM2_STATUS=$(pm2 jlist 2>/dev/null)
    if echo "$PM2_STATUS" | grep -q "bizfin"; then
        echo -e "${GREEN}✅ PM2 process found${NC}"
        pm2 list | grep bizfin
    else
        echo -e "${RED}❌ No PM2 processes${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  PM2 not installed${NC}"
fi
echo ""

# STEP 5: Check port 3005
echo -e "${YELLOW}STEP 5: 🔌 Port 3005 Check${NC}"
echo "----------------------------------------"
PORT_CHECK=$(netstat -tlnp 2>/dev/null | grep ":3005")
if [ ! -z "$PORT_CHECK" ]; then
    echo -e "${GREEN}✅ Port 3005 is listening:${NC}"
    echo "$PORT_CHECK"
    PORT_OK=true
else
    echo -e "${RED}❌ Port 3005 not listening${NC}"
    PORT_OK=false
fi

echo ""
echo "Testing direct connection to port 3005:"
if curl -s --connect-timeout 5 http://localhost:3005/health > /dev/null; then
    echo -e "${GREEN}✅ Port 3005 responds to health check${NC}"
    HEALTH_OK=true
else
    echo -e "${RED}❌ Port 3005 not responding${NC}"
    HEALTH_OK=false
fi
echo ""

# STEP 6: Check nginx configuration
echo -e "${YELLOW}STEP 6: ⚙️  Nginx Configuration Check${NC}"
echo "----------------------------------------"
echo "Nginx sites enabled:"
if [ -d "/etc/nginx/sites-enabled" ]; then
    ls -la /etc/nginx/sites-enabled/ | grep -E "(bizfin|texra)" || echo "No texra/bizfin sites found"
    echo ""
    
    echo "Checking for bizfin configuration:"
    if sudo find /etc/nginx -name "*bizfin*" 2>/dev/null; then
        echo -e "${GREEN}✅ Bizfin config found${NC}"
        NGINX_CONFIG_EXISTS=true
    else
        echo -e "${RED}❌ No bizfin nginx config${NC}"
        NGINX_CONFIG_EXISTS=false
    fi
    
    echo ""
    echo "Checking nginx syntax:"
    if sudo nginx -t &>/dev/null; then
        echo -e "${GREEN}✅ Nginx syntax OK${NC}"
        NGINX_OK=true
    else
        echo -e "${RED}❌ Nginx syntax error${NC}"
        sudo nginx -t
        NGINX_OK=false
    fi
else
    echo -e "${RED}❌ Cannot access nginx config${NC}"
    NGINX_OK=false
fi
echo ""

# STEP 7: Test direct server response
echo -e "${YELLOW}STEP 7: 🌐 Direct Server Response Test${NC}"
echo "----------------------------------------"
echo "Testing localhost with Host header:"
LOCALHOST_RESPONSE=$(curl -s -I -H "Host: bizfin.texra.in" localhost 2>/dev/null)
if [ ! -z "$LOCALHOST_RESPONSE" ]; then
    echo "Response received:"
    echo "$LOCALHOST_RESPONSE" | head -3
    
    if echo "$LOCALHOST_RESPONSE" | grep -q "301\|302"; then
        echo -e "${RED}❌ Localhost also redirecting${NC}"
        LOCALHOST_REDIRECT=true
    else
        echo -e "${GREEN}✅ Localhost not redirecting${NC}"
        LOCALHOST_REDIRECT=false
    fi
else
    echo -e "${RED}❌ No response from localhost${NC}"
    LOCALHOST_REDIRECT=true
fi
echo ""

# STEP 8: Test external access
echo -e "${YELLOW}STEP 8: 🌍 External Access Test${NC}"
echo "----------------------------------------"
echo "Testing bizfin.texra.in from external:"
EXTERNAL_RESPONSE=$(curl -s -I http://bizfin.texra.in 2>/dev/null)
if [ ! -z "$EXTERNAL_RESPONSE" ]; then
    echo "External response:"
    echo "$EXTERNAL_RESPONSE" | head -3
    
    if echo "$EXTERNAL_RESPONSE" | grep -q "Location:"; then
        REDIRECT_TO=$(echo "$EXTERNAL_RESPONSE" | grep "Location:" | cut -d' ' -f2 | tr -d '\r')
        echo -e "${RED}❌ Redirecting to: $REDIRECT_TO${NC}"
        EXTERNAL_REDIRECT=true
    else
        echo -e "${GREEN}✅ No redirect detected${NC}"
        EXTERNAL_REDIRECT=false
    fi
else
    echo -e "${RED}❌ No external response${NC}"
    EXTERNAL_REDIRECT=true
fi
echo ""

# STEP 9: Summary and diagnosis
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}            DIAGNOSIS SUMMARY${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

echo -e "${YELLOW}📊 Status Summary:${NC}"
echo "DNS Resolution: $([ "$DNS_OK" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "Server Identity: $([ "$SERVER_OK" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "App Files: $([ "$APP_EXISTS" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "App Running: $([ "$APP_RUNNING" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "Port 3005: $([ "$PORT_OK" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "Health Check: $([ "$HEALTH_OK" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "Nginx Config: $([ "$NGINX_OK" = true ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ FAIL${NC}")"
echo "Localhost Test: $([ "$LOCALHOST_REDIRECT" = false ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ REDIRECTING${NC}")"
echo "External Test: $([ "$EXTERNAL_REDIRECT" = false ] && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ REDIRECTING${NC}")"
echo ""

echo -e "${YELLOW}🎯 Next Steps Based on Diagnosis:${NC}"
echo ""

if [ "$APP_RUNNING" = false ] || [ "$PORT_OK" = false ]; then
    echo -e "${RED}🚨 CRITICAL: Application not running${NC}"
    echo "Run: cd /var/www/bizfin-agent && pm2 start backend/server.js --name bizfin-agent"
fi

if [ "$NGINX_CONFIG_EXISTS" = false ]; then
    echo -e "${RED}🚨 CRITICAL: Nginx config missing${NC}"
    echo "Run: ./fix-subdomain.sh"
fi

if [ "$LOCALHOST_REDIRECT" = true ]; then
    echo -e "${RED}🚨 CRITICAL: Server-level redirect issue${NC}"
    echo "Check nginx config priority and wildcard rules"
fi

if [ "$EXTERNAL_REDIRECT" = true ] && [ "$LOCALHOST_REDIRECT" = false ]; then
    echo -e "${YELLOW}⚠️  External redirect but localhost works${NC}"
    echo "Possible Cloudflare or DNS-level redirect"
fi

echo ""
echo -e "${GREEN}💡 Ready for next step? Tell me which status shows ❌ FAIL${NC}"