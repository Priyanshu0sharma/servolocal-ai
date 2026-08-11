import os
from backend.database.database import SessionLocal, Base, engine
from backend.database.models import Category

def seed_database():
    """Initializes tables cleanly without fake jobs or users. Starts empty."""
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # Only add basic categories if empty
    if not db.query(Category).first():
        categories = [
            Category(name="AC / HVAC", icon="❄️", base_price=500.0, description="Cooling failure, gas refill, servicing, noisy compressor"),
            Category(name="Electrical", icon="⚡", base_price=400.0, description="Short circuits, MCB tripping, motor rewiring, control panel"),
            Category(name="Industrial Machine", icon="🏭", base_price=800.0, description="3-phase motors, pumps, CNC, hydraulic pressure"),
            Category(name="Appliance", icon="🧺", base_price=450.0, description="Washing machine, refrigerator, microwave, dryer"),
            Category(name="Plumbing", icon="🚰", base_price=350.0, description="Pipe leaks, tap replacement, drainage blockages"),
            Category(name="Other", icon="🛠️", base_price=400.0, description="General hardware & diagnostics"),
        ]
        db.add_all(categories)
        db.commit()

    db.close()

def reset_database():
    """Drops all tables and recreates an empty database for fresh live testing."""
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    seed_database()
    print("[SUCCESS] Database completely reset to empty state.")

if __name__ == "__main__":
    reset_database()
