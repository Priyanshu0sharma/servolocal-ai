from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from backend.services.voice_engine import voice_engine
from backend.database.database import get_db
from backend.database.models import Job
from backend.websocket.connection_manager import manager
from backend.routes.jobs import serialize_job

router = APIRouter(prefix="/api/voice", tags=["Voice"])

class VoiceCommandRequest(BaseModel):
    job_id: Optional[int] = None
    transcript: str # e.g. "Main location par pahunch gaya hoon"

@router.post("/process")
async def process_voice_command(req: VoiceCommandRequest, db: Session = Depends(get_db)):
    parsed = voice_engine.process_voice_transcript(req.transcript)
    
    updated_job = None
    if parsed["recognized"] and req.job_id:
        job = db.query(Job).filter(Job.id == req.job_id).first()
        if job:
            job.status = parsed["detected_status"]
            db.commit()
            db.refresh(job)
            updated_job = serialize_job(job)
            await manager.broadcast_job_event("STATUS_UPDATED", updated_job)

    return {
        "success": True,
        "parsed": parsed,
        "job": updated_job
    }
