# Claude Prompt for New App Implementation

## Copy this prompt and customize it when asking Claude to implement your app:

---

I have a complete infrastructure setup with auto-deployment and want you to implement a new app. Here's my configuration:

**App Configuration:**
```json
[PASTE YOUR app-config.json CONTENTS HERE]
```

**Infrastructure Details:**
- **Server**: Hetzner Cloud (37.27.216.55)
- **Domain**: texra.in with wildcard SSL certificate
- **Auto-deployment**: GitHub Actions → PM2 + Nginx  
- **App URL**: Will be available at the subdomain specified in config
- **Port**: As specified in APP_PORT
- **Process Manager**: PM2 (automatically configured)

**What's Already Set Up:**
- ✅ Server infrastructure and SSL
- ✅ GitHub Actions deployment workflow
- ✅ Nginx reverse proxy configuration
- ✅ PM2 process management
- ✅ Environment variable handling

**What I Need You To Do:**
Please implement the application code based on my configuration. Focus ONLY on the application logic - all infrastructure is automated.

**App Requirements:**
[DESCRIBE YOUR SPECIFIC APP REQUIREMENTS HERE]

Examples:
- "Build a simple task manager with add/edit/delete functionality"
- "Create a URL shortener with custom codes and click tracking"  
- "Make a note-taking app with markdown support and search"
- "Build a file upload service with link sharing"

**Technical Preferences:**
- Framework: Node.js with Express (or specify other)
- Database: As specified in config (sqlite/none/postgresql)
- Authentication: As specified in config features
- AI Integration: As specified in config features
- UI: Simple, responsive, mobile-friendly

**File Structure to Generate:**
```
project-root/
├── server.js              # Main application file
├── package.json           # Dependencies  
├── .env.example           # Environment template
├── .gitignore            # Git ignore
├── public/               # Static files (HTML, CSS, JS)
├── README.md             # App documentation
└── .github/workflows/deploy.yml  # Auto-deployment (use template)
```

**Requirements:**
1. Health check endpoint at `/health`
2. Error handling and logging
3. Production-ready configuration
4. Mobile-responsive UI
5. Use environment variables from config

**What I'll Do Manually:**
1. Create GitHub repository
2. Add SERVER_SSH_KEY secret to GitHub
3. Push your generated code
4. Verify deployment works

**Deployment Process:**
After you generate the code, I will:
1. `git add . && git commit -m "Initial app implementation"`
2. `git push origin main`
3. GitHub Actions automatically deploys to server
4. App becomes available at the configured URL

Please generate a complete, working application that I can immediately deploy using this infrastructure.

---

## Usage Instructions:

1. **Copy this template**
2. **Replace the placeholders:**
   - Paste your `app-config.json` contents
   - Describe your specific app requirements
   - Specify any technical preferences
3. **Provide to Claude**
4. **Deploy the generated code**

## Example Filled Template:

```
I have a complete infrastructure setup with auto-deployment and want you to implement a new app. Here's my configuration:

**App Configuration:**
```json
{
  "APP_NAME": "url-shortener",
  "APP_DESCRIPTION": "A URL shortening service with analytics",
  "APP_SUBDOMAIN": "short",
  "APP_PORT": 3001,
  "FEATURES": {
    "authentication": false,
    "database": "sqlite",
    "ai_integration": false
  },
  "DOMAIN": {
    "base": "texra.in",
    "full_url": "https://short.texra.in"
  }
}
```

**App Requirements:**
Build a URL shortener similar to bit.ly with these features:
- Submit long URLs and get short codes
- Custom short codes (optional)
- Click tracking and basic analytics
- Simple web interface
- API endpoints for programmatic access
- View stats for each shortened URL

Please generate a complete, working application that I can immediately deploy.
```