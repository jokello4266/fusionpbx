# FlowSense Backend API

FastAPI backend for water monitoring and leak detection.

## Local Development

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your database URL
   ```

3. **Run migrations:**
   ```bash
   alembic upgrade head
   ```

4. **Start server:**
   ```bash
   uvicorn app.main:app --reload
   ```

## API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Endpoints

- `GET /api/health` - Health check
- `POST /api/leak-checks` - Create leak check
- `GET /api/leak-checks` - List leak checks
- `POST /api/bill-analyses` - Create bill analysis
- `GET /api/bill-analyses` - List bill analyses
- `GET /api/plumbers` - Find nearby plumbers

## Database Migrations

```bash
# Create migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Docker

See main README.md for Docker Compose setup.


