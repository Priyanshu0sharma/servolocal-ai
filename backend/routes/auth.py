from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from backend.database.database import get_db
from backend.database.models import User, Technician

router = APIRouter(prefix="/api/auth", tags=["Auth"])

class RegisterRequest(BaseModel):
    name: str
    email: str
    phone: str
    password: str
    role: str = "user" # 'user' or 'technician'
    speciality: Optional[str] = "AC & Appliance Specialist"

class LoginRequest(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = "user" # user, technician, admin

@router.post("/register")
def register_user(req: RegisterRequest, db: Session = Depends(get_db)):
    """Registers a new User or Technician account into the database."""
    email_clean = req.email.strip().lower()
    phone_clean = req.phone.strip()

    existing = db.query(User).filter((User.email == email_clean) | (User.phone == phone_clean)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Account with this email or mobile number already exists")

    new_user = User(
        name=req.name.strip(),
        email=email_clean,
        phone=phone_clean,
        password=req.password,
        role=req.role.strip().lower()
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    tech_profile = None
    if new_user.role == "technician":
        new_tech = Technician(
            user_id=new_user.id,
            name=new_user.name,
            phone=new_user.phone,
            speciality=req.speciality or "General Repair Specialist",
            skills=["AC / HVAC", "Electrical", "Plumbing", "Appliance"],
            is_online=True,
            is_verified=True,
            rating=5.0,
            reviews_count=0
        )
        db.add(new_tech)
        db.commit()
        db.refresh(new_tech)
        tech_profile = {
            "id": new_tech.id,
            "name": new_tech.name,
            "speciality": new_tech.speciality,
            "rating": new_tech.rating,
            "is_online": new_tech.is_online,
            "today_earnings": new_tech.today_earnings,
            "completed_jobs_count": new_tech.completed_jobs_count
        }

    return {
        "success": True,
        "message": "Account created successfully",
        "user": {
            "id": new_user.id,
            "name": new_user.name,
            "email": new_user.email,
            "phone": new_user.phone,
            "role": new_user.role,
            "avatar": new_user.avatar,
            "address": new_user.address
        },
        "technician": tech_profile,
        "token": f"aetherion-token-{new_user.id}-{new_user.role}"
    }

@router.post("/login")
def login_user(req: LoginRequest, db: Session = Depends(get_db)):
    """Login supporting email/phone + password verification."""
    query = db.query(User)
    
    if req.email and req.email.strip():
        user = query.filter(User.email == req.email.strip().lower()).first()
    elif req.phone and req.phone.strip():
        user = query.filter(User.phone == req.phone.strip()).first()
    else:
        user = None

    if not user:
        raise HTTPException(status_code=404, detail="No account found with provided email/phone")

    if req.password and user.password and req.password != user.password:
        raise HTTPException(status_code=401, detail="Invalid password")

    tech_profile = None
    if user.role == "technician":
        tech = db.query(Technician).filter(Technician.user_id == user.id).first()
        if not tech:
            # Auto-create technician profile if missing
            tech = Technician(
                user_id=user.id,
                name=user.name,
                phone=user.phone,
                speciality="General Specialist",
                is_online=True,
                is_verified=True,
                rating=5.0
            )
            db.add(tech)
            db.commit()
            db.refresh(tech)

        tech_profile = {
            "id": tech.id,
            "name": tech.name,
            "speciality": tech.speciality,
            "rating": tech.rating,
            "is_online": tech.is_online,
            "today_earnings": tech.today_earnings,
            "completed_jobs_count": tech.completed_jobs_count
        }

    return {
        "success": True,
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "role": user.role,
            "avatar": user.avatar,
            "address": user.address
        },
        "technician": tech_profile,
        "token": f"aetherion-token-{user.id}-{user.role}"
    }

@router.get("/demo-accounts")
def get_demo_accounts(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return {
        "accounts": [
            {"id": u.id, "name": u.name, "email": u.email, "role": u.role, "phone": u.phone}
            for u in users
        ]
    }

