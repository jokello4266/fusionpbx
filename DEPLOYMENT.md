# FlowSense Deployment Guide

Complete deployment instructions for DigitalOcean droplet.

## Prerequisites

- DigitalOcean droplet at IP: 143.198.227.148
- SSH access to the droplet
- Docker and Docker Compose installed on the droplet

## Step 1: Prepare the Droplet

SSH into your droplet:
```bash
ssh root@143.198.227.148
```

Install Docker (if not already installed):
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

Install Docker Compose:
```bash
apt-get update
apt-get install -y docker-compose-plugin
# Or for standalone:
# curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
```

## Step 2: Upload Project Files

Option A: Clone from Git
```bash
cd /opt
git clone <your-repo-url> flowsense
cd flowsense
```

Option B: Upload via SCP
```bash
# From your local machine:
scp -r . root@143.198.227.148:/opt/flowsense
```

## Step 3: Configure Environment

Create `.env` file:
```bash
cd /opt/flowsense
nano .env
```

Add:
```env
DATABASE_URL=postgresql://flowsense:flowsense@postgres:5432/flowsense
POSTGRES_PASSWORD=flowsense
POSTGRES_USER=flowsense
POSTGRES_DB=flowsense
API_BASE_URL=http://143.198.227.148/api
```

**⚠️ IMPORTANT**: Change default passwords in production!

## Step 4: Deploy

Make deploy script executable:
```bash
chmod +x deploy.sh
```

Run deployment:
```bash
./deploy.sh
```

The script will:
1. Pull latest images
2. Build backend
3. Start all services
4. Run database migrations
5. Check health

## Step 5: Verify Deployment

Check service status:
```bash
docker-compose ps
```

Test health endpoint:
```bash
curl http://localhost/health
```

Test API:
```bash
curl http://localhost/api/health
```

## Step 6: Configure Firewall

Allow HTTP/HTTPS traffic:
```bash
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

## Step 7: Flutter App Configuration

### Development
The Flutter app defaults to `http://143.198.227.148/api`

### Production Build
```bash
cd flowsense-flutter
flutter build apk --dart-define=API_BASE_URL=http://143.198.227.148/api
```

## Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose logs -f

# Check specific service
docker-compose logs backend
docker-compose logs postgres
docker-compose logs nginx
```

### Database connection issues
```bash
# Test database connection
docker-compose exec postgres psql -U flowsense -d flowsense -c "SELECT 1;"
```

### Nginx not routing
```bash
# Test config
docker-compose exec nginx nginx -t

# Reload
docker-compose exec nginx nginx -s reload
```

### Port conflicts
If ports 80, 443, or 5432 are in use:
1. Edit `docker-compose.yml`
2. Change port mappings
3. Update Nginx config if needed

## SSL/HTTPS Setup (Optional)

1. Install Certbot:
```bash
apt-get install certbot python3-certbot-nginx
```

2. Get certificate:
```bash
certbot certonly --standalone -d your-domain.com
```

3. Update `nginx/conf.d/flowsense.conf` with SSL settings

4. Restart Nginx:
```bash
docker-compose restart nginx
```

## Monitoring

View logs:
```bash
docker-compose logs -f --tail=100
```

Check resource usage:
```bash
docker stats
```

## Backup

Backup database:
```bash
docker-compose exec postgres pg_dump -U flowsense flowsense > backup_$(date +%Y%m%d).sql
```

Restore database:
```bash
docker-compose exec -T postgres psql -U flowsense flowsense < backup_20240101.sql
```

## Updates

To update the application:
```bash
cd /opt/flowsense
git pull  # if using git
./deploy.sh
```

## Rollback

Stop services:
```bash
docker-compose down
```

Restore previous version and redeploy.


