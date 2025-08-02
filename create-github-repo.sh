#!/bin/bash

# Create GitHub repository and push code
echo "🚀 Creating GitHub Repository for bizfin-agent"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    GITHUB REPOSITORY SETUP${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    echo "node_modules/" > .gitignore
    echo "*.log" >> .gitignore
    echo ".env" >> .gitignore
    echo ".env.local" >> .gitignore
    echo "uploads/" >> .gitignore
    echo ".DS_Store" >> .gitignore
fi

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI (gh) not installed.${NC}"
    echo ""
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  Mac: brew install gh"
    echo ""
    echo "Or create repository manually at: https://github.com/new"
    echo ""
    
    # Manual instructions
    echo -e "${BLUE}Manual Setup Instructions:${NC}"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: bizfin-agent"
    echo "3. Description: Business Finance Advisory Agent - AI-powered financial analysis"
    echo "4. Make it Public or Private"
    echo "5. Don't initialize with README (we already have one)"
    echo "6. Create repository"
    echo ""
    echo "Then run these commands:"
    echo ""
    echo "git add ."
    echo "git commit -m 'Initial commit: Finance Advisory Agent'"
    echo "git branch -M main"
    echo "git remote add origin https://github.com/YOUR_USERNAME/bizfin-agent.git"
    echo "git push -u origin main"
    
else
    echo -e "${GREEN}GitHub CLI found!${NC}"
    echo ""
    
    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        echo -e "${YELLOW}Please authenticate with GitHub:${NC}"
        gh auth login
    fi
    
    # Create repository
    echo "Creating GitHub repository..."
    read -p "Make repository public? (y/n): " IS_PUBLIC
    
    VISIBILITY="private"
    if [ "$IS_PUBLIC" = "y" ]; then
        VISIBILITY="public"
    fi
    
    # Create repo
    if gh repo create bizfin-agent --$VISIBILITY --description "Business Finance Advisory Agent - AI-powered financial analysis" --source=. --push; then
        echo -e "${GREEN}✅ Repository created successfully!${NC}"
        REPO_URL=$(gh repo view --json url -q .url)
        echo "Repository URL: $REPO_URL"
    else
        echo -e "${RED}Repository creation failed. It might already exist.${NC}"
        read -p "Enter your GitHub username: " GITHUB_USER
        REPO_URL="https://github.com/$GITHUB_USER/bizfin-agent.git"
    fi
    
    # Add and commit files
    echo ""
    echo "Adding files to git..."
    git add .
    git commit -m "Initial commit: Business Finance Advisory Agent

- Role-based access (Junior/Intermediate/Department Head)
- AI-powered financial analysis with Claude
- File upload support (Excel, CSV, PDF)
- Real-time chat interface
- Report generation
- Production-ready deployment scripts"
    
    # Push to GitHub
    echo "Pushing to GitHub..."
    git branch -M main
    git remote add origin $REPO_URL 2>/dev/null || git remote set-url origin $REPO_URL
    git push -u origin main
    
    echo ""
    echo -e "${GREEN}✅ Code pushed to GitHub!${NC}"
    echo "Repository: $REPO_URL"
fi

echo ""
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    NEXT STEPS${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Update deployment script with repo URL
if [ ! -z "$REPO_URL" ]; then
    echo "Updating deployment script with repository URL..."
    sed -i "s|REPO_URL=\".*\"|REPO_URL=\"$REPO_URL\"|g" deploy-to-hetzner.sh 2>/dev/null || \
    sed -i '' "s|REPO_URL=\".*\"|REPO_URL=\"$REPO_URL\"|g" deploy-to-hetzner.sh 2>/dev/null
    echo -e "${GREEN}✅ Deployment script updated${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Repository is ready!${NC}"
echo ""
echo "Now you can deploy to your server:"
echo ""
echo -e "${YELLOW}Option 1: Direct deployment${NC}"
echo "ssh root@37.27.216.55"
echo "git clone $REPO_URL /var/www/bizfin-agent"
echo "cd /var/www/bizfin-agent"
echo "./deploy-to-hetzner.sh"
echo ""
echo -e "${YELLOW}Option 2: One-line deployment${NC}"
echo "ssh root@37.27.216.55 'git clone $REPO_URL /var/www/bizfin-agent && cd /var/www/bizfin-agent && ./deploy-to-hetzner.sh'"
echo ""
echo -e "${YELLOW}Option 3: GitHub Actions (automated)${NC}"
echo "1. Go to: $REPO_URL/settings/secrets/actions"
echo "2. Add secrets:"
echo "   - HOST: 37.27.216.55"
echo "   - USERNAME: root"
echo "   - DEPLOY_KEY: (your SSH private key content)"
echo "   - ANTHROPIC_API_KEY: (your Claude API key)"
echo "   - JWT_SECRET: (generate a random string)"
echo "3. Push any change to trigger deployment"
echo ""