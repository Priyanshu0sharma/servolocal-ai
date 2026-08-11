from typing import Dict, Any, List

class PricingEngine:
    """Transparent pricing calculation engine for services, parts, and labour."""

    SERVICE_BASE_FEE = 150.0

    @classmethod
    def calculate_bill(
        cls,
        labour_cost: float,
        parts_cost: float,
        service_charge: float = 150.0,
        discount: float = 0.0
    ) -> Dict[str, Any]:
        subtotal = labour_cost + parts_cost + service_charge
        final_total = max(0.0, subtotal - discount)

        return {
            "labour": labour_cost,
            "parts": parts_cost,
            "service_charge": service_charge,
            "subtotal": subtotal,
            "discount": discount,
            "total_amount": round(final_total, 2),
            "currency": "₹",
            "formatted_total": f"₹{int(final_total):,}"
        }

pricing_engine = PricingEngine()
