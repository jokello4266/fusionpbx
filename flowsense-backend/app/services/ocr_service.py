"""OCR service for extracting information from bill images using AI."""
import re
import os
from datetime import datetime, timedelta
from typing import Dict, Optional
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

# Try to import optional dependencies
try:
    from PIL import Image
    import pytesseract
    TESSERACT_AVAILABLE = True
except ImportError:
    TESSERACT_AVAILABLE = False
    logger.warning("Tesseract not available. Install pytesseract and tesseract-ocr.")

try:
    from openai import OpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False
    logger.warning("OpenAI not available. Install openai package.")

from app.services.ai_service import ai_service

class OCRService:
    """Service for extracting bill information from images using OCR and AI."""
    
    def __init__(self):
        """Initialize OCR service."""
        self.use_ai = OPENAI_AVAILABLE and os.getenv('OPENAI_API_KEY')
        self.use_tesseract = TESSERACT_AVAILABLE and not self.use_ai
        
        if self.use_ai:
            logger.info("Using OpenAI AI for bill extraction")
        elif self.use_tesseract:
            logger.info("Using Tesseract OCR for bill extraction")
        else:
            logger.warning("No OCR/AI available. Using default values.")
    
    async def extract_bill_info(self, image_path: Path) -> Dict[str, any]:
        """Extract bill information from an image using AI/OCR.
        
        Args:
            image_path: Path to the bill image
            
        Returns:
            Dictionary with extracted information:
            {
                'period_start': datetime,
                'period_end': datetime,
                'usage': float,
                'amount': float,
                'confidence': float
            }
        """
        try:
            if self.use_ai:
                return await ai_service.extract_bill_info(image_path)
            elif self.use_tesseract:
                return await self._extract_with_tesseract(image_path)
            else:
                logger.warning("No OCR/AI available. Using default values.")
                return self._get_default_values()
        except Exception as e:
            logger.error(f"OCR extraction failed: {e}")
            return self._get_default_values()
    
    async def _extract_with_tesseract(self, image_path: Path) -> Dict[str, any]:
        """Extract bill info using Tesseract OCR."""
        try:
            # Read image
            image = Image.open(image_path)
            
            # Extract text using Tesseract
            text = pytesseract.image_to_string(image)
            logger.info(f"Extracted text (first 200 chars): {text[:200]}")
            
            # Parse information from text
            period_start = self._parse_date(text)
            period_end = self._parse_date(text)
            usage = self._parse_usage(text)
            amount = self._parse_amount(text)
            
            # Calculate confidence based on what we found
            found_count = sum([
                period_start is not None,
                period_end is not None,
                usage is not None,
                amount is not None
            ])
            confidence = found_count / 4.0
            
            return {
                'period_start': period_start or self._get_default_period_start(),
                'period_end': period_end or self._get_default_period_end(),
                'usage': usage or 0.0,
                'amount': amount or 0.0,
                'confidence': confidence,
            }
        except Exception as e:
            logger.error(f"Tesseract extraction failed: {e}")
            return self._get_default_values()
    
    
    def _get_default_period_start(self) -> datetime:
        """Get default period start (first day of last month)."""
        now = datetime.now()
        if now.month == 1:
            return datetime(now.year - 1, 12, 1)
        return datetime(now.year, now.month - 1, 1)
    
    def _get_default_period_end(self) -> datetime:
        """Get default period end (last day of last month)."""
        now = datetime.now()
        if now.month == 1:
            return datetime(now.year - 1, 12, 31)
        return datetime(now.year, now.month, 1) - timedelta(days=1)
    
    def _get_default_values(self) -> Dict[str, any]:
        """Get default values when extraction fails."""
        return {
            'period_start': self._get_default_period_start(),
            'period_end': self._get_default_period_end(),
            'usage': 0.0,
            'amount': 0.0,
            'confidence': 0.0,
        }
    
    def _parse_date(self, text: str) -> Optional[datetime]:
        """Parse date from text using common patterns."""
        if not text:
            return None
            
        # Common date patterns
        patterns = [
            r'(\d{1,2})/(\d{1,2})/(\d{4})',  # MM/DD/YYYY
            r'(\d{4})-(\d{1,2})-(\d{1,2})',  # YYYY-MM-DD
            r'(\w+)\s+(\d{1,2}),\s+(\d{4})',  # Month DD, YYYY
            r'(\d{1,2})-(\d{1,2})-(\d{4})',  # MM-DD-YYYY
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text)
            if match:
                try:
                    if '/' in match.group(0):
                        month, day, year = match.groups()
                        return datetime(int(year), int(month), int(day))
                    elif '-' in match.group(0) and len(match.group(1)) == 4:
                        year, month, day = match.groups()
                        return datetime(int(year), int(month), int(day))
                    elif '-' in match.group(0):
                        month, day, year = match.groups()
                        return datetime(int(year), int(month), int(day))
                except (ValueError, IndexError):
                    continue
        
        return None
    
    def _parse_usage(self, text: str) -> Optional[float]:
        """Parse water usage (gallons) from text."""
        if not text:
            return None
            
        # Look for patterns like "1,500 gallons", "1500 gal", etc.
        patterns = [
            r'(\d{1,3}(?:,\d{3})*\.?\d*)\s*(?:gallons?|gal|gals|gallon)',
            r'usage[:\s]+(\d{1,3}(?:,\d{3})*\.?\d*)',
            r'(\d{1,3}(?:,\d{3})*\.?\d*)\s*(?:cubic\s+feet|cf|cu\s+ft)',
            r'(\d{1,3}(?:,\d{3})*\.?\d*)\s*gal',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                try:
                    value_str = match.group(1).replace(',', '')
                    return float(value_str)
                except ValueError:
                    continue
        
        return None
    
    def _parse_amount(self, text: str) -> Optional[float]:
        """Parse dollar amount from text."""
        if not text:
            return None
            
        # Look for patterns like "$45.50", "Total: $45.50", etc.
        patterns = [
            r'\$(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            r'total[:\s]+\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            r'amount[:\s]+\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            r'due[:\s]+\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            r'balance[:\s]+\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                try:
                    value_str = match.group(1).replace(',', '')
                    return float(value_str)
                except ValueError:
                    continue
        
        return None

# Global instance
ocr_service = OCRService()
