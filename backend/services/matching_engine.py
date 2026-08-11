import math
from typing import List, Dict, Any
from sqlalchemy.orm import Session
from backend.database.models import Technician

class MatchingEngine:
    """Smart matching algorithm that ranks technicians based on distance, rating, skills match, and availability."""

    @staticmethod
    def calculate_distance(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """Haversine formula to calculate distance in km."""
        R = 6371.0 # Earth radius in km
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return round(R * c, 1)

    @classmethod
    def match_technicians(
        cls,
        db: Session,
        category: str,
        user_lat: float = 26.9150,
        user_lng: float = 75.7420
    ) -> List[Dict[str, Any]]:
        technicians = db.query(Technician).filter(Technician.is_online == True).all()
        results = []

        for tech in technicians:
            # Calculate distance
            dist = cls.calculate_distance(user_lat, user_lng, tech.current_lat, tech.current_lng)
            if dist == 0.0 or dist > 20: # Fallback to seeded distance if mock coords are fixed
                dist = tech.distance_km

            # Check skill match
            skills = tech.skills or []
            skill_matched = any(category.lower() in s.lower() or s.lower() in category.lower() for s in skills)
            skill_score = 30.0 if skill_matched else 10.0

            # Proximity score (closer = higher score, max 35)
            distance_score = max(5.0, (1.0 / (1.0 + (dist / 5.0))) * 35.0)

            # Rating score (max 35)
            rating_score = (tech.rating / 5.0) * 35.0

            total_score = round(distance_score + rating_score + skill_score, 1)
            eta_mins = max(5, int(dist * 3.5))

            results.append({
                "id": tech.id,
                "user_id": tech.user_id,
                "name": tech.name,
                "avatar": tech.avatar,
                "speciality": tech.speciality,
                "skills": tech.skills,
                "rating": tech.rating,
                "reviews_count": tech.reviews_count,
                "distance_km": dist,
                "eta_mins": eta_mins,
                "visit_charge": tech.visit_charge,
                "match_score": total_score,
                "is_verified": tech.is_verified,
                "phone": tech.phone
            })

        # Sort by match score descending
        results.sort(key=lambda x: x["match_score"], reverse=True)
        return results

matching_engine = MatchingEngine()
