@echo off
title AETHERION Backend Server & Presentation Hub
echo =====================================================================
echo               AETHERION / SERVOLOCAL BACKEND SERVER
echo         AI-Powered On-Demand Repair Service Connected Platform
echo =====================================================================
echo.
echo [1/2] Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not found in PATH!
    pause
    exit /b 1
)

echo [2/2] Starting FastAPI Server on http://0.0.0.0:8080 ...
echo.
echo  -------------------------------------------------------------
echo   Presentation Hub (3-in-1):   http://localhost:8080/
echo   User App (Mobile View):      http://localhost:8080/user
echo   User App (Desktop View):     http://localhost:8080/user-desktop
echo   Technician App:              http://localhost:8080/technician
echo   Admin Dashboard:             http://localhost:8080/admin
echo   Interactive API Docs:        http://localhost:8080/docs
echo  -------------------------------------------------------------
echo.
echo Press Ctrl+C anytime to stop the server.
echo.

python -m uvicorn backend.main:app --host 0.0.0.0 --port 8080 --reload
pause
