"""AI service for intelligent bill extraction using OpenAI."""
import os
import json
import re
import base64
from pathlib import Path
from typing import Dict, Optional
from datetime import datetime, timedelta
import logging

try:
    from openai import OpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

logger = logging.getLogger(__name__)

class AIService:
    """Service for AI-powered bill information extraction."""
    
    def __init__(self):
        """Initialize AI service."""
        self.client = None
        if not OPENAI_AVAILABLE:
            logger.warning("OpenAI package not installed")
            return
            
        api_key = os.getenv('OPENAI_API_KEY')
        if api_key:
            try:
                self.client = OpenAI(api_key=api_key)
                logger.info("OpenAI client initialized")
            except Exception as e:
                logger.warning(f"Failed to initialize OpenAI: {e}")
        else:
            logger.warning("OPENAI_API_KEY not set. AI extraction will be limited.")
    
    async def extract_bill_info(self, image_path: Path) -> Dict[str, any]:
        """Extract bill information using AI vision.
        
        Args:
            image_path: Path to the bill image
            
        Returns:
            Dictionary with extracted information
        """
        if not self.client:
            logger.warning("OpenAI client not available. Returning defaults.")
            return self._get_defaults()
        
        try:
            # Convert image to base64
            with open(image_path, 'rb') as img_file:
                image_base64 = base64.b64encode(img_file.read()).decode('utf-8')
            
            # Call OpenAI Vision API
            response = self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": """Analyze this water bill image and extract the following information:

1. Billing period start date (format: YYYY-MM-DD)
2. Billing period end date (format: YYYY-MM-DD)  
3. Water usage in gallons (numeric value only, no units)
4. Total amount due in dollars (numeric value only, no $ sign)

Return ONLY valid JSON with this exact structure (no markdown, no code blocks):
{
    "period_start": "YYYY-MM-DD or null",
    "period_end": "YYYY-MM-DD or null",
    "usage": 1234.56 or null,
    "amount": 45.50 or null
}

If you cannot find a value, use null. Be precise and extract actual numbers from the bill."""
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{image_base64}"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=300,
                temperature=0.1
            )
            
            # Parse response
            content = response.choices[0].message.content.strip()
            
            # Remove markdown code blocks if present
            content = re.sub(r'```json\n?', '', content)
            content = re.sub(r'```\n?', '', content)
            content = content.strip()
            
            # Parse JSON
            data = json.loads(content)
            
            # Convert to proper types
            period_start = self._parse_date(data.get('period_start'))
            period_end = self._parse_date(data.get('period_end'))
            usage = float(data['usage']) if data.get('usage') is not None else 0.0
            amount = float(data['amount']) if data.get('amount') is not None else 0.0
            
            # Calculate confidence
            confidence = 0.0
            if period_start and period_end:
                confidence += 0.3
            if usage and usage > 0:
                confidence += 0.3
            if amount and amount > 0:
                confidence += 0.4
            
            return {
                'period_start': period_start or self._get_default_period_start(),
                'period_end': period_end or self._get_default_period_end(),
                'usage': usage,
                'amount': amount,
                'confidence': confidence,
            }
            
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse AI response as JSON: {e}")
            logger.error(f"Response was: {content[:200]}")
            return self._get_defaults()
        except Exception as e:
            logger.error(f"AI extraction failed: {e}")
            return self._get_defaults()
    
    def _parse_date(self, date_str: Optional[str]) -> Optional[datetime]:
        """Parse date string."""
        if not date_str or date_str.lower() == 'null':
            return None
        try:
            # Try YYYY-MM-DD format
            return datetime.strptime(date_str, '%Y-%m-%d')
        except ValueError:
            try:
                # Try other formats
                for fmt in ['%m/%d/%Y', '%d/%m/%Y', '%Y/%m/%d']:
                    try:
                        return datetime.strptime(date_str, fmt)
                    except ValueError:
                        continue
            except:
                pass
        return None
    
    def _get_default_period_start(self) -> datetime:
        """Get default period start."""
        now = datetime.now()
        if now.month == 1:
            return datetime(now.year - 1, 12, 1)
        return datetime(now.year, now.month - 1, 1)
    
    def _get_default_period_end(self) -> datetime:
        """Get default period end."""
        now = datetime.now()
        if now.month == 1:
            return datetime(now.year - 1, 12, 31)
        return datetime(now.year, now.month, 1) - timedelta(days=1)
    
    def _get_defaults(self) -> Dict[str, any]:
        """Get default values."""
        return {
            'period_start': self._get_default_period_start(),
            'period_end': self._get_default_period_end(),
            'usage': 0.0,
            'amount': 0.0,
            'confidence': 0.0,
        }

# Global instance
ai_service = AIService()

