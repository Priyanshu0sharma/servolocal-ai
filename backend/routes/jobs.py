import os
import shutil
import uuid
from datetime import datetime
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Body
from sqlalchemy.orm import Session
from pydantic import BaseModel

from backend.config import UPLOAD_DIR
from backend.database.database import get_db
from backend.database.models import Job, User, Technician, Notification
from backend.websocket.connection_manager import manager

router = APIRouter(prefix="/api/jobs", tags=["Jobs"])

def serialize_job(job: Job) -> dict:
    return {
        "id": job.id,
        "job_code": job.job_code,
        "user_id": job.user_id,
        "user_name": job.user.name if job.user else "User",
        "user_phone": job.user.phone if job.user else "",
        "user_address": job.address,
        "building": job.building,
        "floor": job.floor,
        "instructions": job.instructions,
        "technician_id": job.technician_id,
        "technician_name": job.technician.name if job.technician else "Not Assigned",
        "technician_phone": job.technician.phone if job.technician else "",
        "technician_rating": job.technician.rating if job.technician else 4.8,
        "technician_avatar": job.technician.avatar if job.technician else "",
        "technician_distance": job.technician.distance_km if job.technician else 2.4,
        "category": job.category,
        "equipment_name": job.equipment_name,
        "brand": job.brand,
        "model_number": job.model_number,
        "approx_age": job.approx_age,
        "title": job.title,
        "description": job.description,
        "media_url": job.media_url,
        "ai_confidence": job.ai_confidence,
        "severity": job.severity,
        "possible_causes": job.possible_causes or [],
        "required_parts": job.required_parts or [],
        "estimated_cost_min": job.estimated_cost_min,
        "estimated_cost_max": job.estimated_cost_max,
        "labour_cost": job.labour_cost,
        "parts_cost": job.parts_cost,
        "service_charge": job.service_charge,
        "final_amount": job.final_amount,
        "status": job.status,
        "created_at": job.created_at.isoformat() if job.created_at else None,
        "accepted_at": job.accepted_at.isoformat() if job.accepted_at else None,
        "arrived_at": job.arrived_at.isoformat() if job.arrived_at else None,
        "completed_at": job.completed_at.isoformat() if job.completed_at else None,
        "before_image": job.before_image,
        "after_image": job.after_image,
        "parts_used": job.parts_used or [],
        "payment_method": job.payment_method,
        "payment_status": job.payment_status,
        "transaction_id": job.transaction_id,
        "rating": job.rating,
        "review_comment": job.review_comment
    }

class CreateJobRequest(BaseModel):
    user_id: int
    technician_id: Optional[int] = None
    category: str
    equipment_name: Optional[str] = ""
    brand: Optional[str] = ""
    model_number: Optional[str] = ""
    approx_age: Optional[str] = ""
    title: str = "Equipment Repair"
    description: str = ""
    media_url: Optional[str] = None
    ai_confidence: Optional[int] = 92
    severity: Optional[str] = "HIGH"
    possible_causes: Optional[List[str]] = []
    required_parts: Optional[List[str]] = []
    estimated_cost_min: Optional[float] = 800.0
    estimated_cost_max: Optional[float] = 1600.0
    labour_cost: Optional[float] = 450.0
    parts_cost: Optional[float] = 600.0
    service_charge: Optional[float] = 150.0
    final_amount: Optional[float] = 1200.0
    address: Optional[str] = ""
    building: Optional[str] = ""
    floor: Optional[str] = ""
    instructions: Optional[str] = ""

@router.post("")
async def create_job(req: CreateJobRequest, db: Session = Depends(get_db)):
    count = db.query(Job).count()
    job_code = f"#{1000 + count + 1}"

    status = "ACCEPTED" if req.technician_id else "SEARCHING"
    accepted_at = datetime.utcnow() if req.technician_id else None

    new_job = Job(
        job_code=job_code,
        user_id=req.user_id,
        technician_id=req.technician_id,
        category=req.category,
        equipment_name=req.equipment_name,
        brand=req.brand,
        model_number=req.model_number,
        approx_age=req.approx_age,
        title=req.title,
        description=req.description,
        media_url=req.media_url,
        ai_confidence=req.ai_confidence,
        severity=req.severity,
        possible_causes=req.possible_causes,
        required_parts=req.required_parts,
        estimated_cost_min=req.estimated_cost_min,
        estimated_cost_max=req.estimated_cost_max,
        labour_cost=req.labour_cost,
        parts_cost=req.parts_cost,
        service_charge=req.service_charge,
        final_amount=req.final_amount,
        status=status,
        address=req.address,
        building=req.building,
        floor=req.floor,
        instructions=req.instructions,
        created_at=datetime.utcnow(),
        accepted_at=accepted_at
    )
    db.add(new_job)
    db.commit()
    db.refresh(new_job)

    job_data = serialize_job(new_job)
    await manager.broadcast_job_event("NEW_REPAIR_REQUEST", job_data)

    return {
        "success": True,
        "job": job_data
    }

