# Routing Fix for bizfin.texra.in

## Problem
The subdomain `bizfin.texra.in` is redirecting to the main `texra.in` domain instead of serving the Finance Advisory Agent.

## Solution

### Quick Fix
Run this on your server:
```bash
cd /var/www/bizfin-agent
./fix-routing.sh
```

### Manual Fix Steps

1. **Remove conflicting nginx configs:**
```bash
sudo rm -f /etc/nginx/sites-enabled/bizfin.texra.in
sudo rm -f /etc/nginx/sites-available/bizfin.texra.in
```

2. **Install priority nginx config:**
```bash
sudo cp deploy/nginx-priority.conf /etc/nginx/sites-available/bizfin.texra.in
sudo ln -sf /etc/nginx/sites-available/bizfin.texra.in /etc/nginx/sites-enabled/00-bizfin.texra.in
```

3. **Test and reload:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

4. **Ensure app is running:**
```bash
pm2 restart bizfin-agent
pm2 status
```

## Root Causes

### 1. Nginx Site Priority
- The main `texra.in` config might be catching all subdomains
- Using `00-` prefix ensures our config loads first

### 2. DNS/Subdomain Setup
- Check that `bizfin.texra.in` points to your server IP
- Verify A record: `bizfin.texra.in → your_server_ip`

### 3. Wildcard Configuration
- Main texra.in config might have `server_name *.texra.in`
- Our specific config should override this

## Verification

### Check nginx configuration order:
```bash
ls -la /etc/nginx/sites-enabled/
```

### Check if port 3005 is listening:
```bash
netstat -tlnp | grep :3005
```

### Check application logs:
```bash
pm2 logs bizfin-agent
```

### Test the domain:
```bash
curl -H "Host: bizfin.texra.in" localhost
```

## Expected Result
- `bizfin.texra.in` → Finance Advisory Agent
- `texra.in` → Main website (unchanged)

## If Still Not Working

1. **Check DNS propagation:**
   ```bash
   nslookup bizfin.texra.in
   ```

2. **Check for conflicting nginx configs:**
   ```bash
   grep -r "bizfin\|server_name.*texra.in" /etc/nginx/sites-enabled/
   ```

3. **Restart nginx completely:**
   ```bash
   sudo systemctl restart nginx
   ```

4. **Check Cloudflare/CDN settings** if using external DNS

## Contact
If the issue persists, provide the output of:
```bash
sudo nginx -T | grep -A 20 -B 5 "texra.in"
pm2 logs bizfin-agent --lines 50
netstat -tlnp | grep :3005
```