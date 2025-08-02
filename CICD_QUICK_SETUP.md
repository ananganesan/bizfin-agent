# 🚀 CI/CD Quick Setup - 5 Minutes!

## ✅ GitHub Actions is Ready!
Your workflow is already configured in `.github/workflows/deploy.yml`

## 📋 Add These 6 Secrets to GitHub:

### Go to: https://github.com/ananganesan/bizfin-agent/settings/secrets/actions

Click "New repository secret" for each:

### 1️⃣ **HOST**
```
Name: HOST
Value: 37.27.216.55
```

### 2️⃣ **USERNAME**
```
Name: USERNAME
Value: root
```

### 3️⃣ **PORT**
```
Name: PORT
Value: 22
```

### 4️⃣ **JWT_SECRET**
```
Name: JWT_SECRET
Value: (generate with: openssl rand -base64 32)
```

### 5️⃣ **OPENAI_API_KEY**
```
Name: OPENAI_API_KEY
Value: [Your OpenAI API key]
```

### 6️⃣ **DEPLOY_KEY**
```
Name: DEPLOY_KEY
Value: [Your SSH private key - entire content]
```

## 🔑 Finding Your SSH Private Key:

```bash
# Common locations:
cat ~/.ssh/id_ed25519
cat ~/.ssh/id_rsa
cat ~/.ssh/hetzner_key
```

Copy the ENTIRE content including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
[all the key content]
-----END OPENSSH PRIVATE KEY-----
```

## 🧪 Test CI/CD:

After adding secrets:

```bash
echo "# Deployed with CI/CD" >> README.md
git add README.md
git commit -m "Test automated deployment"
git push
```

## 📊 Watch Deployment:
https://github.com/ananganesan/bizfin-agent/actions

## 🎯 Result:
Every push to main = Automatic deployment to https://bizfin.texra.in

No more manual SSH needed! 🎉