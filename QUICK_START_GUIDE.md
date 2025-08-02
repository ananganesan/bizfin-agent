# Quick Start Guide: Deploy New Apps in 5 Minutes

**texra.in Infrastructure - Automated App Deployment**

---

## Overview

This guide shows you how to create and deploy a new application on your texra.in infrastructure in under 5 minutes. All apps get automatic HTTPS, subdomain routing, and GitHub Actions deployment.

**Key Benefits:**
- ⚡ 5-minute deployment from idea to live app
- 🔒 Automatic HTTPS with Let's Encrypt
- 🚀 GitHub Actions CI/CD
- 📱 Mobile-responsive by default
- 🎯 Single config file controls everything

---

## Prerequisites

✅ **Before you start, ensure you have:**
- GitHub account
- SSH key for server in `~/.ssh/hetzner_key`
- texra.in infrastructure running (Hetzner server + DNS)

---

## 🚀 Step-by-Step Process

### Step 1: Configure Your App (2 minutes)

**1.1 Copy the configuration template:**
```bash
cd /home/aga/Projects/my-pa
cp docs/templates/app-config.json my-new-app-config.json
```

**1.2 Edit the configuration file:**
Open `my-new-app-config.json` and customize these values:

```json
{
  "APP_NAME": "your-app-name",
  "APP_DESCRIPTION": "Brief description of your app",
  "APP_SUBDOMAIN": "subdomain",
  "APP_PORT": 3001,
  "GITHUB": {
    "username": "your-github-username", 
    "repository": "your-app-name"
  }
}
```

**Port Assignment:**
- 3000: Personal Assistant (used)
- 3001: Available 
- 3002: Available
- 3003: Available

### Step 2: Generate App Structure (30 seconds)

**2.1 Run the generator:**
```bash
./scripts/generate-new-app.sh my-new-app-config.json
```

**2.2 What gets created:**
```
generated-apps/your-app-name/
├── .github/workflows/deploy.yml    # Auto-deployment
├── server.js                       # Basic Node.js server
├── package.json                    # Dependencies
├── public/index.html              # Web interface
├── .env.example                   # Environment template
├── README.md                      # Documentation
└── app-config.json               # Your configuration
```

### Step 3: Create GitHub Repository (30 seconds)

**3.1 Create repository:**
1. Go to https://github.com/new
2. Repository name: Use your `APP_NAME` from config
3. Description: Use your `APP_DESCRIPTION` from config  
4. Choose public or private
5. Click "Create repository"

**3.2 Don't initialize with README** (generator already created files)

### Step 4: Add GitHub Secret (30 seconds)

**4.1 Get the SSH key:**
```bash
cat ~/.ssh/hetzner_key
```
Copy the entire output (including BEGIN/END lines)

**4.2 Add to GitHub:**
1. Go to your repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `SERVER_SSH_KEY`
5. Value: Paste the SSH key
6. Click "Add secret"

### Step 5: Deploy (1 minute)

**5.1 Connect and push to GitHub:**
```bash
cd generated-apps/your-app-name
git remote add origin https://github.com/username/repository.git
git push -u origin main
```

**5.2 Monitor deployment:**
- Go to your GitHub repository
- Click "Actions" tab
- Watch the deployment process
- Takes ~2-3 minutes to complete

### Step 6: Verify Deployment (30 seconds)

**6.1 Check your app:**
- Visit: `https://your-subdomain.texra.in`
- Health check: `https://your-subdomain.texra.in/health`

**6.2 If something's wrong:**
- Check GitHub Actions logs
- Verify SSH key was added correctly
- Ensure port isn't already in use

---

## 🎯 Complete Example Walkthrough

Let's create a URL shortener app called "short":

### Configuration:
```json
{
  "APP_NAME": "url-shortener",
  "APP_DESCRIPTION": "A URL shortening service with analytics",
  "APP_SUBDOMAIN": "short", 
  "APP_PORT": 3001,
  "GITHUB": {
    "username": "johndoe",
    "repository": "url-shortener"
  }
}
```

### Commands:
```bash
# 1. Configure
cp docs/templates/app-config.json url-shortener-config.json
# Edit url-shortener-config.json with above values

# 2. Generate
./scripts/generate-new-app.sh url-shortener-config.json

# 3. Create GitHub repo: github.com/johndoe/url-shortener
# 4. Add SERVER_SSH_KEY secret

# 5. Deploy
cd generated-apps/url-shortener
git remote add origin https://github.com/johndoe/url-shortener.git
git push -u origin main
```

### Result:
✅ **Live app at: https://short.texra.in**

---

## 🔧 Advanced: Implementing Features with Claude

After your basic app is deployed, you can use Claude to add features:

### Get the Claude Prompt:
```bash
cd generated-apps/your-app-name
cat docs/templates/claude-prompt.md
```

### Customize and use with Claude:
1. Copy the prompt template
2. Paste your `app-config.json` contents
3. Describe your feature requirements
4. Ask Claude to implement
5. Push changes to GitHub for auto-deployment

---

## 📋 Port and Subdomain Reference

| Port | Subdomain | Status | App |
|------|-----------|--------|-----|
| 3000 | pa.texra.in | Used | Personal Assistant |
| 3001 | app2.texra.in | Available | - |
| 3002 | app3.texra.in | Available | - |
| 3003 | app4.texra.in | Available | - |

Use the next available port for new apps.

---

## 🚨 Important Rules

### ✅ DO:
- Always use GitHub for deployment
- Edit only the config file for new apps
- Use the generator script for consistency
- Monitor GitHub Actions for deployment status

### ❌ DON'T:
- Deploy directly to server (SSH)
- Skip version control
- Manually edit server configs
- Use ports already in use

---

## 🛠️ Troubleshooting

### Deployment Fails:
1. Check GitHub Actions logs in your repository
2. Verify `SERVER_SSH_KEY` secret is correct
3. Ensure port isn't already used: `ssh hetzner "netstat -tulpn | grep :3001"`

### App Won't Start:
1. Check PM2 logs: `ssh hetzner "pm2 logs your-app-name"`
2. Verify environment variables in `.env`
3. Check dependencies installed correctly

### Can't Access Domain:
1. Wait 2-3 minutes for nginx reload
2. Check DNS: `nslookup your-subdomain.texra.in`
3. Verify SSL certificate covers subdomain

### Get Help:
- Check logs: `ssh hetzner "pm2 logs && nginx -t"`
- Server status: `ssh hetzner "pm2 list && systemctl status nginx"`

---

## 📚 Additional Resources

- **Full Documentation**: `docs/NEW_APP_LAUNCH_WORKFLOW.md`
- **Server Info**: `docs/SERVER_INFO.md`
- **GitHub Setup**: `docs/GITHUB_DEPLOYMENT.md`
- **All Keys/Secrets**: `docs/KEYS_AND_SECRETS.md`

---

**🎉 You're now ready to deploy apps in minutes!**

*This infrastructure setup allows you to go from idea to live application faster than most developers can set up their local environment.*