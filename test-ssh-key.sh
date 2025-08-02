#!/bin/bash
# Test if your SSH key works with the server

echo "Testing SSH connection to 37.27.216.55..."

if [ -z "$1" ]; then
    echo "Usage: ./test-ssh-key.sh /path/to/private_key"
    echo "Example: ./test-ssh-key.sh ~/.ssh/id_ed25519"
    exit 1
fi

if ssh -i "$1" -o BatchMode=yes -o ConnectTimeout=5 root@37.27.216.55 echo "✅ SSH key works!" 2>/dev/null; then
    echo "✅ This key works! Use it for DEPLOY_KEY secret."
else
    echo "❌ This key doesn't work with the server."
fi