@router.get("/{job_id}")
def get_job_by_id(job_id: int, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return serialize_job(job)

@router.get("/user/{user_id}/active")
def get_user_active_job(user_id: int, db: Session = Depends(get_db)):
    """Returns currently ongoing job for user (ON_THE_WAY, ARRIVED, REPAIRING, ACCEPTED)."""
    job = db.query(Job).filter(
        Job.user_id == user_id,
        Job.status.in_(["CREATED", "ACCEPTED", "ON_THE_WAY", "ARRIVED", "REPAIRING"])
    ).order_by(Job.id.desc()).first()

    if not job:
        # Fallback to latest job if none active
        job = db.query(Job).filter(Job.user_id == user_id).order_by(Job.id.desc()).first()

    if not job:
        return {"has_active_job": False, "job": None}

    return {
        "has_active_job": job.status not in ["COMPLETED", "PAID", "CANCELLED"],
        "job": serialize_job(job)
    }

@router.get("/user/{user_id}/history")
def get_user_job_history(user_id: int, db: Session = Depends(get_db)):
    jobs = db.query(Job).filter(Job.user_id == user_id).order_by(Job.id.desc()).all()
    return {
        "jobs": [serialize_job(j) for j in jobs]
    }

class StatusUpdateRequest(BaseModel):
    status: str # ACCEPTED, ON_THE_WAY, ARRIVED, REPAIRING, COMPLETED, PAID, CANCELLED
    technician_id: Optional[int] = None

@router.post("/{job_id}/status")
async def update_job_status(job_id: int, req: StatusUpdateRequest, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    old_status = job.status
    job.status = req.status.upper()

    if req.technician_id and not job.technician_id:
        job.technician_id = req.technician_id

    if job.status == "ACCEPTED" and not job.accepted_at:
        job.accepted_at = datetime.utcnow()
    elif job.status == "ARRIVED" and not job.arrived_at:
        job.arrived_at = datetime.utcnow()
    elif job.status in ["COMPLETED", "PAID"] and not job.completed_at:
        job.completed_at = datetime.utcnow()
        if job.technician:
            job.technician.today_earnings += job.final_amount
            job.technician.total_earnings += job.final_amount
            job.technician.completed_jobs_count += 1

    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("STATUS_UPDATED", job_data)

    return {
        "success": True,
        "old_status": old_status,
        "new_status": job.status,
        "job": job_data
    }

@router.post("/{job_id}/proof")
async def upload_repair_proof(
    job_id: int,
    parts_used: Optional[str] = Form("Air Filter, Electrical Relay"),
    before_image: Optional[UploadFile] = File(None),
    after_image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    if before_image and before_image.filename:
        ext = os.path.splitext(before_image.filename)[1] or ".jpg"
        b_name = f"proof_before_{job.id}_{uuid.uuid4().hex[:6]}{ext}"
        b_path = UPLOAD_DIR / b_name
        with open(b_path, "wb") as buffer:
            shutil.copyfileobj(before_image.file, buffer)
        job.before_image = f"/uploads/{b_name}"
    elif not job.before_image:
        job.before_image = "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=80"

    if after_image and after_image.filename:
        ext = os.path.splitext(after_image.filename)[1] or ".jpg"
        a_name = f"proof_after_{job.id}_{uuid.uuid4().hex[:6]}{ext}"
        a_path = UPLOAD_DIR / a_name
        with open(a_path, "wb") as buffer:
            shutil.copyfileobj(after_image.file, buffer)
        job.after_image = f"/uploads/{a_name}"
    elif not job.after_image:
        job.after_image = "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&auto=format&fit=crop&q=80"

    if parts_used:
        job.parts_used = [p.strip() for p in parts_used.split(",") if p.strip()]

    job.status = "COMPLETED"
    job.completed_at = datetime.utcnow()
    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("PROOF_SUBMITTED", job_data)

    return {
        "success": True,
        "message": "Repair proof uploaded and job marked completed",
        "job": job_data
    }

class FeedbackRequest(BaseModel):
    rating: float = 5.0
    review_comment: str = "Fast and transparent service."
    issue_resolved: bool = True

@router.post("/{job_id}/feedback")
async def submit_feedback(job_id: int, req: FeedbackRequest, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    job.rating = req.rating
    job.review_comment = req.review_comment
    job.issue_resolved = req.issue_resolved

    if job.technician:
        # Re-compute technician rolling average rating
        all_tech_ratings = db.query(Job.rating).filter(
            Job.technician_id == job.technician_id,
            Job.rating.isnot(None)
        ).all()
        ratings_list = [r[0] for r in all_tech_ratings if r[0] is not None]
        ratings_list.append(req.rating)
        job.technician.rating = round(sum(ratings_list) / len(ratings_list), 1)
        job.technician.reviews_count += 1

    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("FEEDBACK_SUBMITTED", job_data)

    return {
        "success": True,
        "job": job_data
    }

class AcceptJobRequest(BaseModel):
    technician_id: int

@router.post("/{job_id}/accept")
async def accept_job(job_id: int, req: AcceptJobRequest, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    tech = db.query(Technician).filter(Technician.id == req.technician_id).first()
    if not tech:
        raise HTTPException(status_code=404, detail="Technician not found")

    job.technician_id = tech.id
    job.status = "ACCEPTED"
    job.accepted_at = datetime.utcnow()
    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("REQUEST_ACCEPTED", job_data)

    return {
        "success": True,
        "message": "Job accepted successfully",
        "job": job_data
    }

class SubmitQuoteRequest(BaseModel):
    technician_id: int
    actual_issue: str
    required_parts: List[str] = []
    labour_cost: float = 450.0
    parts_cost: float = 600.0
    service_fee: float = 150.0
    total_amount: float = 1200.0

@router.post("/{job_id}/quote")
async def submit_quote(job_id: int, req: SubmitQuoteRequest, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    job.labour_cost = req.labour_cost
    job.parts_cost = req.parts_cost
    job.service_charge = req.service_fee
    job.final_amount = req.total_amount
    job.status = "QUOTE_PENDING"
    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("QUOTE_SUBMITTED", job_data)

    return {
        "success": True,
        "message": "Quotation submitted to customer",
        "job": job_data
    }

@router.post("/{job_id}/approve-quote")
async def approve_quote(job_id: int, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    job.status = "QUOTE_APPROVED"
    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("QUOTE_APPROVED", job_data)

    return {
        "success": True,
        "message": "Quote approved. Technician notified.",
        "job": job_data
    }

class ChatMessageRequest(BaseModel):
    sender_id: int
    receiver_id: int
    sender_name: str
    sender_role: str # 'user' or 'technician'
    message: str

@router.get("/{job_id}/messages")
def get_job_chat_messages(job_id: int, db: Session = Depends(get_db)):
    from backend.database.models import ChatMessage
    msgs = db.query(ChatMessage).filter(ChatMessage.job_id == job_id).order_by(ChatMessage.created_at.asc()).all()
    return {
        "messages": [
            {
                "id": m.id,
                "job_id": m.job_id,
                "sender_id": m.sender_id,
                "receiver_id": m.receiver_id,
                "sender_name": m.sender_name,
                "sender_role": m.sender_role,
                "message": m.message,
                "created_at": m.created_at.isoformat()
            }
            for m in msgs
        ]
    }

@router.post("/{job_id}/messages")
async def post_job_chat_message(job_id: int, req: ChatMessageRequest, db: Session = Depends(get_db)):
    from backend.database.models import ChatMessage
    new_msg = ChatMessage(
        job_id=job_id,
        sender_id=req.sender_id,
        receiver_id=req.receiver_id,
        sender_name=req.sender_name,
        sender_role=req.sender_role,
        message=req.message,
        created_at=datetime.utcnow()
    )
    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)

    msg_data = {
        "id": new_msg.id,
        "job_id": new_msg.job_id,
        "sender_id": new_msg.sender_id,
        "receiver_id": new_msg.receiver_id,
        "sender_name": new_msg.sender_name,
        "sender_role": new_msg.sender_role,
        "message": new_msg.message,
        "created_at": new_msg.created_at.isoformat()
    }

    # Broadcast real-time message via WebSocket
    await manager.broadcast_job_event("CHAT_MESSAGE", {"job_id": job_id, "message": msg_data})

    return {
        "success": True,
        "message": msg_data
    }

