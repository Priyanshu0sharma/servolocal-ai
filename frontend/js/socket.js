/**
 * AETHERION - Real-time WebSocket Client
 */

class SocketClient {
  constructor(clientType = 'user', clientId = '1') {
    this.clientType = clientType;
    this.clientId = clientId;
    this.socket = null;
    this.listeners = {};
    this.reconnectTimer = null;
    this.isConnected = false;
  }

  connect() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws/${this.clientType}/${this.clientId}`;

    console.log(`📡 Connecting to WebSocket: ${wsUrl}`);
    try {
      this.socket = new WebSocket(wsUrl);

      this.socket.onopen = () => {
        console.log('✅ WebSocket Connected!');
        this.isConnected = true;
        this.emit('connected', { status: 'connected' });
      };

      this.socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          console.log('📨 WebSocket Message Received:', data);
          if (data.type) {
            this.emit(data.type, data);
          }
          this.emit('*', data);
        } catch (err) {
          console.warn('Non-JSON WS message:', event.data);
        }
      };

      this.socket.onclose = () => {
        console.log('🔌 WebSocket Disconnected. Reconnecting in 2s...');
        this.isConnected = false;
        this.emit('disconnected', { status: 'disconnected' });
        clearTimeout(this.reconnectTimer);
        this.reconnectTimer = setTimeout(() => this.connect(), 2000);
      };

      this.socket.onerror = (err) => {
        console.error('⚠️ WebSocket Error:', err);
      };
    } catch (e) {
      console.error('Socket init error:', e);
    }
  }

  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }

  off(event, callback) {
    if (!this.listeners[event]) return;
    this.listeners[event] = this.listeners[event].filter(cb => cb !== callback);
  }

  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(cb => cb(data));
    }
  }

  send(data) {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.send(typeof data === 'string' ? data : JSON.stringify(data));
    }
  }
}

window.SocketClient = SocketClient;
