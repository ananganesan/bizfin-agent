# 🚀 DEPLOY NOW - One Command!

## ✅ Your Code is on GitHub!
Repository: https://github.com/ananganesan/bizfin-agent

## 🎯 Deploy to Server 37.27.216.55

### Option 1: Copy & Paste This Single Command
```bash
ssh root@37.27.216.55 "git clone https://github.com/ananganesan/bizfin-agent.git /var/www/bizfin-agent && cd /var/www/bizfin-agent && chmod +x deploy-to-hetzner.sh && ./deploy-to-hetzner.sh"
```

### Option 2: Step by Step
```bash
# 1. SSH to server
ssh root@37.27.216.55

# 2. Clone repository
git clone https://github.com/ananganesan/bizfin-agent.git /var/www/bizfin-agent

# 3. Navigate to directory
cd /var/www/bizfin-agent

# 4. Run deployment
./deploy-to-hetzner.sh
```

## 📋 What Will Happen:
1. ✅ Installs Node.js, PM2, Nginx
2. ✅ Installs all dependencies
3. ✅ Starts the application
4. ✅ Configures nginx for bizfin.texra.in
5. ✅ Sets up SSL certificate
6. ✅ Your app will be live!

## 🔑 Important After Deployment:
1. **Add your Anthropic API key**: Edit `/var/www/bizfin-agent/backend/.env`
2. **Test the app**: Visit https://bizfin.texra.in
3. **Login with demo users**

## 🆘 If You Can't SSH:
1. Check your SSH key: `./ssh-quicksetup.sh`
2. Or use Hetzner console to add your SSH key
3. Or reset root password in Hetzner panel

## 🎉 Success Indicators:
- ✅ https://bizfin.texra.in shows login page
- ✅ No redirect to texra.in
- ✅ Demo users can login
- ✅ Chat interface works

Your Finance Advisory Agent is ready to deploy! Just run the command above! 🚀