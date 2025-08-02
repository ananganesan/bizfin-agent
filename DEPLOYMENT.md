# Deployment Guide

## Quick Deploy to Texra.in Infrastructure

### 1. Prerequisites
- GitHub repository with your code
- Anthropic API key
- Access to texra.in server

### 2. GitHub Secrets Setup
Add these secrets to your GitHub repository (Settings → Secrets):

```
ANTHROPIC_API_KEY=your_claude_api_key_here
JWT_SECRET=your_strong_jwt_secret_here
HOST=your_server_ip
USERNAME=your_server_username
DEPLOY_KEY=your_ssh_private_key
PORT=22
```

### 3. Manual Deployment
On your server, run:

```bash
# Clone the repository
git clone https://github.com/yourusername/bizfin-agent.git
cd bizfin-agent

# Run deployment script
./deploy.sh
```

### 4. Automatic Deployment
Push to `main` branch - GitHub Actions will automatically deploy.

### 5. Post-Deployment

**Your app will be available at:**
- `https://bizfin.texra.in`

**Monitor with:**
```bash
pm2 status          # Check app status
pm2 logs bizfin-agent  # View logs
pm2 restart bizfin-agent  # Restart if needed
```

### 6. Demo Users
- **Junior Staff**: `junior_user` / `junior123`
- **Intermediate Staff**: `intermediate_user` / `junior123`
- **Department Head**: `department_head` / `junior123`

### 7. Features
- ✅ File upload (Excel, CSV, PDF)
- ✅ AI-powered financial analysis
- ✅ Role-based access control
- ✅ Real-time chat interface
- ✅ Report generation
- ✅ Production-ready deployment

### 8. Troubleshooting

**App not starting:**
```bash
pm2 logs bizfin-agent
```

**Nginx issues:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

**SSL issues:**
```bash
sudo certbot renew
```

### 9. Configuration Files
- `app-config.json` - App configuration
- `deploy/nginx.conf` - Nginx configuration
- `.github/workflows/deploy.yml` - CI/CD pipeline
- `backend/.env.production` - Production environment variables