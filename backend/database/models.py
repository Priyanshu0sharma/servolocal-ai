from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, Text, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from backend.database.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    phone = Column(String(20), nullable=True)
    password = Column(String(255), nullable=False, default="password123")
    role = Column(String(20), default="user") # 'user', 'technician', 'admin'
    avatar = Column(String(255), default="")
    address = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    jobs = relationship("Job", back_populates="user", foreign_keys="Job.user_id")
    technician_profile = relationship("Technician", back_populates="user", uselist=False)

class Technician(Base):
    __tablename__ = "technicians"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(100), nullable=False)
    phone = Column(String(20), default="")
    avatar = Column(String(255), default="")
    speciality = Column(String(100), default="General Specialist")
    skills = Column(JSON, default=list) # ["AC / HVAC", "Electrical", "Industrial Machine"]
    experience_years = Column(Integer, default=5)
    rating = Column(Float, default=5.0)
    reviews_count = Column(Integer, default=0)
    visit_charge = Column(Float, default=450.0)
    is_online = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=True)
    current_lat = Column(Float, default=26.9124)
    current_lng = Column(Float, default=75.7873)
    distance_km = Column(Float, default=2.4)
    total_earnings = Column(Float, default=0.0)
    today_earnings = Column(Float, default=0.0)
    completed_jobs_count = Column(Integer, default=0)

    # Relationships
    user = relationship("User", back_populates="technician_profile")
    jobs = relationship("Job", back_populates="technician", foreign_keys="Job.technician_id")

class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    job_code = Column(String(20), unique=True, index=True) # e.g. #1001
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    technician_id = Column(Integer, ForeignKey("technicians.id"), nullable=True)
    
    # Request Info
    category = Column(String(50), default="AC / HVAC") # Electrical, AC / HVAC, Industrial Machine, Appliance, Plumbing, Other
    equipment_name = Column(String(150), default="")
    brand = Column(String(100), default="")
    model_number = Column(String(100), default="")
    approx_age = Column(String(50), default="")
    title = Column(String(150), default="Equipment Repair")
    description = Column(Text, default="")
    media_url = Column(String(255), nullable=True)
    
    # Problem Details
    when_started = Column(String(50), default="Today")
    is_stopped = Column(Boolean, default=True)
    has_noise_smell = Column(Boolean, default=False)
    voice_transcript = Column(Text, nullable=True)
    
    # Location
    address = Column(String(255), default="")
    building = Column(String(100), default="")
    floor = Column(String(50), default="")
    instructions = Column(String(255), default="")
    user_lat = Column(Float, default=26.9150)
    user_lng = Column(Float, default=75.7420)
    
    # AI Diagnosis Fields
    ai_confidence = Column(Integer, default=90)
    ai_detected_issue = Column(String(150), default="System Failure")
    severity = Column(String(20), default="HIGH") # HIGH, MEDIUM, LOW
    possible_causes = Column(JSON, default=list)
    required_parts = Column(JSON, default=list)
    
    # Financials / Quotation
    estimated_cost_min = Column(Float, default=800.0)
    estimated_cost_max = Column(Float, default=1600.0)
    labour_cost = Column(Float, default=450.0)
    parts_cost = Column(Float, default=600.0)
    service_charge = Column(Float, default=150.0)
    final_amount = Column(Float, default=1200.0)
    
    # Status progression:
    # 'SEARCHING', 'ACCEPTED', 'ON_THE_WAY', 'ARRIVED', 'INSPECTION', 'QUOTE_PENDING', 'QUOTE_APPROVED', 'REPAIRING', 'TESTING', 'COMPLETED', 'PAID', 'CANCELLED'
    status = Column(String(30), default="SEARCHING")
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    accepted_at = Column(DateTime, nullable=True)
    arrived_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    
    # Proof & Digital Handover
    before_image = Column(String(255), nullable=True)
    after_image = Column(String(255), nullable=True)
    parts_used = Column(JSON, default=list)
    inspection_notes = Column(Text, nullable=True)
    
    # Payment
    payment_method = Column(String(20), default="UPI") # UPI, CARD, CASH
    payment_status = Column(String(20), default="PENDING") # PENDING, SUCCESS
    transaction_id = Column(String(50), nullable=True)
    
    # Rating & Feedback
    rating = Column(Float, nullable=True)
    review_comment = Column(Text, nullable=True)
    rating_tags = Column(JSON, default=list)

    # Relationships
    user = relationship("User", back_populates="jobs", foreign_keys=[user_id])
    technician = relationship("Technician", back_populates="jobs", foreign_keys=[technician_id])
    chat_messages = relationship("ChatMessage", back_populates="job", cascade="all, delete-orphan")
    quotes = relationship("Quote", back_populates="job", cascade="all, delete-orphan")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=False)
    sender_id = Column(Integer, nullable=False)
    receiver_id = Column(Integer, nullable=False)
    sender_name = Column(String(100), default="User")
    sender_role = Column(String(20), default="user") # 'user' or 'technician'
    message = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    job = relationship("Job", back_populates="chat_messages")

class Quote(Base):
    __tablename__ = "quotes"

    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=False)
    technician_id = Column(Integer, ForeignKey("technicians.id"), nullable=False)
    actual_issue = Column(String(200), default="")
    required_parts = Column(JSON, default=list)
    labour_cost = Column(Float, default=450.0)
    parts_cost = Column(Float, default=600.0)
    service_fee = Column(Float, default=150.0)
    total_amount = Column(Float, default=1200.0)
    status = Column(String(20), default="PENDING") # PENDING, APPROVED, REJECTED
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    job = relationship("Job", back_populates="quotes")

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True)
    icon = Column(String(50), default="❄️")
    base_price = Column(Float, default=450.0)
    description = Column(String(200), default="")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    target_role = Column(String(20), default="all") # 'user', 'technician', 'admin', 'all'
    user_id = Column(Integer, nullable=True)
    title = Column(String(100), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(30), default="info") # info, alert, success
    created_at = Column(DateTime, default=datetime.utcnow)
    is_read = Column(Boolean, default=False)
