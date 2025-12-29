"""File storage service for handling photo uploads."""
import os
import uuid
from pathlib import Path
from typing import Optional
from fastapi import UploadFile
import shutil

class StorageService:
    """Service for storing and retrieving uploaded files."""
    
    def __init__(self, storage_path: str = "/app/photos"):
        """Initialize storage service.
        
        Args:
            storage_path: Base directory for storing photos
        """
        self.storage_path = Path(storage_path)
        self.storage_path.mkdir(parents=True, exist_ok=True)
    
    async def save_file(self, file: UploadFile, subfolder: str = "uploads") -> str:
        """Save an uploaded file and return the relative path.
        
        Args:
            file: Uploaded file from FastAPI
            subfolder: Subfolder within storage path (e.g., "bills", "meters")
            
        Returns:
            Relative path to the saved file
        """
        # Create subfolder
        folder = self.storage_path / subfolder
        folder.mkdir(parents=True, exist_ok=True)
        
        # Generate unique filename
        file_ext = Path(file.filename).suffix if file.filename else ".jpg"
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = folder / unique_filename
        
        # Save file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Return relative path for database storage
        return f"{subfolder}/{unique_filename}"
    
    def get_file_path(self, relative_path: str) -> Optional[Path]:
        """Get full path to a stored file.
        
        Args:
            relative_path: Relative path stored in database
            
        Returns:
            Full Path object or None if file doesn't exist
        """
        full_path = self.storage_path / relative_path
        if full_path.exists():
            return full_path
        return None
    
    def delete_file(self, relative_path: str) -> bool:
        """Delete a stored file.
        
        Args:
            relative_path: Relative path stored in database
            
        Returns:
            True if deleted, False if not found
        """
        full_path = self.storage_path / relative_path
        if full_path.exists():
            full_path.unlink()
            return True
        return False

# Global instance
storage_service = StorageService()

