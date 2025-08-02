#!/bin/bash

echo "Starting Business Finance Advisory Agent..."

# Check if .env file exists in backend
if [ ! -f backend/.env ]; then
    echo "Warning: backend/.env file not found. Please create it with your Anthropic API key."
    echo "Example content:"
    echo "PORT=3001"
    echo "NODE_ENV=development"
    echo "ANTHROPIC_API_KEY=your_claude_api_key_here"
    echo "JWT_SECRET=your_jwt_secret_here"
    echo "UPLOAD_DIR=./uploads"
    echo "MAX_FILE_SIZE=10485760"
    echo "CORS_ORIGIN=http://localhost:3000"
fi

# Create uploads directory if it doesn't exist
mkdir -p backend/uploads

# Start backend
echo "Starting backend server..."
cd backend
node server.js &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend
echo "Starting frontend server..."
cd ../frontend
node server.js &
FRONTEND_PID=$!

echo ""
echo "✅ Application started successfully!"
echo ""
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:3001"
echo ""
echo "📋 Demo Users:"
echo "   Junior Staff: junior_user / junior123"
echo "   Intermediate Staff: intermediate_user / junior123"
echo "   Department Head: department_head / junior123"
echo ""
echo "Press Ctrl+C to stop both servers"

# Function to cleanup background processes
cleanup() {
    echo ""
    echo "Stopping servers..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

# Wait for both processes
wait