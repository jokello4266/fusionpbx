from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app import models, schemas
from app.services.storage_service import storage_service
from app.services.ocr_service import ocr_service
from pathlib import Path

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

@router.post("/bill-analyses/upload", response_model=schemas.BillAnalysisResponse)
async def upload_and_analyze_bill(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Upload a bill image and automatically extract information using OCR."""
    # Validate file
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Save the uploaded file
    try:
        photo_path = await storage_service.save_file(file, subfolder="bills")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save file: {str(e)}")
    
    # Get full path for OCR processing
    full_path = storage_service.get_file_path(photo_path)
    
    # Extract information using OCR
    extracted_info = await ocr_service.extract_bill_info(full_path)
    
    # Create bill analysis with extracted data
    db_bill = models.BillAnalysis(
        period_start=extracted_info['period_start'],
        period_end=extracted_info['period_end'],
        usage=extracted_info['usage'],
        amount=extracted_info['amount'],
        photo_path=photo_path,
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


