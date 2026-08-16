import socket
from pathlib import Path
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse

from backend.config import UPLOAD_DIR
from backend.database.seed_data import seed_database
from backend.websocket.connection_manager import manager
from backend.routes import auth, diagnosis, jobs, technicians, payments, admin, voice

app = FastAPI(
    title="AETHERION / ServoLocal API",
    description="AI-Powered On-Demand Repair Service Platform Backend",
    version="2.0.0"
)

# Enable permissive CORS for multi-device local network / Wi-Fi / Hotspot testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Startup: Seed Database
@app.on_event("startup")
def on_startup():
    seed_database()

# Include REST Routers
app.include_router(auth.router)
app.include_router(diagnosis.router)
app.include_router(jobs.router)
app.include_router(technicians.router)
app.include_router(payments.router)
app.include_router(admin.router)
app.include_router(voice.router)

# Mount Uploads directory
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")

# Frontend directory paths
FRONTEND_DIR = Path(__file__).resolve().parent.parent / "frontend"
if (FRONTEND_DIR / "css").exists():
    app.mount("/css", StaticFiles(directory=str(FRONTEND_DIR / "css")), name="css")
if (FRONTEND_DIR / "js").exists():
    app.mount("/js", StaticFiles(directory=str(FRONTEND_DIR / "js")), name="js")
if (FRONTEND_DIR / "assets").exists():
    app.mount("/assets", StaticFiles(directory=str(FRONTEND_DIR / "assets")), name="assets")
if (FRONTEND_DIR / "_next").exists():
    app.mount("/_next", StaticFiles(directory=str(FRONTEND_DIR / "_next")), name="next_static")

# WebSocket Endpoint
@app.websocket("/ws/{client_type}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_type: str, client_id: str):
    await manager.connect(websocket, client_type, client_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Echo / Ping acknowledgement
            await websocket.send_text(f'{{"type":"ACK","received":{data}}}')
    except WebSocketDisconnect:
        manager.disconnect(websocket, client_type, client_id)
    except Exception:
        manager.disconnect(websocket, client_type, client_id)

def get_local_ip() -> str:
    """Helper to detect laptop Wi-Fi/Hotspot IP address for mobile connection."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

# Frontend HTML Entrypoints
@app.get("/")
async def serve_hub():
    index_path = FRONTEND_DIR / "index.html"
    if index_path.exists():
        return FileResponse(str(index_path))
    return {"message": "AETHERION API Server Running. Open /user, /technician, or /admin"}

@app.get("/user")
async def serve_user():
    path = FRONTEND_DIR / "user.html"
    if path.exists():
        return FileResponse(str(path))
    return FileResponse(str(FRONTEND_DIR / "index.html"))

@app.get("/user-desktop")
async def serve_user_desktop():
    path = FRONTEND_DIR / "user_desktop.html"
    if path.exists():
        return FileResponse(str(path))
    return FileResponse(str(FRONTEND_DIR / "index.html"))

@app.get("/aetherion.apk")
async def download_apk():
    apk_path = FRONTEND_DIR / "aetherion.apk"
    if apk_path.exists():
        return FileResponse(str(apk_path), media_type="application/vnd.android.package-archive", filename="aetherion.apk")
    return {"error": "APK not found"}

@app.get("/servolocal_user.apk")
async def download_user_apk():
    apk_path = FRONTEND_DIR / "servolocal_user.apk"
    if apk_path.exists():
        return FileResponse(str(apk_path), media_type="application/vnd.android.package-archive", filename="servolocal_user.apk")
    return {"error": "User APK not found"}

@app.get("/servolocal_technician.apk")
async def download_tech_apk():
    apk_path = FRONTEND_DIR / "servolocal_technician.apk"
    if apk_path.exists():
        return FileResponse(str(apk_path), media_type="application/vnd.android.package-archive", filename="servolocal_technician.apk")
    return {"error": "Technician APK not found"}

@app.get("/technician")
async def serve_tech():
    path = FRONTEND_DIR / "technician.html"
    if path.exists():
        return FileResponse(str(path))
    return FileResponse(str(FRONTEND_DIR / "index.html"))

@app.get("/admin")
async def serve_admin():
    path = FRONTEND_DIR / "admin.html"
    if path.exists():
        return FileResponse(str(path))
    return FileResponse(str(FRONTEND_DIR / "index.html"))

@app.get("/api/health")
def health_check():
    local_ip = get_local_ip()
    return {
        "status": "healthy",
        "service": "AETHERION Backend",
        "local_ip": local_ip,
        "api_base_url": f"http://{local_ip}:8080",
        "ws_base_url": f"ws://{local_ip}:8080"
    }
