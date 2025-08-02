# GitHub Auto-Deployment Setup Guide

## Overview
This guide explains how to set up automatic deployment from GitHub to your Hetzner server for any new app.

## Prerequisites
- GitHub account
- App code in a GitHub repository
- Server SSH access

## Step 1: Create GitHub Repository
1. Go to https://github.com/new
2. Create repository (public or private)
3. Push your app code to the repository

## Step 2: Add Server SSH Key to GitHub Secrets
1. Get the server SSH private key:
   ```bash
   cat ~/.ssh/hetzner_key
   ```
2. Copy the ENTIRE output (including BEGIN/END lines)
3. Go to your GitHub repository
4. Settings → Secrets and variables → Actions
5. Click "New repository secret"
6. Name: `SERVER_SSH_KEY`
7. Value: Paste the SSH key
8. Click "Add secret"

## Step 3: Create GitHub Actions Workflow
Create `.github/workflows/deploy.yml` in your repository:

```yaml
name: Deploy to Server

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: 37.27.216.55
        username: root
        key: ${{ secrets.SERVER_SSH_KEY }}
        script: |
          cd /apps/YOUR_APP_NAME
          # Remove existing git directory to start fresh
          rm -rf .git
          
          # Clone the repository directly
          cd /apps
          rm -rf YOUR_APP_NAME-temp
          git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git YOUR_APP_NAME-temp
          
          # Copy files to the app directory
          rsync -av --delete --exclude='.git' --exclude='node_modules' YOUR_APP_NAME-temp/ YOUR_APP_NAME/
          
          # Clean up temp directory
          rm -rf YOUR_APP_NAME-temp
          
          # Install dependencies and restart
          cd YOUR_APP_NAME
          npm install --production
          pm2 restart YOUR_APP_NAME --update-env
```

## Step 4: Configure Server for New App

### Create App Directory
```bash
ssh hetzner
mkdir -p /apps/YOUR_APP_NAME
cd /apps/YOUR_APP_NAME
```

### Update Nginx Configuration
Add to `/etc/nginx/sites-available/texra`:
```nginx
# YOUR_APP_NAME subdomain
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name YOUR_APP_NAME.texra.in;
    
    ssl_certificate /etc/letsencrypt/live/texra.in/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/texra.in/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    location / {
        proxy_pass http://localhost:YOUR_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Reload Nginx
```bash
nginx -t && nginx -s reload
```

## Step 5: Start Your App
```bash
cd /apps/YOUR_APP_NAME
pm2 start server.js --name YOUR_APP_NAME
pm2 save
```

## Step 6: Test Deployment
1. Make a small change to your code
2. Commit and push to GitHub
3. Check GitHub Actions tab for deployment status
4. Visit https://YOUR_APP_NAME.texra.in

## Port Assignment
- Use the next available port (3001, 3002, etc.)
- Update YOUR_PORT in nginx config
- Ensure your app listens on the correct port

## Troubleshooting
- Check GitHub Actions logs for deployment errors
- Check PM2 logs: `pm2 logs YOUR_APP_NAME`
- Verify nginx config: `nginx -t`
- Check SSL certificate includes your subdomain