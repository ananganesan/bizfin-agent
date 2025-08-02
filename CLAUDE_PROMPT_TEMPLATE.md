# Claude Prompt Template for New Apps

## Copy this prompt when starting a new app with Claude

---

# New App Development on Existing Server Infrastructure

I have an existing server setup and want you to help me build a new application. Here's my infrastructure:

## Server Information
- **Server**: Hetzner Cloud (37.27.216.55)
- **Domain**: texra.in with wildcard DNS (*.texra.in)
- **OS**: Ubuntu 24.04.2 LTS
- **Web Server**: Nginx with SSL (Let's Encrypt)
- **Process Manager**: PM2 for Node.js apps
- **Directory Structure**: `/apps/{app-name}/`

## Current Apps
- Personal Assistant: pa.texra.in (port 3000) - Already deployed

## Available Resources
- **Next Available Port**: 3001
- **Next Available Subdomain**: app2.texra.in (or custom name)
- **Auto-deployment**: GitHub Actions → Server

## Keys and Access
- SSH Key for server: `~/.ssh/hetzner_key`
- OpenAI API Key: Available (if needed for AI features)
- GitHub repository: **YOU will create this manually**
- GitHub Secrets: **YOU will add SERVER_SSH_KEY manually**

## What I Need Help With
**[DESCRIBE YOUR NEW APP REQUIREMENTS HERE]**

Example:
"I want to build a [type of app] that [main functionality]. The app should [list key features]. I want it to be accessible at [subdomain].texra.in."

## Technical Preferences
- **Framework**: [Node.js/Python/etc.]
- **Database**: [SQLite/PostgreSQL/None]
- **Authentication**: [Yes/No - if yes, simple login/password]
- **AI Integration**: [Yes/No - if yes, what kind]
- **Mobile Support**: [Yes/No]

## Deployment Requirements
- Auto-deployment via GitHub Actions when I push to main branch
- HTTPS with existing SSL certificate
- PM2 process management
- Nginx reverse proxy configuration

## Please Help Me:
1. Design the application architecture
2. Set up the project structure
3. Implement the core functionality
4. Create GitHub Actions workflow files
5. Provide step-by-step deployment instructions

## What I Will Do Manually:
1. Create GitHub repository
2. Add SERVER_SSH_KEY secret to repository
3. Push the code you generate
4. Verify deployment works

---

## Additional Context Files

When working with Claude, also provide these context files if relevant:

### For Authentication Reference
```bash
# If you need authentication similar to the PA app
cat /home/aga/Projects/my-pa/server.js | grep -A 20 "authentication"
```

### For Deployment Reference
```bash
# Show the working deployment configuration
cat /home/aga/Projects/my-pa/.github/workflows/deploy.yml
```

### For Nginx Reference
```bash
# Show current nginx configuration
ssh hetzner 'cat /etc/nginx/sites-available/texra'
```

## Example Problem Statements

### Example 1: Task Tracker
"I want to build a simple task tracking app that allows teams to create, assign, and track tasks. The app should have user authentication, real-time updates, and be accessible at tasks.texra.in."

### Example 2: File Sharing
"I need a secure file sharing application where users can upload files, share them with links, and set expiration dates. It should have password protection and be accessible at files.texra.in."

### Example 3: Note Taking
"I want to create a note-taking app with markdown support, tagging, and search functionality. Users should be able to organize notes in folders and access them at notes.texra.in."

### Example 4: URL Shortener
"I need a URL shortening service similar to bit.ly, with custom short codes, click tracking, and analytics. It should be accessible at short.texra.in."

## What Claude Will Do

When you provide this prompt, Claude will:
1. ✅ Understand your existing infrastructure
2. ✅ Design the new application
3. ✅ Set up proper project structure
4. ✅ Configure auto-deployment
5. ✅ Set up subdomain routing
6. ✅ Implement all requested features
7. ✅ Test and deploy the application

## Files to Have Ready

Before starting, have these documentation files available:
- `docs/SERVER_INFO.md` - Server details
- `docs/GITHUB_DEPLOYMENT.md` - Deployment guide
- `docs/KEYS_AND_SECRETS.md` - All keys and credentials
- `docs/NEW_APP_CHECKLIST.md` - Development checklist

This ensures Claude has all the context needed to build and deploy your new app efficiently!