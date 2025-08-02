#!/bin/bash

# Check hosting and service provider for texra.in
echo "🔍 Checking hosting and service provider for texra.in..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    HOSTING ANALYSIS FOR TEXRA.IN${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. DNS Information
echo -e "${YELLOW}1. 🌐 DNS Information${NC}"
echo "A Records:"
dig +short texra.in A | head -5
echo ""

echo "NS Records (Name Servers):"
dig +short texra.in NS
echo ""

echo "MX Records:"
dig +short texra.in MX
echo ""

# 2. WHOIS Information
echo -e "${YELLOW}2. 📋 WHOIS Information${NC}"
if command -v whois &> /dev/null; then
    echo "Domain Registration Info:"
    whois texra.in | grep -E "(Registrar|Name Server|Creation Date|Registry Expiry|Registrant)" | head -10
    echo ""
else
    echo "whois command not available"
fi

# 3. Server Information
echo -e "${YELLOW}3. 🖥️  Server Information${NC}"
echo "Server IP and Location:"
SERVER_IP=$(dig +short texra.in A | head -1)
echo "IP: $SERVER_IP"

if command -v curl &> /dev/null; then
    echo "IP Location Info:"
    curl -s "http://ip-api.com/json/$SERVER_IP" | grep -E '"country"|"regionName"|"city"|"org"|"as"' | sed 's/[",]//g'
fi
echo ""

# 4. HTTP Headers
echo -e "${YELLOW}4. 🌐 HTTP Response Headers${NC}"
echo "Server headers from texra.in:"
curl -s -I https://texra.in | head -10
echo ""

# 5. SSL Certificate Info
echo -e "${YELLOW}5. 🔒 SSL Certificate Information${NC}"
echo "SSL Certificate details:"
echo | openssl s_client -servername texra.in -connect texra.in:443 2>/dev/null | openssl x509 -noout -text | grep -E "(Issuer|Subject|DNS)" | head -5
echo ""

# 6. Cloudflare Check
echo -e "${YELLOW}6. ☁️  Cloudflare Detection${NC}"
CF_CHECK=$(curl -s -I https://texra.in | grep -i cloudflare)
if [ ! -z "$CF_CHECK" ]; then
    echo "✅ Cloudflare detected:"
    echo "$CF_CHECK"
else
    echo "❌ No Cloudflare headers found"
fi
echo ""

# 7. Technology Stack
echo -e "${YELLOW}7. 🛠️  Technology Stack${NC}"
echo "Server technology:"
curl -s -I https://texra.in | grep -i "server\|x-powered-by\|x-technology" || echo "No server technology headers found"
echo ""

# 8. Hosting Provider Guess
echo -e "${YELLOW}8. 🏢 Hosting Provider Analysis${NC}"
echo "Based on IP and headers:"

# Check common hosting providers
if curl -s -I https://texra.in | grep -qi "cloudflare"; then
    echo "🔸 CDN: Cloudflare"
fi

if curl -s -I https://texra.in | grep -qi "nginx"; then
    echo "🔸 Web Server: Nginx"
fi

if curl -s -I https://texra.in | grep -qi "apache"; then
    echo "🔸 Web Server: Apache"
fi

# Check IP range for common providers
echo "🔸 IP Analysis:"
curl -s "http://ip-api.com/json/$SERVER_IP" | grep -o '"org":"[^"]*"' | sed 's/"org":"//g' | sed 's/"//g'

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}            SUMMARY${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo "Domain: texra.in"
echo "IP: $SERVER_IP"
echo "To add DNS record for bizfin.texra.in:"
echo "1. Login to your DNS provider (shown in NS records above)"
echo "2. Add A record: bizfin -> $SERVER_IP"
echo "3. Wait for propagation (5-60 minutes)"
echo ""