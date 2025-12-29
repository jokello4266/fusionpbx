"""Status calculation endpoint."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from app.database import get_db
from app import models

router = APIRouter()

@router.get("/status")
async def get_status(db: Session = Depends(get_db)):
    """Calculate current guardian status based on recent activity.
    
    Returns:
        Status object with:
        - status: "normal", "warning", or "confirmed"
        - message: Human-readable status message
        - last_check: Last leak check timestamp
        - recent_leaks: Count of recent leak detections
    """
    # Get recent leak checks (last 30 days)
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)
    recent_leak_checks = db.query(models.LeakCheck).filter(
        models.LeakCheck.created_at >= thirty_days_ago
    ).order_by(models.LeakCheck.created_at.desc()).all()
    
    # Count confirmed leaks
    confirmed_leaks = [lc for lc in recent_leak_checks if lc.leak_detected and lc.confidence in ["High", "Very High"]]
    
    # Get most recent leak check
    last_check = recent_leak_checks[0] if recent_leak_checks else None
    
    # Determine status
    if confirmed_leaks:
        # Check if there's a very recent confirmed leak (last 7 days)
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        recent_confirmed = [lc for lc in confirmed_leaks if lc.created_at >= seven_days_ago]
        
        if recent_confirmed:
            status = "confirmed"
            message = "Leak detected"
        else:
            status = "warning"
            message = "Something might need attention"
    else:
        # Check for unusual patterns in bills
        recent_bills = db.query(models.BillAnalysis).filter(
            models.BillAnalysis.created_at >= thirty_days_ago
        ).order_by(models.BillAnalysis.created_at.desc()).limit(3).all()
        
        if len(recent_bills) >= 2:
            # Check for significant usage increase
            usage_trend = [b.usage for b in recent_bills]
            if len(usage_trend) >= 2 and usage_trend[0] > usage_trend[-1] * 1.5:
                status = "warning"
                message = "Water use looks unusual"
            else:
                status = "normal"
                message = "Everything looks okay"
        else:
            status = "normal"
            message = "Everything looks okay"
    
    return {
        "status": status,
        "message": message,
        "last_check": last_check.created_at.isoformat() if last_check else None,
        "recent_leaks": len(confirmed_leaks),
        "total_checks_30d": len(recent_leak_checks),
    }

