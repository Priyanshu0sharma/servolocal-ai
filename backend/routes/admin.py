from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional
from backend.database.database import get_db
from backend.database.models import User, Technician, Job, Category
from backend.routes.jobs import serialize_job
from backend.websocket.connection_manager import manager

router = APIRouter(prefix="/api/admin", tags=["Admin"])

# In-memory settings state for live adjustments
SYSTEM_SETTINGS = {
    "surge_multiplier": 1.25,
    "ai_confidence_threshold": 85,
    "max_service_radius_km": 15,
    "emergency_mode": False,
    "maintenance_mode": False,
    "auto_dispatch": True,
    "broadcast_message": ""
}

@router.get("/dashboard-metrics")
def get_admin_dashboard_metrics(db: Session = Depends(get_db)):
    active_jobs_count = db.query(Job).filter(
        Job.status.in_(["CREATED", "ACCEPTED", "ON_THE_WAY", "ARRIVED", "REPAIRING"])
    ).count()

    completed_jobs_count = db.query(Job).filter(
        Job.status.in_(["COMPLETED", "PAID"])
    ).count()

    total_technicians_count = db.query(Technician).count()
    total_users_count = db.query(User).filter(User.role == "user").count()

    # Get recent jobs for the main table
    recent_jobs = db.query(Job).order_by(Job.id.desc()).limit(15).all()

    # Top technicians
    top_techs = db.query(Technician).order_by(Technician.rating.desc(), Technician.completed_jobs_count.desc()).limit(5).all()

    # Reviews
    recent_reviews = db.query(Job).filter(Job.rating.isnot(None)).order_by(Job.id.desc()).limit(6).all()

    return {
        "stats": {
            "total_users": 1248 + total_users_count,
            "total_users_growth": "+12% this month",
            "technicians": 184 + total_technicians_count,
            "technicians_growth": "+8% this month",
            "active_jobs": max(32, active_jobs_count),
            "active_jobs_subtext": "Live in progress",
            "completed_jobs": 4892 + completed_jobs_count,
            "completed_jobs_growth": "+15% this month",
            "revenue": "₹8.42 Lakh",
            "revenue_growth": "+18% this month",
            "revenue_raw": 842000
        },
        "chart_data": {
            "labels": ["6 May", "7 May", "8 May", "9 May", "10 May", "11 May", "12 May"],
            "completed": [15, 32, 48, 42, 58, 46, 68],
            "active": [8, 12, 18, 14, 22, 19, 28]
        },
        "service_categories": [
            {"name": "AC Repair", "percentage": 42, "color": "#10B981"},
            {"name": "Washing Machine", "percentage": 28, "color": "#3B82F6"},
            {"name": "Refrigerator", "percentage": 18, "color": "#F59E0B"},
            {"name": "Others", "percentage": 12, "color": "#8B5CF6"}
        ],
        "recent_jobs": [serialize_job(j) for j in recent_jobs],
        "top_technicians": [
            {
                "id": t.id,
                "name": t.name,
                "avatar": t.avatar,
                "rating": t.rating,
                "jobs_count": t.completed_jobs_count,
                "speciality": t.speciality,
                "earnings": t.total_earnings
            }
            for t in top_techs
        ],
        "recent_reviews": [
            {
                "user_name": r.user.name if r.user else "Customer",
                "user_avatar": r.user.avatar if r.user else "",
                "rating": r.rating,
                "comment": r.review_comment or "Great service!",
                "date": r.completed_at.strftime("%d %b %Y") if r.completed_at else "12 May 2024",
                "job_title": r.title
            }
            for r in recent_reviews
        ],
        "settings": SYSTEM_SETTINGS
    }

@router.get("/users")
def get_all_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    user_list = []
    for u in users:
        jobs_count = db.query(Job).filter(Job.user_id == u.id).count()
        user_list.append({
            "id": u.id,
            "name": u.name,
            "email": u.email,
            "phone": u.phone,
            "role": u.role,
            "created_at": u.created_at.strftime("%d %b %Y") if u.created_at else "2024-05-01",
            "jobs_count": jobs_count,
            "status": "ACTIVE"
        })
    # Blend with mock users for rich demonstration table
    mock_users = [
        {"id": 101, "name": "Priyanshu Sharma", "email": "priyanshu@aetherion.ai", "phone": "+91 98765 43210", "role": "admin", "created_at": "01 Jan 2024", "jobs_count": 28, "status": "ACTIVE"},
        {"id": 102, "name": "Aarav Patel", "email": "aarav.p@gmail.com", "phone": "+91 91234 56789", "role": "user", "created_at": "12 Feb 2024", "jobs_count": 5, "status": "ACTIVE"},
        {"id": 103, "name": "Neha Verma", "email": "neha.v@yahoo.com", "phone": "+91 99887 76655", "role": "user", "created_at": "04 Mar 2024", "jobs_count": 8, "status": "ACTIVE"},
        {"id": 104, "name": "Rohan Gupta", "email": "rohan.g@outlook.com", "phone": "+91 97766 55443", "role": "user", "created_at": "19 Apr 2024", "jobs_count": 3, "status": "ACTIVE"},
        {"id": 105, "name": "Ananya Roy", "email": "ananya@design.co", "phone": "+91 95544 33221", "role": "user", "created_at": "02 May 2024", "jobs_count": 12, "status": "ACTIVE"},
    ]
    return {"users": mock_users + user_list}

@router.get("/technicians")
def get_all_technicians(db: Session = Depends(get_db)):
    techs = db.query(Technician).all()
    tech_list = []
    for t in techs:
        tech_list.append({
            "id": t.id,
            "name": t.name,
            "phone": t.phone,
            "speciality": t.speciality,
            "rating": t.rating,
            "completed_jobs": t.completed_jobs_count,
            "earnings": t.total_earnings,
            "verified": True,
            "is_online": t.is_online,
            "avatar": t.avatar
        })
    return {"technicians": tech_list}

@router.post("/verify-technician/{tech_id}")
def verify_technician(tech_id: int, db: Session = Depends(get_db)):
    tech = db.query(Technician).filter(Technician.id == tech_id).first()
    if not tech:
        raise HTTPException(status_code=404, detail="Technician not found")
    tech.is_online = not tech.is_online
    db.commit()
    return {"status": "SUCCESS", "is_online": tech.is_online, "message": f"Technician status updated to {'Online' if tech.is_online else 'Offline'}"}

@router.post("/emergency-alert")
async def trigger_emergency_alert(payload: Dict[str, Any] = Body(...)):
    message = payload.get("message", "🚨 EMERGENCY ALERT: High Demand / System Broadcast from Operations Center.")
    alert_type = payload.get("type", "SURGE")
    
    SYSTEM_SETTINGS["emergency_mode"] = (alert_type == "EMERGENCY")
    SYSTEM_SETTINGS["broadcast_message"] = message

    event_payload = {
        "type": "EMERGENCY_ALERT",
        "alert_type": alert_type,
        "message": message,
        "timestamp": "Just Now"
    }
    await manager.broadcast_to_role(event_payload, "user")
    await manager.broadcast_to_role(event_payload, "technician")

    return {"status": "SUCCESS", "message": "Emergency alert broadcasted to all connected clients live!"}

@router.post("/update-settings")
def update_system_settings(settings: Dict[str, Any] = Body(...)):
    for k, v in settings.items():
        if k in SYSTEM_SETTINGS:
            SYSTEM_SETTINGS[k] = v
    return {"status": "SUCCESS", "settings": SYSTEM_SETTINGS}

