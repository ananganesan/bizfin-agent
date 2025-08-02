#!/bin/bash

# Setup SSH access for Hetzner server
echo "🔐 Setting up SSH access to 37.27.216.55"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# The public key you provided
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY89Z0XiaslNFoZS60ig6EI0sfl4jAFz2u9efBRwy+I"

echo -e "${YELLOW}⚠️  IMPORTANT: This script assumes you have the PRIVATE KEY${NC}"
echo -e "${YELLOW}The public key you shared is: ${NC}"
echo "$PUBLIC_KEY"
echo ""

echo -e "${BLUE}Choose what to do:${NC}"
echo "1. I have the private key file"
echo "2. I need to generate a new key pair"
echo "3. Just show me how to connect"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo -e "${GREEN}Setting up with existing private key...${NC}"
        echo ""
        echo "Please provide the path to your private key file:"
        echo "Example: /path/to/id_ed25519 or ~/Downloads/hetzner_key"
        read -p "Private key path: " KEY_PATH
        
        if [ -f "$KEY_PATH" ]; then
            # Copy key to SSH directory
            cp "$KEY_PATH" ~/.ssh/hetzner_key
            chmod 600 ~/.ssh/hetzner_key
            
            # Add to SSH config
            echo -e "${GREEN}Adding to SSH config...${NC}"
            cat >> ~/.ssh/config << EOF

# Hetzner server for bizfin.texra.in
Host hetzner-bizfin
    HostName 37.27.216.55
    User root
    IdentityFile ~/.ssh/hetzner_key
    StrictHostKeyChecking no
EOF
            
            echo -e "${GREEN}✅ SSH key configured!${NC}"
            echo ""
            echo -e "${GREEN}You can now connect using:${NC}"
            echo "ssh hetzner-bizfin"
            echo ""
            echo -e "${GREEN}Or directly:${NC}"
            echo "ssh -i ~/.ssh/hetzner_key root@37.27.216.55"
        else
            echo -e "${RED}❌ File not found: $KEY_PATH${NC}"
        fi
        ;;
        
    2)
        echo -e "${GREEN}Generating new SSH key pair...${NC}"
        ssh-keygen -t ed25519 -f ~/.ssh/hetzner_bizfin_key -N ""
        
        echo ""
        echo -e "${YELLOW}⚠️  IMPORTANT: Add this public key to your server:${NC}"
        cat ~/.ssh/hetzner_bizfin_key.pub
        echo ""
        echo -e "${YELLOW}Steps to add the key to server:${NC}"
        echo "1. Access server via console (Hetzner Cloud Console)"
        echo "2. Run: echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys"
        echo ""
        
        # Add to SSH config
        cat >> ~/.ssh/config << EOF

# Hetzner server for bizfin.texra.in
Host hetzner-bizfin
    HostName 37.27.216.55
    User root
    IdentityFile ~/.ssh/hetzner_bizfin_key
    StrictHostKeyChecking no
EOF
        
        echo -e "${GREEN}✅ New key generated!${NC}"
        echo "Connect with: ssh hetzner-bizfin"
        ;;
        
    3)
        echo -e "${BLUE}SSH Connection Instructions:${NC}"
        echo ""
        echo "If you have the private key file, use:"
        echo "ssh -i /path/to/private_key root@37.27.216.55"
        echo ""
        echo "Common private key locations:"
        echo "- ~/.ssh/id_ed25519"
        echo "- ~/.ssh/id_rsa"
        echo "- ~/Downloads/hetzner_key"
        echo ""
        echo "The public key suggests this is an ed25519 key"
        ;;
esac

echo ""
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    QUICK DEPLOYMENT AFTER SSH SETUP${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""
echo -e "${GREEN}Once you can SSH to the server, run:${NC}"
echo ""
echo "# Connect to server"
echo "ssh hetzner-bizfin  # or ssh root@37.27.216.55"
echo ""
echo "# Deploy the app"
echo "cd /var/www"
echo "git clone [your-repo-url] bizfin-agent"
echo "cd bizfin-agent"
echo "./deploy-to-hetzner.sh"
echo ""
echo -e "${YELLOW}📋 Or copy files from local:${NC}"
echo "rsync -avz --exclude 'node_modules' . root@37.27.216.55:/var/www/bizfin-agent/"
echo ""