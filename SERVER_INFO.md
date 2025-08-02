# Server Information & Infrastructure

## Server Details
- **Provider**: Hetzner Cloud
- **Location**: Helsinki, Finland
- **Server IP**: 37.27.216.55
- **Instance Type**: 4GB RAM server (€3.79/month)
- **OS**: Ubuntu 24.04.2 LTS
- **Domain**: texra.in (purchased from Hostinger)

## DNS Configuration
- **DNS Provider**: Hostinger
- **Root Domain**: texra.in → 37.27.216.55
- **Wildcard**: *.texra.in → 37.27.216.55
- **TTL**: 60 seconds

### Available Subdomains
- pa.texra.in (Personal Assistant - current app)
- app2.texra.in (available)
- app3.texra.in (available)
- pcs.texra.in (available)

## Server Access
```bash
# SSH Access
ssh -i ~/.ssh/hetzner_key root@37.27.216.55

# Or using SSH config alias
ssh hetzner
```

## Directory Structure
```
/apps/
├── pa/              # Personal Assistant app (port 3000)
├── app2/            # Available for next app (port 3001)
├── app3/            # Available for next app (port 3002)
├── nginx/           # Nginx configuration files
└── deploy-app.sh    # Generic deployment script
```

## Services Running
- **Web Server**: Nginx (reverse proxy)
- **Process Manager**: PM2 (Node.js apps)
- **SSL**: Let's Encrypt certificates (auto-renewal)
- **Database**: None currently (SQLite files in app directories)

## SSL Configuration
- **Provider**: Let's Encrypt
- **Auto-renewal**: Configured via cron job
- **Renewal command**: `/root/ssl-renew.sh`
- **Cron schedule**: Every 15 days at 3 AM

## Port Allocation
- 3000: Personal Assistant (pa.texra.in)
- 3001: Available for next app
- 3002: Available for next app
- 3003: Available for next app
- etc.

## Key Files Locations
- SSH Keys: `~/.ssh/hetzner_key`
- Nginx Config: `/etc/nginx/sites-available/texra`
- SSL Certificates: `/etc/letsencrypt/live/texra.in/`
- PM2 Process List: `pm2 list`