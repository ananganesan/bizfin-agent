# 🚀 GitHub Repository Setup

## Quick Setup

### Option 1: Using GitHub CLI (Recommended)
```bash
./create-github-repo.sh
```

### Option 2: Manual Setup

1. **Create Repository on GitHub:**
   - Go to https://github.com/new
   - Repository name: `bizfin-agent`
   - Description: `Business Finance Advisory Agent - AI-powered financial analysis`
   - Choose Public or Private
   - **DON'T** initialize with README
   - Click "Create repository"

2. **Push Your Code:**
```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/bizfin-agent.git

# Push code
git branch -M main
git push -u origin main
```

## After GitHub Setup

### Deploy Using Git Clone

Once your code is on GitHub, deployment is super easy:

```bash
# SSH to server
ssh root@37.27.216.55

# Clone and deploy (one line)
git clone https://github.com/YOUR_USERNAME/bizfin-agent.git /var/www/bizfin-agent && \
cd /var/www/bizfin-agent && \
chmod +x deploy-to-hetzner.sh && \
./deploy-to-hetzner.sh
```

### Or Even Simpler (from your local machine):
```bash
# Deploy in one command from local
ssh root@37.27.216.55 "git clone https://github.com/YOUR_USERNAME/bizfin-agent /var/www/bizfin-agent && cd /var/www/bizfin-agent && ./deploy-to-hetzner.sh"
```

## GitHub Actions (Optional - Automated Deployment)

To enable push-to-deploy:

1. Go to your repo settings: `https://github.com/YOUR_USERNAME/bizfin-agent/settings/secrets/actions`

2. Add these secrets:
   - `HOST`: 37.27.216.55
   - `USERNAME`: root
   - `DEPLOY_KEY`: (your SSH private key content)
   - `ANTHROPIC_API_KEY`: (your Claude API key)
   - `JWT_SECRET`: (generate random string)
   - `PORT`: 22

3. The `.github/workflows/deploy.yml` is already set up!

4. Any push to main branch will auto-deploy

## What You Have

Your bizfin-agent repository includes:
- ✅ Complete backend API (Node.js + Express)
- ✅ Frontend interface (HTML/CSS/JS)
- ✅ Claude AI integration
- ✅ Role-based access control
- ✅ File upload handling
- ✅ Deployment scripts
- ✅ Nginx configurations
- ✅ GitHub Actions workflow
- ✅ Documentation

## Next Steps

1. Create GitHub repo
2. Push code
3. SSH to server and run the clone/deploy command
4. Your Finance Advisory Agent will be live at https://bizfin.texra.in!