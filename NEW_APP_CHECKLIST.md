# New App Development Checklist

## Pre-Development Setup

### 1. Planning Phase
- [ ] Define app requirements and features
- [ ] Choose technology stack (Node.js, Python, etc.)
- [ ] Decide on subdomain: `{app-name}.texra.in`
- [ ] Assign port number (next available: 3001, 3002, etc.)

### 2. Local Development Setup
- [ ] Create new project directory
- [ ] Initialize git repository: `git init`
- [ ] Create initial project structure
- [ ] Set up development environment

## Development Phase

### 3. Core Development
- [ ] Build core application features
- [ ] Add authentication (if needed)
- [ ] Implement error handling
- [ ] Add logging
- [ ] Create health check endpoint (`/health`)

### 4. Environment Configuration
- [ ] Create `.env.example` file
- [ ] Create `.env` file with actual values
- [ ] Add `.env` to `.gitignore`
- [ ] Use environment variables for all configuration

### 5. Production Readiness
- [ ] Add cache headers (if web app)
- [ ] Implement proper error pages
- [ ] Add security headers
- [ ] Optimize for production

## Deployment Setup

### 6. GitHub Repository
- [ ] Create GitHub repository
- [ ] Push code to repository
- [ ] Create `.github/workflows/deploy.yml`
- [ ] Add `SERVER_SSH_KEY` secret to repository

### 7. Server Configuration
- [ ] Create app directory: `/apps/{app-name}`
- [ ] Update Nginx configuration for subdomain
- [ ] Test Nginx configuration: `nginx -t`
- [ ] Reload Nginx: `nginx -s reload`

### 8. SSL and Domain
- [ ] Add subdomain to SSL certificate (if new)
- [ ] Test SSL: `curl -I https://{app-name}.texra.in`
- [ ] Verify domain resolution

### 9. Application Deployment
- [ ] Deploy via GitHub Actions
- [ ] Start app with PM2: `pm2 start server.js --name {app-name}`
- [ ] Save PM2 configuration: `pm2 save`
- [ ] Test application: `curl http://localhost:{port}/health`

## Testing and Verification

### 10. Functionality Testing
- [ ] Test all core features
- [ ] Test error scenarios
- [ ] Test authentication (if implemented)
- [ ] Test API endpoints

### 11. Performance Testing
- [ ] Test load times
- [ ] Test mobile responsiveness
- [ ] Test caching behavior
- [ ] Monitor resource usage

### 12. Security Testing
- [ ] Test HTTPS redirect
- [ ] Verify no sensitive data in logs
- [ ] Test authentication security
- [ ] Check for exposed endpoints

## Monitoring and Maintenance

### 13. Monitoring Setup
- [ ] Monitor PM2 logs: `pm2 logs {app-name}`
- [ ] Set up error tracking (if needed)
- [ ] Monitor server resources
- [ ] Test auto-deployment

### 14. Documentation
- [ ] Update README.md
- [ ] Document API endpoints
- [ ] Document deployment process
- [ ] Document troubleshooting steps

## Quick Commands Reference

### Development
```bash
# Start local development
npm run dev

# Test locally
npm test

# Build for production
npm run build
```

### Deployment
```bash
# Deploy to server
git add .
git commit -m "Deploy changes"
git push

# Check deployment status
# Visit: https://github.com/{username}/{repo}/actions
```

### Server Management
```bash
# SSH to server
ssh hetzner

# Check app status
pm2 list
pm2 logs {app-name}

# Restart app
pm2 restart {app-name}

# Check nginx
nginx -t
systemctl status nginx
```

### Troubleshooting
```bash
# Check if port is in use
netstat -tulpn | grep :{port}

# Check nginx logs
tail -f /var/log/nginx/error.log

# Check SSL certificate
openssl s_client -connect {subdomain}.texra.in:443

# Test internal connectivity
curl http://localhost:{port}/health
```

## Port Assignment Guide

| Port | App Name | Subdomain | Status |
|------|----------|-----------|---------|
| 3000 | Personal Assistant | pa.texra.in | Used |
| 3001 | Available | app2.texra.in | Available |
| 3002 | Available | app3.texra.in | Available |
| 3003 | Available | app4.texra.in | Available |

## Common Issues and Solutions

### Deployment Fails
1. Check GitHub Actions logs
2. Verify SSH key is correct
3. Check server disk space
4. Verify repository access

### App Won't Start
1. Check PM2 logs: `pm2 logs {app-name}`
2. Verify environment variables
3. Check port availability
4. Verify dependencies installed

### Can't Access via Domain
1. Check nginx configuration
2. Verify DNS resolution: `nslookup {subdomain}.texra.in`
3. Check SSL certificate includes subdomain
4. Verify app is running on correct port