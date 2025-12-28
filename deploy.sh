#!/bin/bash

set -e

echo "🚀 Deploying FlowSense..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# Database
DATABASE_URL=postgresql://flowsense:flowsense@postgres:5432/flowsense

# Backend
API_BASE_URL=http://143.198.227.148/api

# Security (change these in production!)
POSTGRES_PASSWORD=flowsense
POSTGRES_USER=flowsense
POSTGRES_DB=flowsense
EOF
    echo "✅ Created .env file. Please review and update with your values."
fi

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose pull

# Build backend image
echo "🔨 Building backend image..."
docker-compose build backend

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Start services
echo "▶️  Starting services..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 10

# Run migrations
echo "🔄 Running database migrations..."
docker-compose exec -T backend alembic upgrade head

# Check service health
echo "🏥 Checking service health..."
sleep 5

if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Health check passed!"
else
    echo "⚠️  Health check failed. Services may still be starting..."
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Service Status:"
docker-compose ps
echo ""
echo "🌐 API available at: http://143.198.227.148/api"
echo "🏥 Health check: http://143.198.227.148/health"
echo ""
echo "📝 View logs with: docker-compose logs -f"
echo "🛑 Stop services with: docker-compose down"


