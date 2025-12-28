from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter()

def calculate_confidence(delta: float, no_water_used: bool, duration_minutes: int) -> str:
    """Calculate confidence level based on delta and conditions."""
    if not no_water_used:
        return "Low"
    
    # Normalize delta per minute
    delta_per_minute = delta / duration_minutes if duration_minutes > 0 else delta
    
    if delta_per_minute > 1.0:
        return "Very High"
    elif delta_per_minute > 0.5:
        return "High"
    elif delta_per_minute > 0.1:
        return "Medium"
    else:
        return "Low"

@router.post("/leak-checks", response_model=schemas.LeakCheckResponse)
async def create_leak_check(
    leak_check: schemas.LeakCheckCreate,
    db: Session = Depends(get_db)
):
    """Create a new leak check and calculate results."""
    delta = abs(leak_check.reading_b - leak_check.reading_a)
    leak_detected = delta > 0.01 and leak_check.no_water_used  # Threshold: 0.01 gallons
    confidence = calculate_confidence(delta, leak_check.no_water_used, leak_check.duration_minutes)
    
    db_leak_check = models.LeakCheck(
        reading_a=leak_check.reading_a,
        reading_b=leak_check.reading_b,
        no_water_used=leak_check.no_water_used,
        delta=delta,
        leak_detected=leak_detected,
        confidence=confidence,
        photo_path_a=leak_check.photo_path_a,
        photo_path_b=leak_check.photo_path_b,
        duration_minutes=leak_check.duration_minutes,
    )
    
    db.add(db_leak_check)
    db.commit()
    db.refresh(db_leak_check)
    
    return db_leak_check

@router.get("/leak-checks", response_model=List[schemas.LeakCheckResponse])
async def get_leak_checks(
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get leak check history."""
    leak_checks = db.query(models.LeakCheck).order_by(models.LeakCheck.created_at.desc()).limit(limit).all()
    return leak_checks

@router.get("/leak-checks/{leak_check_id}", response_model=schemas.LeakCheckResponse)
async def get_leak_check(
    leak_check_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific leak check by ID."""
    leak_check = db.query(models.LeakCheck).filter(models.LeakCheck.id == leak_check_id).first()
    if not leak_check:
        raise HTTPException(status_code=404, detail="Leak check not found")
    return leak_check


