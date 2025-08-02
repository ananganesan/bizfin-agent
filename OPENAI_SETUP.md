# 🔄 OpenAI Setup - Changed from Claude to GPT-4!

## ✅ What's Changed
- **AI Engine**: Now using OpenAI GPT-4 instead of Claude
- **API Key**: Changed from `ANTHROPIC_API_KEY` to `OPENAI_API_KEY`
- **Model**: Using `gpt-4-turbo-preview` for best performance

## 🔑 Get Your OpenAI API Key

1. Go to: https://platform.openai.com/api-keys
2. Sign up or login
3. Create new API key
4. Copy the key (starts with `sk-`)

## 📋 Update These Places:

### 1. Local Development
Edit `backend/.env`:
```
OPENAI_API_KEY=sk-your-actual-openai-key-here
```

### 2. Production Server
After deployment, edit `/var/www/bizfin-agent/backend/.env`:
```
OPENAI_API_KEY=sk-your-actual-openai-key-here
```

### 3. GitHub Actions CI/CD
Go to: https://github.com/ananganesan/bizfin-agent/settings/secrets/actions

Update/Add secret:
```
Name: OPENAI_API_KEY
Value: sk-your-actual-openai-key-here
```

## 💰 OpenAI Pricing
- GPT-4 Turbo: ~$0.01 per 1K input tokens, $0.03 per 1K output tokens
- Each financial analysis: ~$0.05-0.10
- Reports: ~$0.20-0.40

## 🚀 Deploy Command (Same as Before)
```bash
ssh root@37.27.216.55 "cd /var/www/bizfin-agent && git pull && pm2 restart bizfin-agent"
```

Or for fresh deployment:
```bash
ssh root@37.27.216.55 "git clone https://github.com/ananganesan/bizfin-agent.git /var/www/bizfin-agent && cd /var/www/bizfin-agent && ./deploy-to-hetzner.sh"
```

## 🧪 Test the AI
After adding your OpenAI key:
1. Login as any demo user
2. Upload `sample-data.csv`
3. Ask: "What are the key financial insights?"
4. You should get GPT-4 powered analysis!

## 🎯 Benefits of GPT-4
- ✅ Widely available API
- ✅ Great financial analysis capabilities
- ✅ Fast response times
- ✅ Reliable uptime
- ✅ Extensive documentation

Your Finance Advisory Agent now runs on OpenAI GPT-4! 🎉