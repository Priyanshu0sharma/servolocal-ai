import json
from typing import Dict, List, Any
from fastapi import WebSocket

class ConnectionManager:
    """Manages active WebSocket connections for Users, Technicians, and Admins with zero latency broadcast."""

    def __init__(self):
        # Maps client_type -> {client_id: [WebSocket]}
        self.active_connections: Dict[str, Dict[str, List[WebSocket]]] = {
            "user": {},
            "technician": {},
            "admin": {},
            "all": {}
        }

    async def connect(self, websocket: WebSocket, client_type: str, client_id: str):
        await websocket.accept()
        if client_type not in self.active_connections:
            self.active_connections[client_type] = {}
        
        client_id_str = str(client_id)
        if client_id_str not in self.active_connections[client_type]:
            self.active_connections[client_type][client_id_str] = []
        
        self.active_connections[client_type][client_id_str].append(websocket)
        print(f"[WebSocket Connected] Type: {client_type}, ID: {client_id}")

    def disconnect(self, websocket: WebSocket, client_type: str, client_id: str):
        client_id_str = str(client_id)
        if client_type in self.active_connections and client_id_str in self.active_connections[client_type]:
            if websocket in self.active_connections[client_type][client_id_str]:
                self.active_connections[client_type][client_id_str].remove(websocket)
        print(f"[WebSocket Disconnected] Type: {client_type}, ID: {client_id}")

    async def send_personal_message(self, message: Dict[str, Any], client_type: str, client_id: str):
        client_id_str = str(client_id)
        if client_type in self.active_connections and client_id_str in self.active_connections[client_type]:
            payload = json.dumps(message)
            dead_sockets = []
            for ws in self.active_connections[client_type][client_id_str]:
                try:
                    await ws.send_text(payload)
                except Exception:
                    dead_sockets.append(ws)
            for ws in dead_sockets:
                self.active_connections[client_type][client_id_str].remove(ws)

    async def broadcast_to_role(self, message: Dict[str, Any], client_type: str):
        if client_type in self.active_connections:
            payload = json.dumps(message)
            for client_id, ws_list in self.active_connections[client_type].items():
                dead_sockets = []
                for ws in ws_list:
                    try:
                        await ws.send_text(payload)
                    except Exception:
                        dead_sockets.append(ws)
                for ws in dead_sockets:
                    ws_list.remove(ws)

    async def broadcast_job_event(self, event_type: str, job_dict: Dict[str, Any]):
        """Broadcasts job lifecycle events to the specific User, Technician, and all Admins."""
        message = {
            "type": event_type,
            "job": job_dict
        }

        # 1. Send to User
        user_id = str(job_dict.get("user_id"))
        if user_id:
            await self.send_personal_message(message, "user", user_id)

        # 2. Send to Technician (if assigned)
        tech_id = str(job_dict.get("technician_id"))
        if tech_id:
            await self.send_personal_message(message, "technician", tech_id)
        else:
            # Broadcast to all online technicians if new unassigned job
            await self.broadcast_to_role(message, "technician")

        # 3. Send to all Admins
        await self.broadcast_to_role(message, "admin")

manager = ConnectionManager()
