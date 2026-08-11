import re
from typing import Dict, Any

class VoiceEngine:
    """Voice status update parser supporting Hinglish and Hindi commands."""

    STATUS_PATTERNS = {
        "ARRIVED": [
            r"pahunch gaya",
            r"pahuch gaya",
            r"arrived",
            r"location par hu",
            r"location par hoon",
            r"ghar pahunch gaya",
            r"gate par hu"
        ],
        "ON_THE_WAY": [
            r"raste me",
            r"raste mein",
            r"on the way",
            r"nikal gaya",
            r"nikal raha",
            r"coming"
        ],
        "REPAIRING": [
            r"repair shuru",
            r"kaam shuru",
            r"starting repair",
            r"repairing",
            r"checking problem",
            r"inspection"
        ],
        "COMPLETED": [
            r"repair ho gaya",
            r"kaam ho gaya",
            r"theek ho gaya",
            r"completed",
            r"done",
            r"finished",
            r"repair done"
        ]
    }

    @classmethod
    def process_voice_transcript(cls, transcript: str) -> Dict[str, Any]:
        cleaned = transcript.strip().lower()
        
        detected_status = None
        for status, patterns in cls.STATUS_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, cleaned):
                    detected_status = status
                    break
            if detected_status:
                break

        status_messages = {
            "ARRIVED": "Technician has arrived at your location.",
            "ON_THE_WAY": "Technician is on the way to your location.",
            "REPAIRING": "Technician has started inspection and repair.",
            "COMPLETED": "Repair successfully completed. Ready for digital proof & payment."
        }

        return {
            "original_transcript": transcript,
            "detected_status": detected_status,
            "recognized": detected_status is not None,
            "status_message": status_messages.get(detected_status, "Status updated.")
        }

voice_engine = VoiceEngine()
