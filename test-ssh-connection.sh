#!/bin/bash

# Test SSH connection to server
echo "🔐 Testing SSH Connection to 37.27.216.55"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    SSH CONNECTION TEST${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Test different key locations
echo -e "${YELLOW}Testing SSH keys...${NC}"
echo ""

# Common key locations to test
KEY_LOCATIONS=(
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_rsa"
    "$HOME/.ssh/hetzner_key"
    "$HOME/.ssh/bizfin_key"
    "$HOME/.ssh/id_ecdsa"
)

WORKING_KEY=""

for KEY in "${KEY_LOCATIONS[@]}"; do
    if [ -f "$KEY" ]; then
        echo -n "Testing $KEY... "
        if ssh -i "$KEY" -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@37.27.216.55 echo "Connected" 2>/dev/null; then
            echo -e "${GREEN}✅ SUCCESS!${NC}"
            WORKING_KEY="$KEY"
            break
        else
            echo -e "${RED}❌ Failed${NC}"
        fi
    fi
done

if [ -z "$WORKING_KEY" ]; then
    echo ""
    echo -e "${RED}❌ No working SSH key found!${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "1. Check if you have the correct private key"
    echo "2. The public key you shared was: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY89Z0XiaslNFoZS60ig6EI0sfl4jAFz2u9efBRwy+I"
    echo "3. You need the matching PRIVATE key (not the .pub file)"
    echo ""
    echo "Try finding your key:"
    echo "  find ~ -name 'id_*' -not -name '*.pub' 2>/dev/null | grep -E '(ssh|key)'"
else
    echo ""
    echo -e "${GREEN}🎉 SSH Connection Successful!${NC}"
    echo -e "${GREEN}Working key: $WORKING_KEY${NC}"
    echo ""
    
    # Add to SSH config for easy access
    if ! grep -q "Host hetzner-bizfin" ~/.ssh/config 2>/dev/null; then
        echo -e "${YELLOW}Adding to SSH config for easy access...${NC}"
        cat >> ~/.ssh/config << EOF

# Business Finance Agent Server
Host hetzner-bizfin
    HostName 37.27.216.55
    User root
    IdentityFile $WORKING_KEY
    StrictHostKeyChecking no
EOF
        echo -e "${GREEN}✅ Added to SSH config${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🚀 You can now connect using:${NC}"
    echo "  ssh hetzner-bizfin"
    echo "  OR"
    echo "  ssh -i $WORKING_KEY root@37.27.216.55"
    echo ""
    echo -e "${GREEN}🎯 Deploy your app:${NC}"
    echo "  ssh hetzner-bizfin 'cd /var/www/bizfin-agent && git pull && pm2 restart bizfin-agent'"
    echo ""
    echo -e "${GREEN}🆕 Fresh deployment:${NC}"
    echo "  ssh hetzner-bizfin 'git clone https://github.com/ananganesan/bizfin-agent.git /var/www/bizfin-agent && cd /var/www/bizfin-agent && ./deploy-to-hetzner.sh'"
fi