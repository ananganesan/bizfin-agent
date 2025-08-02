# 🤖 OpenAI API Setup Required

## ⚠️ Critical: Production OpenAI API Key Missing

The analysis functionality is currently failing because the OpenAI API key is not configured in production.

## 🔧 Fix Required:

### 1. Get OpenAI API Key
1. Go to [OpenAI API Keys](https://platform.openai.com/api-keys)
2. Create a new API key
3. Copy the key (starts with `sk-`)

### 2. Update Production Environment
On your server, update the environment file:

```bash
# SSH to your server
ssh root@49.207.59.52

# Edit the production environment file
nano /var/www/bizfin-agent/backend/.env.production

# Replace this line:
OPENAI_API_KEY=your_production_openai_api_key_here

# With your actual key:
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

### 3. Restart the Application
```bash
# Restart the backend to load new environment variables
pm2 restart bizfin-backend

# Check if it's running properly
pm2 status
pm2 logs bizfin-backend
```

## 🔄 Alternative: Update via GitHub Secrets (Recommended)

1. Go to your GitHub repository: https://github.com/ananganesan/bizfin-agent
2. Go to Settings → Secrets and variables → Actions
3. Add a new secret:
   - Name: `OPENAI_API_KEY`
   - Value: Your OpenAI API key (sk-...)
4. Push any change to trigger auto-deployment

## ✅ Verification

Test the fix by:
1. Visit https://bizfin.texra.in
2. Login with demo credentials
3. Upload a CSV file
4. Ask a question about the data

## 🎯 Current Error:
- **Status**: 500 Internal Server Error
- **Endpoint**: `/api/analysis/query`
- **Cause**: Missing or invalid OpenAI API key
- **Solution**: Set valid OPENAI_API_KEY in production environment

## 💰 OpenAI API Costs
- Using `gpt-4o-mini` model (cost-effective)
- Estimated cost: ~$0.01-0.10 per analysis query
- Monitor usage at [OpenAI Usage Dashboard](https://platform.openai.com/usage)