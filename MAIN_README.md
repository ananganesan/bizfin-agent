# Personal Assistant App (my-pa)

A Progressive Web App (PWA) for task management with natural language processing.

🚀 Auto-deployed via GitHub Actions

## Features

- Natural language task management
- AI-powered chat interface (GPT-4.1-nano)
- Authentication system
- Task priorities and reminders
- Dark theme UI
- PWA with offline support

## Local Development

1. Clone the repository
```bash
git clone https://github.com/ananganesan/my-pa.git
cd my-pa
```

2. Install dependencies
```bash
npm install
```

3. Create `.env` file
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. Start the server
```bash
npm start
```

## Deployment

### Manual deployment
```bash
./deploy.sh
```

### Automatic deployment
Push to the `main` branch on GitHub to trigger automatic deployment.

## SSL Setup

On the server, run:
```bash
ssh hetzner
cd /apps/pa
./ssl-setup.sh
```

## Default Credentials

- Username: `admin`
- Password: `yourSecurePassword123`

Change these in the `.env` file:
```
AUTH_USERNAME=your-username
AUTH_PASSWORD=your-password
```

## Server Details

- Domain: https://texra.in
- Server: Hetzner Cloud (Helsinki)
- Process Manager: PM2
- Web Server: Nginx

## API Keys

You need:
- OpenAI API key for GPT-4.1-nano
- Session secret for authentication

Configure these in `.env` file.