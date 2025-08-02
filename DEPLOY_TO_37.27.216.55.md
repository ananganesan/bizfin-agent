# 🚀 Deploy to Server 37.27.216.55 (Hetzner)

## Quick Deploy Instructions

### 1. **Transfer Files to Server**

From your local machine:
```bash
# Option A: Using Git (if you have a repository)
ssh user@37.27.216.55
git clone https://github.com/yourusername/bizfin-agent.git
cd bizfin-agent

# Option B: Direct file transfer (if no Git repo)
cd /home/aga/Projects/bizfin-agent
rsync -avz --exclude 'node_modules' --exclude '.git' . user@37.27.216.55:/var/www/bizfin-agent/
```

### 2. **SSH to the Server**
```bash
ssh user@37.27.216.55
```

### 3. **Run Deployment Script**
```bash
cd /var/www/bizfin-agent
./deploy-to-hetzner.sh
```

## Manual Steps if Script Fails

### Step 1: Install Dependencies
```bash
# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PM2
sudo npm install -g pm2

# Nginx & Certbot
sudo apt-get install -y nginx certbot python3-certbot-nginx
```

### Step 2: Setup Application
```bash
# Create directory
sudo mkdir -p /var/www/bizfin-agent
sudo chown -R $USER:$USER /var/www/bizfin-agent

# Navigate and install
cd /var/www/bizfin-agent
cd backend && npm install
cd ../frontend && npm install
```

### Step 3: Configure Environment
```bash
# Create .env file
cat > backend/.env << EOF
PORT=3005
NODE_ENV=production
ANTHROPIC_API_KEY=your_api_key_here
JWT_SECRET=your_jwt_secret_here
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
CORS_ORIGIN=https://bizfin.texra.in
EOF
```

### Step 4: Start Application
```bash
cd /var/www/bizfin-agent
pm2 start backend/server.js --name bizfin-agent
pm2 save
pm2 startup
```

### Step 5: Configure Nginx
```bash
# Create nginx config
sudo nano /etc/nginx/sites-available/bizfin.texra.in
# Paste the nginx configuration from the script

# Enable site
sudo ln -s /etc/nginx/sites-available/bizfin.texra.in /etc/nginx/sites-enabled/00-bizfin.texra.in
sudo nginx -t
sudo systemctl reload nginx
```

### Step 6: Setup SSL
```bash
sudo certbot --nginx -d bizfin.texra.in
```

## Verification Checklist

✅ **DNS**: `bizfin.texra.in` → `37.27.216.55`  
✅ **Port 3005**: `netstat -tlnp | grep :3005`  
✅ **PM2 Status**: `pm2 status`  
✅ **Nginx Test**: `sudo nginx -t`  
✅ **Health Check**: `curl http://localhost:3005/health`  
✅ **External Access**: Visit `https://bizfin.texra.in`  

## Troubleshooting

### If redirect still happens:
1. Check nginx site priority:
   ```bash
   ls -la /etc/nginx/sites-enabled/
   ```
   Make sure `00-bizfin.texra.in` loads before other configs

2. Check for wildcard configs:
   ```bash
   sudo grep -r "server_name.*\*.*texra" /etc/nginx/sites-enabled/
   ```

3. Check PM2 logs:
   ```bash
   pm2 logs bizfin-agent
   ```

4. Test direct access:
   ```bash
   curl -H "Host: bizfin.texra.in" http://localhost
   ```

## Important Notes

1. **Repository URL**: Update `REPO_URL` in the deployment script
2. **API Key**: Add your Anthropic API key to `backend/.env`
3. **File Transfer**: If using rsync, make sure to exclude node_modules
4. **SSL**: Let's Encrypt will auto-renew every 90 days

## Success Indicators

When deployment is successful:
- ✅ `https://bizfin.texra.in` shows login page
- ✅ No redirect to `texra.in`
- ✅ Demo users can login
- ✅ File upload works
- ✅ AI chat responds

The key is deploying to the **correct server** (37.27.216.55) where the DNS points!