import random
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from backend.database.database import get_db
from backend.database.models import Job
from backend.websocket.connection_manager import manager
from backend.routes.jobs import serialize_job

router = APIRouter(prefix="/api/payments", tags=["Payments"])

class PaymentProcessRequest(BaseModel):
    job_id: int
    payment_method: str = "UPI" # UPI, CARD, CASH
    amount: float = 1450.0

@router.post("/process")
async def process_payment(req: PaymentProcessRequest, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == req.job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    txn_id = f"TXN-DEMO-{random.randint(10000, 99999)}"
    job.payment_method = req.payment_method.upper()
    job.payment_status = "SUCCESS"
    job.transaction_id = txn_id
    if job.status != "COMPLETED":
        job.status = "PAID"
        job.completed_at = datetime.utcnow()

    db.commit()
    db.refresh(job)

    job_data = serialize_job(job)
    await manager.broadcast_job_event("PAYMENT_SUCCESSFUL", job_data)

    return {
        "success": True,
        "transaction_id": txn_id,
        "amount": req.amount,
        "payment_method": req.payment_method,
        "timestamp": datetime.utcnow().isoformat(),
        "job": job_data
    }
