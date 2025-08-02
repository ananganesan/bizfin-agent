#!/bin/bash

# Quick SSH setup for 37.27.216.55
echo "🔐 Quick SSH Setup for Hetzner Server"

# Ensure SSH directory exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Check if you already have a private key that matches
echo "Checking for existing ed25519 keys..."

if [ -f ~/.ssh/id_ed25519 ]; then
    echo "Found existing ed25519 key. Testing if it matches..."
    
    # Add to known_hosts to avoid prompt
    ssh-keyscan -H 37.27.216.55 >> ~/.ssh/known_hosts 2>/dev/null
    
    # Try to connect
    echo "Testing connection..."
    if ssh -o BatchMode=yes -o ConnectTimeout=5 root@37.27.216.55 echo "Connected successfully" 2>/dev/null; then
        echo "✅ Connection successful! You can already access the server."
        echo ""
        echo "🚀 Deploy your app now:"
        echo "ssh root@37.27.216.55"
        exit 0
    else
        echo "❌ This key doesn't work for the server"
    fi
fi

echo ""
echo "📋 To set up SSH access, you need the PRIVATE key file."
echo "The public key you shared was: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY89Z0XiaslNFoZS60ig6EI0sfl4jAFz2u9efBRwy+I"
echo ""
echo "Do you have the private key file? (It might be named: id_ed25519, hetzner_key, etc.)"
echo "Common locations:"
echo "  - ~/Downloads/"
echo "  - ~/.ssh/"
echo "  - Your email attachments"
echo "  - Hetzner Cloud Console"
echo ""

read -p "Enter the full path to your private key file (or 'skip' to see alternatives): " KEYFILE

if [ "$KEYFILE" != "skip" ] && [ -f "$KEYFILE" ]; then
    # Copy the key
    cp "$KEYFILE" ~/.ssh/hetzner_server_key
    chmod 600 ~/.ssh/hetzner_server_key
    
    # Test connection
    echo "Testing connection..."
    if ssh -i ~/.ssh/hetzner_server_key -o BatchMode=yes -o ConnectTimeout=5 root@37.27.216.55 echo "Connected!" 2>/dev/null; then
        echo "✅ Success! Key is working."
        
        # Add SSH config for easy access
        cat >> ~/.ssh/config << EOF

Host hetzner
    HostName 37.27.216.55
    User root
    IdentityFile ~/.ssh/hetzner_server_key
EOF
        
        echo ""
        echo "🎉 SSH configured successfully!"
        echo ""
        echo "🚀 You can now connect with: ssh hetzner"
        echo "🚀 Or: ssh root@37.27.216.55"
    else
        echo "❌ Key didn't work. The server might expect a different key."
    fi
else
    echo ""
    echo "🔧 Alternative Options:"
    echo ""
    echo "1. Check Hetzner Cloud Console:"
    echo "   - Login to console.hetzner.cloud"
    echo "   - Go to your server"
    echo "   - Use the console to access the server"
    echo "   - Add your local public key:"
    echo "     echo 'ssh-ed25519 YOUR_KEY_HERE' >> ~/.ssh/authorized_keys"
    echo ""
    echo "2. Find the private key:"
    echo "   - Check your email for 'Hetzner server access'"
    echo "   - Look in ~/Downloads for key files"
    echo "   - Check if someone else set up the server"
    echo ""
    echo "3. Reset root password:"
    echo "   - In Hetzner Console, reset root password"
    echo "   - Use console to login with new password"
    echo "   - Add your SSH key"
fi

echo ""
echo "Once you have SSH access, deployment is simple:"
echo "1. ssh root@37.27.216.55"
echo "2. cd /var/www && git clone [repo] bizfin-agent"
echo "3. cd bizfin-agent && ./deploy-to-hetzner.sh"