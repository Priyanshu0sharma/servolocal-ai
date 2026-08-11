# 🏛️ AETHERION / ServoLocal — System Architecture & Production Blueprint

This document details the software architecture, database design, real-time communication protocol, and the **step-by-step roadmap to scale this prototype into a real-world enterprise application**.

---

## 1. High-Level Architecture

The platform follows a **Modular Clean Architecture** divided into Client Presentation, API Gateway & Business Core, Real-Time Event Bus, and Persistent Storage.

```mermaid
flowchart TD
    subgraph Clients["📱 Client Layer"]
        UserWeb["User Web / Mobile Portal\n(HTML5 / JS / CSS)"]
        TechWeb["Technician Portal\n(Mobile Web)"]
        AdminWeb["Admin Command Center\n(Desktop Web)"]
        FlutterApp["Flutter Native Mobile App\n(Android / iOS)"]
    end

    subgraph Gateway["🌐 API & Real-Time Gateway (FastAPI)"]
        RouterAuth["/api/auth\n(Authentication & Profiles)"]
        RouterDiag["/api/diagnose\n(AI Vision & Audio Analysis)"]
        RouterJobs["/api/jobs\n(Job Lifecycle & Handover)"]
        RouterTech["/api/technicians\n(Matchmaking & Stats)"]
        RouterPay["/api/payments\n(UPI & Checkout)"]
        RouterAdmin["/api/admin\n(Analytics & Operations)"]
        WSManager["WebSocket Connection Manager\n(/ws/{client_type}/{id})"]
    end

    subgraph Engines["⚙️ Core Business Intelligence Engines"]
        AIEngine["AI Multi-Modal Engine\n(Gemini 2.0 / Vision / NLP)"]
        MatchEngine["Proximity Matchmaking Engine\n(Haversine + Skill Matrix)"]
        PriceEngine["Dynamic Pricing Engine\n(Labour + Parts + Surge)"]
        VoiceEngine["Technician Voice Assistant\n(Hindi / Hinglish / English)"]
    end

    subgraph DataLayer["💾 Persistent Data Layer"]
        DB[(SQLite / PostgreSQL ORM)]
        FileSystem[(Uploads & Media Proofs)]
    end

    Clients <-->|REST HTTP & WebSockets| Gateway
    Gateway --> Engines
    Gateway --> DataLayer
```

---

## 2. Database Schema & Entity Relationships

The data layer uses SQLAlchemy ORM models capable of running on SQLite for local prototypes and PostgreSQL in production without schema modifications.

```mermaid
erDiagram
    USERS ||--o{ JOBS : "places"
    USERS ||--o| TECHNICIANS : "has profile"
    TECHNICIANS ||--o{ JOBS : "fulfills"
    CATEGORIES ||--o{ JOBS : "categorizes"
    USERS ||--o{ NOTIFICATIONS : "receives"

    USERS {
        int id PK
        string name
        string email UK
        string phone
        string role "user | technician | admin"
        string avatar
        string address
        datetime created_at
    }

    TECHNICIANS {
        int id PK
        int user_id FK
        string name
        string phone
        string speciality
        json skills
        int experience_years
        float rating
        int reviews_count
        float visit_charge
        boolean is_online
        boolean is_verified
        float current_lat
        float current_lng
        float distance_km
        float total_earnings
        float today_earnings
        int completed_jobs_count
    }

    JOBS {
        int id PK
        string job_code UK "#1021"
        int user_id FK
        int technician_id FK
        string category
        string title
        text description
        string media_url
        int ai_confidence
        string severity
        json possible_causes
        json required_parts
        float estimated_cost_min
        float estimated_cost_max
        float labour_cost
        float parts_cost
        float service_charge
        float final_amount
        string status "CREATED|ACCEPTED|ON_THE_WAY|ARRIVED|REPAIRING|COMPLETED|PAID"
        string address
        float user_lat
        float user_lng
        string before_image
        string after_image
        json parts_used
        text customer_signature
        string payment_method "UPI|CARD|CASH"
        string payment_status "PENDING|SUCCESS"
        string transaction_id
        float rating
        text review_comment
        datetime created_at
        datetime accepted_at
        datetime arrived_at
        datetime completed_at
    }

    CATEGORIES {
        int id PK
        string name UK
        string icon
        float base_price
        string description
    }

    NOTIFICATIONS {
        int id PK
        string target_role "user | technician | admin | all"
        int user_id
        string title
        text message
        string type "info | alert | success"
        datetime created_at
        boolean is_read
    }
```

---

## 3. Real-Time Event-Driven WebSocket Protocol

