/**
 * AETHERION - API Client Helper
 * Automatically connects to local backend or Wi-Fi IP
 */

const API_BASE = window.location.origin;

class ApiClient {
  static async get(endpoint) {
    try {
      const res = await fetch(`${API_BASE}${endpoint}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      return await res.json();
    } catch (err) {
      console.error(`API GET error for ${endpoint}:`, err);
      throw err;
    }
  }

  static async post(endpoint, data = {}) {
    try {
      const isFormData = data instanceof FormData;
      const headers = isFormData ? {} : { 'Content-Type': 'application/json' };
      const body = isFormData ? data : JSON.stringify(data);

      const res = await fetch(`${API_BASE}${endpoint}`, {
        method: 'POST',
        headers: headers,
        body: body
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      return await res.json();
    } catch (err) {
      console.error(`API POST error for ${endpoint}:`, err);
      throw err;
    }
  }
}

window.ApiClient = ApiClient;
