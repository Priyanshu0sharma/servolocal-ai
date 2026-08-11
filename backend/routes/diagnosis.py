import os
import shutil
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from backend.config import UPLOAD_DIR
from backend.services.ai_engine import ai_service
from backend.database.database import get_db

router = APIRouter(prefix="/api/diagnose", tags=["Diagnosis"])

@router.post("")
async def diagnose_problem(
    description: str = Form("AC cooling nahi kar raha aur outdoor unit se unusual sound aa rahi hai."),
    location: Optional[str] = Form("Jaipur, Rajasthan"),
    media: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    """Processes user uploaded image/video and text issue, running the AI diagnostic engine."""
    saved_file_path = None
    media_url = None

    if media and media.filename:
        ext = os.path.splitext(media.filename)[1] or ".jpg"
        file_name = f"diag_{uuid.uuid4().hex[:10]}{ext}"
        saved_file_path = str(UPLOAD_DIR / file_name)
        with open(saved_file_path, "wb") as buffer:
            shutil.copyfileobj(media.file, buffer)
        media_url = f"/uploads/{file_name}"
    else:
        # Fallback sample image
        media_url = "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&auto=format&fit=crop&q=80"

    result = ai_service.diagnose(
        text_description=description,
        image_path=saved_file_path,
        location=location
    )

    result["media_url"] = media_url
    return {
        "success": True,
        "diagnosis": result
    }
