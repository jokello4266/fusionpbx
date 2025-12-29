"""File upload endpoints."""
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import FileResponse
from typing import Optional
from app.services.storage_service import storage_service
from pathlib import Path

router = APIRouter()

@router.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    category: Optional[str] = None,
):
    """Upload a file (photo/image).
    
    Args:
        file: The file to upload
        category: Optional category (e.g., "bill", "meter", "leak-check")
        
    Returns:
        Dictionary with file path and metadata
    """
    # Validate file type
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Validate file size (max 10MB)
    file.file.seek(0, 2)  # Seek to end
    file_size = file.file.tell()
    file.file.seek(0)  # Reset to beginning
    
    max_size = 10 * 1024 * 1024  # 10MB
    if file_size > max_size:
        raise HTTPException(status_code=400, detail="File size exceeds 10MB limit")
    
    # Determine subfolder based on category
    subfolder = category if category else "uploads"
    
    try:
        # Save file
        relative_path = await storage_service.save_file(file, subfolder)
        
        return {
            "success": True,
            "path": relative_path,
            "filename": file.filename,
            "content_type": file.content_type,
            "size": file_size,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload file: {str(e)}")

@router.get("/photos/{file_path:path}")
async def get_photo(file_path: str):
    """Retrieve an uploaded photo.
    
    Args:
        file_path: Relative path to the photo (e.g., "bills/uuid.jpg")
        
    Returns:
        File response with the image
    """
    full_path = storage_service.get_file_path(file_path)
    
    if not full_path or not full_path.exists():
        raise HTTPException(status_code=404, detail="Photo not found")
    
    # Determine media type from file extension
    ext = full_path.suffix.lower()
    media_type = "image/jpeg"  # default
    if ext in [".png"]:
        media_type = "image/png"
    elif ext in [".gif"]:
        media_type = "image/gif"
    elif ext in [".webp"]:
        media_type = "image/webp"
    
    return FileResponse(
        str(full_path),
        media_type=media_type,
    )

@router.delete("/photos/{file_path:path}")
async def delete_photo(file_path: str):
    """Delete an uploaded photo.
    
    Args:
        file_path: Relative path to the photo
        
    Returns:
        Success message
    """
    success = storage_service.delete_file(file_path)
    
    if not success:
        raise HTTPException(status_code=404, detail="Photo not found")
    
    return {"success": True, "message": "Photo deleted"}

