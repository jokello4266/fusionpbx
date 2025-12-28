from sqlalchemy import Column, Integer, Float, Boolean, String, DateTime, Text
from sqlalchemy.sql import func
from app.database import Base

class LeakCheck(Base):
    __tablename__ = "leak_checks"

    id = Column(Integer, primary_key=True, index=True)
    reading_a = Column(Float, nullable=False)
    reading_b = Column(Float, nullable=False)
    no_water_used = Column(Boolean, nullable=False, default=True)
    delta = Column(Float, nullable=False)
    leak_detected = Column(Boolean, nullable=False, default=False)
    confidence = Column(String(50), nullable=False)
    photo_path_a = Column(String(500), nullable=True)
    photo_path_b = Column(String(500), nullable=True)
    duration_minutes = Column(Integer, nullable=False, default=10)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class BillAnalysis(Base):
    __tablename__ = "bill_analyses"

    id = Column(Integer, primary_key=True, index=True)
    period_start = Column(DateTime(timezone=True), nullable=False)
    period_end = Column(DateTime(timezone=True), nullable=False)
    usage = Column(Float, nullable=False)
    amount = Column(Float, nullable=False)
    photo_path = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


