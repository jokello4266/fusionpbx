from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter()

@router.post("/bill-analyses", response_model=schemas.BillAnalysisResponse)
async def create_bill_analysis(
    bill_analysis: schemas.BillAnalysisCreate,
    db: Session = Depends(get_db)
):
    """Create a new bill analysis."""
    db_bill = models.BillAnalysis(
        period_start=bill_analysis.period_start,
        period_end=bill_analysis.period_end,
        usage=bill_analysis.usage,
        amount=bill_analysis.amount,
        photo_path=bill_analysis.photo_path,
    )
    
    db.add(db_bill)
    db.commit()
    db.refresh(db_bill)
    
    return db_bill

@router.get("/bill-analyses", response_model=List[schemas.BillAnalysisResponse])
async def get_bill_analyses(
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get bill analysis history."""
    bills = db.query(models.BillAnalysis).order_by(models.BillAnalysis.created_at.desc()).limit(limit).all()
    return bills

@router.get("/bill-analyses/{bill_id}", response_model=schemas.BillAnalysisResponse)
async def get_bill_analysis(
    bill_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific bill analysis by ID."""
    bill = db.query(models.BillAnalysis).filter(models.BillAnalysis.id == bill_id).first()
    if not bill:
        raise HTTPException(status_code=404, detail="Bill analysis not found")
    return bill


