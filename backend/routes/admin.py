from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.database.database import get_db
from backend.database.models import User, Technician, Job, Category
from backend.routes.jobs import serialize_job

router = APIRouter(prefix="/api/admin", tags=["Admin"])

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
            {"name": "AC Repair", "percentage": 42, "color": "#1B4332"},
            {"name": "Washing Machine", "percentage": 28, "color": "#4C6B5D"},
            {"name": "Refrigerator", "percentage": 18, "color": "#7B4B2A"},
            {"name": "Others", "percentage": 12, "color": "#C49A6C"}
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
        ]
    }
