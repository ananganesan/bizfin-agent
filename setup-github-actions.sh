#!/bin/bash

# Setup GitHub Actions CI/CD
echo "🚀 Setting up GitHub Actions CI/CD"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    GITHUB ACTIONS CI/CD SETUP${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

REPO_URL="https://github.com/ananganesan/bizfin-agent"

echo -e "${GREEN}Your repository: $REPO_URL${NC}"
echo ""

echo -e "${YELLOW}📋 Step 1: Generate Secrets${NC}"
echo "----------------------------------------"

# Generate JWT secret if not exists
JWT_SECRET=$(openssl rand -base64 32)
echo "Generated JWT_SECRET: $JWT_SECRET"
echo ""

echo -e "${YELLOW}📋 Step 2: Add GitHub Secrets${NC}"
echo "----------------------------------------"
echo ""
echo -e "${GREEN}Go to: $REPO_URL/settings/secrets/actions${NC}"
echo ""
echo "Click 'New repository secret' for each of these:"
echo ""
echo -e "${BLUE}1. HOST${NC}"
echo "   Name: HOST"
echo "   Value: 37.27.216.55"
echo ""
echo -e "${BLUE}2. USERNAME${NC}"
echo "   Name: USERNAME"
echo "   Value: root"
echo ""
echo -e "${BLUE}3. PORT${NC}"
echo "   Name: PORT"
echo "   Value: 22"
echo ""
echo -e "${BLUE}4. JWT_SECRET${NC}"
echo "   Name: JWT_SECRET"
echo "   Value: $JWT_SECRET"
echo ""
echo -e "${BLUE}5. ANTHROPIC_API_KEY${NC}"
echo "   Name: ANTHROPIC_API_KEY"
echo "   Value: [Your Claude API key]"
echo ""
echo -e "${BLUE}6. DEPLOY_KEY${NC}"
echo "   Name: DEPLOY_KEY"
echo "   Value: [Your SSH private key content]"
echo ""

echo -e "${YELLOW}📋 Step 3: SSH Key Instructions${NC}"
echo "----------------------------------------"
echo ""
echo "For the DEPLOY_KEY, you need your SSH private key content."
echo ""
echo "Find your private key (try these locations):"
echo "  - ~/.ssh/id_ed25519"
echo "  - ~/.ssh/id_rsa"
echo "  - ~/.ssh/hetzner_key"
echo ""
echo "Copy the ENTIRE content including:"
echo "-----BEGIN OPENSSH PRIVATE KEY-----"
echo "[key content]"
echo "-----END OPENSSH PRIVATE KEY-----"
echo ""

# Check if we can find a key
if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${GREEN}Found key at: ~/.ssh/id_ed25519${NC}"
    echo "Copy its content with: cat ~/.ssh/id_ed25519"
elif [ -f ~/.ssh/id_rsa ]; then
    echo -e "${GREEN}Found key at: ~/.ssh/id_rsa${NC}"
    echo "Copy its content with: cat ~/.ssh/id_rsa"
fi

echo ""
echo -e "${YELLOW}📋 Step 4: Test CI/CD${NC}"
echo "----------------------------------------"
echo ""
echo "After adding all secrets, test the deployment:"
echo ""
echo "1. Make a small change:"
echo "   echo '# CI/CD Test' >> README.md"
echo ""
echo "2. Commit and push:"
echo "   git add README.md"
echo "   git commit -m 'Test CI/CD deployment'"
echo "   git push"
echo ""
echo "3. Watch the deployment:"
echo "   Go to: $REPO_URL/actions"
echo ""

echo -e "${YELLOW}📋 Step 5: Quick Links${NC}"
echo "----------------------------------------"
echo ""
echo -e "${GREEN}Add secrets here:${NC}"
echo "$REPO_URL/settings/secrets/actions"
echo ""
echo -e "${GREEN}View deployments:${NC}"
echo "$REPO_URL/actions"
echo ""
echo -e "${GREEN}Your app:${NC}"
echo "https://bizfin.texra.in"
echo ""

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    AUTOMATED DEPLOYMENT BENEFITS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""
echo "✅ Every push to main branch auto-deploys"
echo "✅ No manual SSH needed"
echo "✅ Automatic testing before deploy"
echo "✅ Rollback on failures"
echo "✅ Deployment history tracked"
echo ""

# Create a helper to test connection
cat > test-ssh-key.sh << 'EOF'
#!/bin/bash
# Test if your SSH key works with the server

echo "Testing SSH connection to 37.27.216.55..."

if [ -z "$1" ]; then
    echo "Usage: ./test-ssh-key.sh /path/to/private_key"
    echo "Example: ./test-ssh-key.sh ~/.ssh/id_ed25519"
    exit 1
fi

if ssh -i "$1" -o BatchMode=yes -o ConnectTimeout=5 root@37.27.216.55 echo "✅ SSH key works!" 2>/dev/null; then
    echo "✅ This key works! Use it for DEPLOY_KEY secret."
else
    echo "❌ This key doesn't work with the server."
fi
EOF

chmod +x test-ssh-key.sh

echo -e "${GREEN}Created test-ssh-key.sh to test your keys${NC}"
echo "Usage: ./test-ssh-key.sh ~/.ssh/your_key"
echo ""