import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATABASE_URL = f"sqlite:///{BASE_DIR / 'aetherion.db'}"
UPLOAD_DIR = BASE_DIR / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Pre-create demo images folder
SAMPLE_ASSETS_DIR = BASE_DIR / "sample_assets"
SAMPLE_ASSETS_DIR.mkdir(parents=True, exist_ok=True)

HOST = "0.0.0.0"
PORT = 8080
SECRET_KEY = "aetherion_hackathon_super_secret_key"
ALGORITHM = "HS256"
