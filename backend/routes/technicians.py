from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from backend.database.database import get_db
from backend.database.models import Technician, Job
from backend.services.matching_engine import matching_engine

router = APIRouter(prefix="/api/technicians", tags=["Technicians"])

@router.get("/nearby")
def get_nearby_technicians(
    category: Optional[str] = Query("AC Repair"),
    lat: Optional[float] = Query(26.9150),
    lng: Optional[float] = Query(75.7420),
    db: Session = Depends(get_db)
):
    """Returns smart-ranked technicians matching the category and user location."""
    results = matching_engine.match_technicians(db, category=category, user_lat=lat, user_lng=lng)
    return {
        "success": True,
        "category": category,
        "count": len(results),
        "technicians": results
    }

@router.get("/{tech_id}")
def get_technician_detail(tech_id: int, db: Session = Depends(get_db)):
    tech = db.query(Technician).filter(Technician.id == tech_id).first()
    if not tech:
        raise HTTPException(status_code=404, detail="Technician not found")
    return {
        "id": tech.id,
        "user_id": tech.user_id,
        "name": tech.name,
        "phone": tech.phone,
        "avatar": tech.avatar,
        "speciality": tech.speciality,
        "skills": tech.skills,
        "experience_years": tech.experience_years,
        "rating": tech.rating,
        "reviews_count": tech.reviews_count,
        "visit_charge": tech.visit_charge,
        "is_online": tech.is_online,
        "distance_km": tech.distance_km,
        "completed_jobs_count": tech.completed_jobs_count
    }

@router.post("/{tech_id}/toggle-status")
def toggle_technician_status(tech_id: int, db: Session = Depends(get_db)):
    tech = db.query(Technician).filter(Technician.id == tech_id).first()
    if not tech:
        raise HTTPException(status_code=404, detail="Technician not found")
    tech.is_online = not tech.is_online
    db.commit()
    db.refresh(tech)
    return {
        "success": True,
        "id": tech.id,
        "is_online": tech.is_online
    }

@router.get("/{tech_id}/dashboard-stats")
def get_technician_dashboard_stats(tech_id: int, db: Session = Depends(get_db)):
    tech = db.query(Technician).filter(Technician.id == tech_id).first()
    if not tech:
        raise HTTPException(status_code=404, detail="Technician not found")

    pending_jobs = db.query(Job).filter(
        Job.technician_id == tech.id,
        Job.status.in_(["CREATED", "DIAGNOSED", "ACCEPTED", "ON_THE_WAY", "ARRIVED", "REPAIRING"])
    ).all()

    completed_today = db.query(Job).filter(
        Job.technician_id == tech.id,
        Job.status.in_(["COMPLETED", "PAID"])
    ).count()

    return {
        "name": tech.name,
        "avatar": tech.avatar,
        "is_online": tech.is_online,
        "rating": tech.rating,
        "today_jobs": completed_today + len(pending_jobs),
        "pending_requests": len(pending_jobs),
        "today_earnings": tech.today_earnings,
        "week_earnings": tech.week_earnings,
        "month_earnings": tech.total_earnings,
        "completed_jobs_count": tech.completed_jobs_count,
        "active_jobs": [
            {
                "id": j.id,
                "job_code": j.job_code,
                "title": j.title,
                "category": j.category,
                "status": j.status,
                "final_amount": j.final_amount,
                "address": j.address,
                "user_name": j.user.name if j.user else "Customer",
                "user_phone": j.user.phone if j.user else ""
            }
            for j in pending_jobs
        ]
    }
