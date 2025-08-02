# Keys, Secrets, and Configuration

## SSH Keys

### Hetzner Server SSH Key
**Location**: `~/.ssh/hetzner_key`
**Usage**: Server access from local machine
```bash
# To view private key (for GitHub Secrets)
cat ~/.ssh/hetzner_key

# To view public key (for adding to other services)
cat ~/.ssh/hetzner_key.pub
```

### Personal SSH Key
**Location**: `~/.ssh/id_ed25519`
**Usage**: GitHub authentication from local machine
```bash
# Public key for GitHub
cat ~/.ssh/id_ed25519.pub
```

## Environment Variables Template

### Copy this template for new apps
Create `.env` file in your app directory:
```env
# OpenAI API Configuration
OPENAI_API_KEY=YOUR_OPENAI_API_KEY_HERE

# Authentication (if needed)
SESSION_SECRET=your-super-secret-session-key-change-this-in-production
AUTH_USERNAME=admin
AUTH_PASSWORD=yourSecurePassword123

# Database (if needed)
DATABASE_URL=sqlite:./database.sqlite

# App Configuration
NODE_ENV=production
PORT=3001
```

## GitHub Secrets Required

### For Each Repository
Add these secrets in GitHub repository settings:

1. **SERVER_SSH_KEY**
   - Value: Content of `~/.ssh/hetzner_key`
   - Usage: Auto-deployment to server

2. **OPENAI_API_KEY** (if using AI)
   - Value: Your OpenAI API key
   - Usage: GPT integration

## API Keys and External Services

### OpenAI API Key
- **Service**: OpenAI Platform
- **Usage**: GPT-4, GPT-3.5, embeddings, etc.
- **Current Key**: [STORED IN SERVER .env FILE - NOT IN THIS DOCUMENT]
- **Where to get**: https://platform.openai.com/api-keys

### GitHub Personal Access Token
- **Usage**: Repository access for local git operations
- **Where to get**: https://github.com/settings/tokens/new
- **Scopes needed**: repo, workflow

### Domain and DNS
- **Domain**: texra.in
- **Provider**: Hostinger
- **DNS Management**: Hostinger DNS panel
- **Nameservers**: Hostinger's nameservers

## Server Credentials

### Hetzner Cloud
- **Username**: ananganesan
- **Server IP**: 37.27.216.55
- **SSH Access**: Key-based authentication only

### SSL Certificates
- **Provider**: Let's Encrypt
- **Email**: admin@texra.in
- **Auto-renewal**: Configured
- **Certificate location**: `/etc/letsencrypt/live/texra.in/`

## Database Credentials (if needed)

### SQLite (recommended for simple apps)
```env
DATABASE_URL=sqlite:./database.sqlite
```

### PostgreSQL (if needed)
```env
DATABASE_URL=postgresql://username:password@localhost:5432/dbname
```

## Security Notes

1. **Never commit secrets to Git**
2. **Use environment variables for all sensitive data**
3. **Rotate API keys regularly**
4. **Use strong passwords for authentication**
5. **Keep server packages updated**

## Quick Copy Commands

### For new app setup:
```bash
# Copy SSH key for GitHub Secrets
cat ~/.ssh/hetzner_key | pbcopy  # macOS
cat ~/.ssh/hetzner_key | xclip -selection clipboard  # Linux

# SSH to server
ssh hetzner

# Check PM2 processes
pm2 list

# Check nginx status
nginx -t
```