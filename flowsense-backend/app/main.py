from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, leak_checks, bill_analyses, plumbers, upload, status
from app.database import engine, Base

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="FlowSense API",
    description="Water monitoring and leak detection API",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/api", tags=["health"])
app.include_router(leak_checks.router, prefix="/api", tags=["leak-checks"])
app.include_router(bill_analyses.router, prefix="/api", tags=["bill-analyses"])
app.include_router(plumbers.router, prefix="/api", tags=["plumbers"])
app.include_router(upload.router, prefix="/api", tags=["upload"])
app.include_router(status.router, prefix="/api", tags=["status"])

@app.get("/")
async def root():
    return {"message": "FlowSense API", "version": "1.0.0"}


