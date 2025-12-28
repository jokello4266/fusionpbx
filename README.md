# FlowSense - Water Monitoring App

A production-ready water monitoring application with leak detection and bill analysis. Built with Flutter (frontend) and FastAPI (backend), deployed on DigitalOcean.

## 🏗️ Architecture

- **Frontend**: Flutter app with Material 3, Riverpod state management
- **Backend**: FastAPI with PostgreSQL, SQLAlchemy 2.x
- **Deployment**: Docker Compose with Nginx reverse proxy
- **Server**: DigitalOcean droplet at 143.198.227.148

## 📁 Project Structure

```
.
├── flowsense-flutter/      # Flutter mobile app
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── screens/      # UI screens
│   │   ├── services/     # API service
│   │   ├── providers/    # Riverpod providers
│   │   ├── router/       # Navigation
│   │   └── theme/        # App theme
│   └── pubspec.yaml
├── flowsense-backend/     # FastAPI backend
│   ├── app/
│   │   ├── main.py       # FastAPI app
│   │   ├── models.py     # SQLAlchemy models
│   │   ├── schemas.py    # Pydantic schemas
│   │   ├── database.py   # Database config
│   │   └── routers/      # API routes
│   ├── alembic/          # Database migrations
│   └── Dockerfile
├── nginx/                 # Nginx configuration
├── docker-compose.yml     # Docker Compose setup
├── deploy.sh              # Deployment script
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Flutter SDK (for mobile app development)
- Access to DigitalOcean droplet at 143.198.227.148

### Backend Deployment

1. **SSH into your DigitalOcean droplet:**
   ```bash
   ssh root@143.198.227.148
   ```

2. **Clone or upload the project:**
   ```bash
   git clone <your-repo-url> flowsense
   cd flowsense
   ```

3. **Make deploy script executable:**
   ```bash
   chmod +x deploy.sh
   ```

4. **Run deployment:**
   ```bash
   ./deploy.sh
   ```

5. **Verify deployment:**
   ```bash
   curl http://143.198.227.148/health
   ```

### Flutter App Setup

1. **Navigate to Flutter project:**
   ```bash
   cd flowsense-flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters:**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Configure API base URL (optional):**
   - Default: `http://143.198.227.148/api`
   - Override via environment variable: `API_BASE_URL`
   - Or change in Settings screen (read-only display)

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Database
DATABASE_URL=postgresql://flowsense:flowsense@postgres:5432/flowsense
POSTGRES_PASSWORD=flowsense
POSTGRES_USER=flowsense
POSTGRES_DB=flowsense

# Backend
API_BASE_URL=http://143.198.227.148/api
```

**⚠️ Security Note**: Change default passwords in production!

### Flutter App Configuration

The Flutter app uses environment variables or compile-time constants:

- **Development**: Uses default `http://143.198.227.148/api`
- **Production**: Set via `--dart-define=API_BASE_URL=https://your-domain.com/api`

## 📱 App Features

### Screens

1. **Home** - Guardian status dashboard
2. **Upload** - Bill photo/document upload
3. **Leak Check** - 5-step leak detection wizard
4. **History** - Timeline of bills and leak checks
5. **Settings** - Demo mode, privacy, backend config

### Leak Check Flow

1. **Prep**: Checklist (taps off, appliances paused, irrigation off)
2. **Reading A**: Photo or manual entry
3. **Timer**: 10 minutes (2 minutes in demo mode)
4. **Reading B**: Photo or manual entry
5. **Result**: Leak detection with confidence level

## 🔌 API Endpoints

Base URL: `http://143.198.227.148/api`

### Health
- `GET /health` - Health check

### Leak Checks
- `POST /leak-checks` - Create leak check
- `GET /leak-checks?limit=50` - Get leak check history
- `GET /leak-checks/{id}` - Get specific leak check

### Bill Analyses
- `POST /bill-analyses` - Create bill analysis
- `GET /bill-analyses?limit=50` - Get bill history
- `GET /bill-analyses/{id}` - Get specific bill

### Plumbers
- `GET /plumbers?latitude={lat}&longitude={lon}` - Find nearby plumbers

## 🐳 Docker Services

- **postgres**: PostgreSQL 15 database
- **backend**: FastAPI application
- **nginx**: Reverse proxy and load balancer

### Useful Commands

```bash
# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build
```

## 🔒 Security Considerations

1. **Change default passwords** in `.env`
2. **Use HTTPS** - Configure SSL certificates in `nginx/conf.d/flowsense.conf`
3. **Restrict CORS** - Update allowed origins in `app/main.py`
4. **Database backups** - Set up regular PostgreSQL backups
5. **Firewall** - Configure UFW or similar on the droplet

## 📊 Database Migrations

Migrations are handled by Alembic:

```bash
# Create new migration
docker-compose exec backend alembic revision --autogenerate -m "description"

# Apply migrations
docker-compose exec backend alembic upgrade head

# Rollback
docker-compose exec backend alembic downgrade -1
```

## 🎨 UI Theme

**Calming Ocean** color palette:
- Background: `#F6FAFA`
- Card: `#FFFFFF`
- Primary: `#3BA6A6`
- Success: `#4CAF93`
- Warning: `#F3C98B`
- Danger: `#E46A6A`
- Text Primary: `#1F2D2D`
- Text Secondary: `#5F7373`

## 🐛 Troubleshooting

### Backend not starting
```bash
# Check logs
docker-compose logs backend

# Check database connection
docker-compose exec backend python -c "from app.database import engine; engine.connect()"
```

### Database connection issues
```bash
# Verify PostgreSQL is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres
```

### Nginx not routing correctly
```bash
# Test Nginx config
docker-compose exec nginx nginx -t

# Reload Nginx
docker-compose exec nginx nginx -s reload
```

### Flutter app can't connect
- Verify backend is accessible: `curl http://143.198.227.148/api/health`
- Check CORS settings in `app/main.py`
- Verify API base URL in app settings

## 📝 Development

### Backend Development

```bash
# Install dependencies
cd flowsense-backend
pip install -r requirements.txt

# Run locally (requires local PostgreSQL)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Flutter Development

```bash
# Run in debug mode
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## 🚢 Production Deployment

1. **Set up SSL certificate** (Let's Encrypt recommended)
2. **Update Nginx config** with SSL settings
3. **Change all default passwords**
4. **Set up database backups**
5. **Configure firewall rules**
6. **Set up monitoring** (optional)

## 📄 License

This project is proprietary. All rights reserved.

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs: `docker-compose logs -f`
3. Verify service status: `docker-compose ps`

---

**Made with ❤️ for water conservation**
