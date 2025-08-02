# New App Launch Workflow

## Overview
This document provides a step-by-step workflow to launch a new app on the texra.in infrastructure. All configuration is centralized in one file for easy customization.

**🚨 IMPORTANT: ALL DEPLOYMENT MUST GO THROUGH GITHUB**
- No direct server deployment scripts
- No manual file transfers to server  
- All changes deployed via GitHub Actions only
- This ensures consistency, version control, and rollback capability

## Quick Start (5 minutes)

### Step 1: Copy Configuration Template
Copy the `app-config.json` template and customize it:

```bash
cp docs/templates/app-config.json my-new-app-config.json
```

Edit the variables in `my-new-app-config.json` - this is the ONLY file you need to change.

### Step 2: Generate App Structure
Run the generator script:

```bash
./scripts/generate-new-app.sh my-new-app-config.json
```

### Step 3: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: Use `APP_NAME` from your config
3. Description: Use `APP_DESCRIPTION` from your config
4. Create repository (public/private as needed)

### Step 4: Deploy
```bash
cd generated-apps/{APP_NAME}
git remote add origin https://github.com/{USERNAME}/{APP_NAME}.git
git push -u origin main
```

The GitHub Actions will auto-deploy to `{APP_SUBDOMAIN}.texra.in`

## Manual Steps Required

### 1. GitHub Repository Creation
- **Why manual**: GitHub API requires tokens with org permissions
- **Time**: 30 seconds
- **Frequency**: Once per app

### 2. Add GitHub Secret
- Go to repo Settings → Secrets and variables → Actions
- Add secret: `SERVER_SSH_KEY`
- Value: Copy from command below

```bash
cat ~/.ssh/hetzner_key
```

### 3. Server Configuration (Auto-handled by deployment)
The first deployment automatically:
- Creates app directory on server
- Updates nginx configuration
- Starts PM2 process
- Configures SSL

## Configuration File Structure

All customization happens in ONE file: `app-config.json`

```json
{
  "APP_NAME": "my-awesome-app",
  "APP_DESCRIPTION": "A cool new application",
  "APP_SUBDOMAIN": "awesome",
  "APP_PORT": 3001,
  "APP_TYPE": "node",
  "FEATURES": {
    "authentication": true,
    "database": "sqlite",
    "ai_integration": true
  },
  "GITHUB": {
    "username": "your-github-username",
    "repository": "my-awesome-app"
  },
  "DOMAIN": {
    "base": "texra.in",
    "full_url": "https://awesome.texra.in"
  }
}
```

## Claude Integration

### Prompt Template for Claude
Copy this prompt when asking Claude to implement your app:

```
I have a complete infrastructure setup and want you to implement a new app. 

Configuration file: [paste contents of your app-config.json]

Infrastructure details:
- Server: Hetzner Cloud (37.27.216.55)  
- Domain: texra.in with wildcard SSL
- Auto-deployment: GitHub Actions → PM2 + Nginx
- Available: Port {APP_PORT}, subdomain {APP_SUBDOMAIN}.texra.in

Please implement the app based on the configuration file. All infrastructure setup is automated - just focus on the application code.

App requirements:
[describe your specific app requirements here]
```

## Generated File Structure

When you run the generator, it creates:

```
generated-apps/{APP_NAME}/
├── .github/workflows/deploy.yml    # Auto-deployment
├── .env.example                    # Environment template  
├── .gitignore                     # Git ignore rules
├── server.js                      # Main application file
├── package.json                   # Dependencies
├── public/                        # Static files
├── README.md                      # App documentation
└── config/
    ├── app-config.json           # Your configuration
    └── nginx.conf                # Nginx config for server
```

## Port Assignment

Ports are auto-assigned in sequence:

| Port | Status | Subdomain | App Name |
|------|--------|-----------|----------|
| 3000 | Used   | pa.texra.in | Personal Assistant |
| 3001 | Available | app2.texra.in | - |
| 3002 | Available | app3.texra.in | - |
| 3003 | Available | app4.texra.in | - |

The generator automatically assigns the next available port.

## Troubleshooting

### Deployment Fails
1. Check GitHub Actions logs
2. Verify `SERVER_SSH_KEY` secret is added
3. Ensure port isn't already in use

### App Won't Start  
1. Check PM2 logs: `ssh hetzner "pm2 logs {APP_NAME}"`
2. Verify environment variables
3. Check application dependencies

### Domain Not Accessible
1. Wait 2-3 minutes for nginx reload
2. Check SSL certificate includes subdomain
3. Verify DNS propagation

## Next Steps After This Document

1. Create the configuration template file
2. Create the generator script  
3. Create GitHub Actions workflow template
4. Test the complete workflow

This workflow reduces new app deployment from hours to minutes with zero server configuration needed.