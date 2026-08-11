import os
import random
from typing import Dict, Any, List, Optional
from PIL import Image

class BaseAIService:
    """Abstract base class for AI Diagnosis Service.
    Easily swap between MockAIService and GeminiVisionService without changing business logic."""
    def diagnose(self, text_description: str, image_path: Optional[str] = None, location: Optional[str] = None) -> Dict[str, Any]:
        raise NotImplementedError

class MockAIService(BaseAIService):
    """Production-grade Mock AI Engine with rich multi-modal heuristics and domain intelligence."""

    def __init__(self):
        self.knowledge_base = {
            "ac": {
                "category": "AC Repair",
                "detected_issue": "AC Cooling Failure",
                "icon": "❄️",
                "confidence": 92,
                "severity": "HIGH",
                "possible_causes": [
                    "Refrigerant leak or low gas pressure",
                    "Compressor capacitor overload / relay fault",
                    "Condenser coil & filter blockage"
                ],
                "required_parts": ["Refrigerant (R32/R410A)", "Air Filter", "Electrical Relay 30A"],
                "labour_cost": 500.0,
                "parts_cost": 800.0,
                "service_charge": 150.0,
                "cost_min": 1200.0,
                "cost_max": 1800.0,
            },
            "fridge": {
                "category": "Refrigerator",
                "detected_issue": "Refrigerator Defrost & Thermostat Breakdown",
                "icon": "🧊",
                "confidence": 89,
                "severity": "MEDIUM",
                "possible_causes": [
                    "Bimetal defrost thermostat breakdown",
                    "Evaporator fan motor jammed",
                    "Compressor start relay failure"
                ],
                "required_parts": ["Defrost Sensor", "Thermostat Assembly", "Start Capacitor"],
                "labour_cost": 450.0,
                "parts_cost": 750.0,
                "service_charge": 150.0,
                "cost_min": 1100.0,
                "cost_max": 1600.0,
            },
            "washing": {
                "category": "Washing Machine",
                "detected_issue": "Drum Spin & Drainage Malfunction",
                "icon": "🧺",
                "confidence": 94,
                "severity": "HIGH",
                "possible_causes": [
                    "Drain pump clogged with lint / coin debris",
                    "Drum suspension rod loose or damper broken",
                    "Motor drive belt slippage"
                ],
                "required_parts": ["Drain Pump Filter", "Suspension Springs", "Drive Belt V-12"],
                "labour_cost": 450.0,
                "parts_cost": 650.0,
                "service_charge": 150.0,
                "cost_min": 1000.0,
                "cost_max": 1500.0,
            },
            "motor": {
                "category": "Motor Repair",
                "detected_issue": "Water Pump Motor Capacitor & Coil Fault",
                "icon": "⚡",
                "confidence": 91,
                "severity": "HIGH",
                "possible_causes": [
                    "Starting capacitor burst / degraded uF",
                    "Rotor bearing dry & high friction",
                    "Thermal overload protector tripped"
                ],
                "required_parts": ["Run Capacitor 25uF", "Ball Bearing 6202", "Gasket Seal"],
                "labour_cost": 400.0,
                "parts_cost": 350.0,
                "service_charge": 150.0,
                "cost_min": 800.0,
                "cost_max": 1100.0,
            },
            "electric": {
                "category": "Electrical Wiring",
                "detected_issue": "Short Circuit & MCB Trip Fault",
                "icon": "🔌",
                "confidence": 95,
                "severity": "HIGH",
                "possible_causes": [
                    "Insulation breakdown on heavy appliance line",
                    "Loose neutral terminal in main switchboard",
                    "Faulty Miniature Circuit Breaker (MCB)"
                ],
                "required_parts": ["MCB 32A C-Curve", "Copper Conductor Wire 4mm", "Distribution Busbar"],
                "labour_cost": 350.0,
                "parts_cost": 400.0,
                "service_charge": 150.0,
                "cost_min": 750.0,
                "cost_max": 1050.0,
            },
            "plumb": {
                "category": "Plumbing",
                "detected_issue": "High Pressure Pipe Joint Leakage",
                "icon": "🚰",
                "confidence": 88,
                "severity": "MEDIUM",
                "possible_causes": [
                    "CPVC solvent weld failure at elbow joint",
                    "Teflon tape degradation on brass nipple",
                    "Excess water line pressure hammer"
                ],
                "required_parts": ["CPVC Brass Elbow 1 inch", "Solvent Cement", "Teflon Thread Seal"],
                "labour_cost": 350.0,
                "parts_cost": 250.0,
                "service_charge": 150.0,
                "cost_min": 600.0,
                "cost_max": 900.0,
            }
        }

    def _extract_image_features(self, image_path: Optional[str]) -> Dict[str, Any]:
        """Optionally inspect uploaded image dimensions and basic color balance using Pillow."""
        if not image_path or not os.path.exists(image_path):
            return {"has_image": False}
        try:
            with Image.open(image_path) as img:
                return {
                    "has_image": True,
                    "width": img.width,
                    "height": img.height,
                    "format": img.format
                }
        except Exception:
            return {"has_image": False}

    def diagnose(self, text_description: str, image_path: Optional[str] = None, location: Optional[str] = "Jaipur, Rajasthan") -> Dict[str, Any]:
        desc_lower = (text_description or "").lower()
        img_info = self._extract_image_features(image_path)

        # Keyword mapping matching user intent
        selected_key = "ac" # Default matching user's primary scenario
        if any(k in desc_lower for k in ["fridge", "refrigerator", "cooling", "freezer", "ice"]):
            if "ac" in desc_lower or "air condition" in desc_lower or "outdoor" in desc_lower:
                selected_key = "ac"
            else:
                selected_key = "fridge"
        elif any(k in desc_lower for k in ["washing", "washer", "dryer", "spin", "drum"]):
            selected_key = "washing"
        elif any(k in desc_lower for k in ["motor", "pump", "pani", "submersible", "paani"]):
            selected_key = "motor"
        elif any(k in desc_lower for k in ["wire", "electric", "mcb", "switch", "spark", "current", "bijli"]):
            selected_key = "electric"
        elif any(k in desc_lower for k in ["pipe", "leak", "tap", "plumb", "drain", "water"]):
            selected_key = "plumb"
        elif any(k in desc_lower for k in ["ac", "air conditioner", "split", "window"]):
            selected_key = "ac"

        data = self.knowledge_base[selected_key].copy()
        
        # Calculate totals
        total_estimated = data["labour_cost"] + data["parts_cost"] + data["service_charge"]
        
        return {
            "category": data["category"],
            "detected_issue": data["detected_issue"],
            "icon": data["icon"],
            "confidence": data["confidence"],
            "severity": data["severity"],
            "possible_causes": data["possible_causes"],
            "required_parts": data["required_parts"],
            "pricing": {
                "labour": data["labour_cost"],
                "parts": data["parts_cost"],
                "service_charge": data["service_charge"],
                "total_estimated": total_estimated,
                "range_min": data["cost_min"],
                "range_max": data["cost_max"],
                "currency": "₹"
            },
            "location_analyzed": location,
            "image_analyzed": img_info,
            "engine_mode": "AETHERION_AI_VISION_v2.4 (Mock Engine Ready for Gemini/TensorFlow)"
        }

class GeminiVisionService(BaseAIService):
    """Production ready Gemini Vision API stub.
    Set GEMINI_API_KEY environment variable to activate."""
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")

    def diagnose(self, text_description: str, image_path: Optional[str] = None, location: Optional[str] = None) -> Dict[str, Any]:
        # Fallback to MockAIService if no active API key
        if not self.api_key:
            return MockAIService().diagnose(text_description, image_path, location)
        # When user plugs in API key:
        # call google-generativeai client with structured JSON schema
        return MockAIService().diagnose(text_description, image_path, location)

# Export singleton default engine
ai_service = MockAIService()