The system utilizes bi-directional WebSockets to ensure zero-latency synchronization across customer, technician, and operations admin screens.

### WebSocket Connection Endpoint:
```
ws://<server-host>:8080/ws/{client_type}/{client_id}
```
- `client_type`: `user`, `technician`, or `admin`
- `client_id`: User ID, Technician ID, or Admin Session ID

### Event Types & Broadcast Matrix:
| Event Type | Trigger | Recipients |
| :--- | :--- | :--- |
| `JOB_CREATED` | Customer books diagnostic/repair | Assigned Technician + All Admins |
| `STATUS_UPDATED` | Tech changes status (`ACCEPTED`, `ON_THE_WAY`, `ARRIVED`, `REPAIRING`) | Customer + Operations Admin |
| `PROOF_SUBMITTED` | Tech uploads before/after photos & signature | Customer + Operations Admin |
| `PAYMENT_SUCCESSFUL` | Customer completes UPI/Card checkout | Customer + Assigned Technician + Admin |

---

## 4. Production Transition Plan (From Prototype to Real App)

To deploy Aetherion as a full-scale commercial application, transition the prototype components according to the following architecture roadmap:

### 1. Database & Persistence
- **Current**: SQLite database (`backend/aetherion.db`).
- **Production Target**: **PostgreSQL 16** hosted on **AWS RDS / Supabase**.
- **Steps**:
  1. Change `DATABASE_URL` in `.env` to `postgresql://user:pass@host:5432/aetherion`.
  2. Integrate **Alembic** for automated schema migrations (`alembic init alembic`).
  3. Add indexing on `(user_lat, user_lng)` with **PostGIS** extension for hyper-precise spatial queries.

### 2. Multi-Modal AI Diagnostics Engine
- **Current**: `backend/services/ai_engine.py` (Mock engine with rich heuristic rules).
- **Production Target**: **Google Gemini 2.0 Flash / Pro Multimodal Vision API**.
- **Implementation**:
  ```python
  import google.generativeai as genai

  genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
  model = genai.GenerativeModel("gemini-2.0-flash")

  prompt = """
  You are an expert master technician. Analyze the appliance image and description.
  Return STRICT JSON with keys: category, detected_issue, confidence (0-100),
  severity (HIGH/MEDIUM/LOW), possible_causes (list), required_parts (list),
  estimated_labour_cost, estimated_parts_cost.
  """
  response = model.generate_content([prompt, image_input, description])
  ```

### 3. Payment Gateway & Instant Settlement
- **Current**: Simulated UPI payment modal.
- **Production Target**: **Razorpay** / **Cashfree** / **Stripe**.
- **Implementation**:
  1. Customer initiates order &rarr; Backend creates Razorpay Order ID via API.
  2. Mobile/Web client opens native Razorpay Checkout SDK (UPI Intent, Cards, NetBanking).
  3. Webhook listener endpoint (`/api/payments/webhook`) validates cryptographic signature (`X-Razorpay-Signature`) and auto-marks the job as `PAID`.

### 4. Distributed Real-Time Event Bus
- **Current**: In-memory Python `ConnectionManager`.
- **Production Target**: **Redis Pub/Sub** or **AWS API Gateway WebSockets**.
- **Benefit**: Allows scaling backend across multiple load-balanced instances/containers without losing WebSocket state.

### 5. Media & Proof Storage
- **Current**: Local `backend/uploads/` directory.
- **Production Target**: **AWS S3** / **Cloudflare R2** with CloudFront CDN.
- **Implementation**: Upload images directly via pre-signed S3 URLs to reduce server bandwidth.

### 6. Push Notifications & SMS
- **Current**: In-app WebSocket events.
- **Production Target**:
  - **Firebase Cloud Messaging (FCM)** for background push notifications when app is closed.
  - **WhatsApp Business API (Twilio / Gupshup)** for automated booking confirmations and digital invoices.

---

## 5. Security & Production Checklist

- [ ] **Authentication**: Implement JWT authentication with refresh tokens and phone OTP verification (Twilio / MSG91 / Firebase Auth).
- [ ] **Rate Limiting**: Add `slowapi` or Redis-based rate limiting on `/api/auth/login` and `/api/diagnose`.
- [ ] **CORS Security**: Restrict `allow_origins` in `backend/main.py` from `["*"]` to verified production domain names.
- [ ] **Role-Based Access Control (RBAC)**: Ensure technician endpoints verify `current_user.role == 'technician'`.
- [ ] **Data Encryption**: Enforce HTTPS / TLS 1.3 across all client-server communications and encrypt sensitive customer addresses at rest.
