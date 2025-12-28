from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class LeakCheckCreate(BaseModel):
    reading_a: float
    reading_b: float
    no_water_used: bool
    duration_minutes: int = 10
    photo_path_a: Optional[str] = None
    photo_path_b: Optional[str] = None

class LeakCheckResponse(BaseModel):
    id: int
    reading_a: float
    reading_b: float
    no_water_used: bool
    delta: float
    leak_detected: bool
    confidence: str
    photo_path_a: Optional[str] = None
    photo_path_b: Optional[str] = None
    duration_minutes: int
    created_at: datetime

    class Config:
        from_attributes = True

class BillAnalysisCreate(BaseModel):
    period_start: datetime
    period_end: datetime
    usage: float
    amount: float
    photo_path: Optional[str] = None

class BillAnalysisResponse(BaseModel):
    id: int
    period_start: datetime
    period_end: datetime
    usage: float
    amount: float
    photo_path: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

class PlumberResponse(BaseModel):
    name: str
    rating: float
    distance: float
    phone: str
    address: str


