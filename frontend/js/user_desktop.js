/**
 * AETHERION - User Desktop Portal Controller
 */

class UserDesktopApp {
  constructor() {
    this.userId = 1;
    this.socket = new SocketClient('user', this.userId);
    this.activeJob = null;
    this.currentDiagnosis = null;
    this.selectedPaymentMethod = 'UPI';
  }

  async init() {
    console.log('💻 Initializing User Desktop Portal...');
    this.socket.connect();
    this.bindSocketEvents();
    this.bindDomEvents();
    await this.loadActiveJob();
    await this.loadNearbyTechnicians();
  }

  bindSocketEvents() {
    this.socket.on('*', (data) => {
      console.log('⚡ [UserDesktop] WebSocket event received:', data);
      this.loadActiveJob();
    });
  }

  bindDomEvents() {
    // Run AI Diagnosis Button
    document.getElementById('btn-desktop-diag')?.addEventListener('click', () => this.handleRunDiagnosis());

    // Preset pills
    document.querySelectorAll('.preset-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const descInput = document.getElementById('desktop-desc-input');
        if (descInput) descInput.value = btn.getAttribute('data-desc');
      });
    });

    // Dropzone upload trigger
    const dropzone = document.getElementById('desktop-upload-dropzone');
    const fileInput = document.getElementById('desktop-file-input');
    if (dropzone && fileInput) {
      dropzone.addEventListener('click', () => fileInput.click());
      fileInput.addEventListener('change', () => {
        if (fileInput.files[0]) {
          document.getElementById('upload-status-text').textContent = `Selected: ${fileInput.files[0].name}`;
        }
      });
    }

    // Payment button
    document.getElementById('desktop-pay-btn')?.addEventListener('click', () => this.handlePayment());
  }

  async loadActiveJob() {
    try {
      const res = await ApiClient.get(`/api/jobs/user/${this.userId}/active`);
      if (res && res.job) {
        this.activeJob = res.job;
        this.renderActiveServiceRadar(res.job);
      }
    } catch (e) {
      console.error('Error loading active job:', e);
    }
  }

  renderActiveServiceRadar(job) {
    const banner = document.getElementById('desktop-active-job-container');
    if (!banner) return;

    if (!job || ['COMPLETED', 'PAID', 'CANCELLED'].includes(job.status)) {
      banner.innerHTML = `
        <div style="text-align: center; padding: 30px; background: var(--bg-light-cream); border-radius: var(--radius-md); border: 1px dashed var(--border-medium);">
          <div style="font-size: 32px; margin-bottom: 8px;">❄️</div>
          <h4 style="color: var(--primary-dark-green); margin-bottom: 4px;">No Active Repair Service</h4>
          <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 12px;">Use the AI diagnostic scanner on the left to report any issue.</p>
        </div>
      `;
      return;
    }

    const steps = ['ACCEPTED', 'ON_THE_WAY', 'ARRIVED', 'REPAIRING', 'COMPLETED'];
    const currentIdx = steps.indexOf(job.status);

    banner.innerHTML = `
      <div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
          <div>
            <span class="badge badge-brown" style="font-size: 11px; margin-bottom: 4px;">${job.job_code}</span>
            <h3 style="font-size: 18px; font-weight: 800; color: var(--primary-dark-green);">${job.title}</h3>
          </div>
          <span class="badge badge-green"><span class="pulse-dot"></span> ${job.status.replace(/_/g, ' ')}</span>
        </div>

        <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 16px; background: var(--bg-soft-beige); padding: 12px 16px; border-radius: var(--radius-md);">
          <img src="${job.technician_avatar || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'}" style="width: 48px; height: 48px; border-radius: 50%; border: 2px solid var(--accent-brown);" alt="Tech">
          <div style="flex: 1;">
            <div style="font-size: 15px; font-weight: 700; color: var(--text-primary);">${job.technician_name}</div>
            <div style="font-size: 12px; color: var(--muted-green); font-weight: 600;">⭐ ${job.technician_rating || 4.8} • ${job.technician_distance || 2.4} km away</div>
          </div>
          <a href="tel:+919876543210" class="btn btn-sm btn-brown">📞 Call Tech</a>
        </div>

        <!-- Progress Steps -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 16px; position: relative;">
          ${steps.map((s, idx) => `
            <div style="display: flex; flex-direction: column; align-items: center; gap: 4px; flex: 1;">
              <div style="width: 24px; height: 24px; border-radius: 50%; background: ${idx <= currentIdx ? 'var(--primary-dark-green)' : '#E2E8F0'}; color: white; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold;">
                ${idx < currentIdx ? '✓' : idx + 1}
              </div>
              <span style="font-size: 10px; font-weight: ${idx === currentIdx ? '700' : '500'}; color: ${idx === currentIdx ? 'var(--primary-dark-green)' : 'var(--text-muted)'}; text-align: center;">
                ${s.replace(/_/g, ' ')}
              </span>
            </div>
          `).join('')}
        </div>

        <!-- Live Map Radar -->
        <div class="live-map-desktop-frame">
          <div style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; flex-direction: column; gap: 6px;">
            <span style="font-size: 28px;">🛵 ──────── 📍 ──────── 🏠</span>
            <span style="font-size: 12px; font-weight: 700; color: var(--primary-dark-green);">Live GPS Route Tracking Active • ETA: 8 mins</span>
          </div>
        </div>

        ${job.status === 'COMPLETED' ? `
          <div style="background: #E8F5E9; border: 1.5px solid #2E7D32; border-radius: var(--radius-md); padding: 16px; margin-top: 14px;">
            <h4 style="color: #1B4332; margin-bottom: 6px;">🎉 Repair Completed by ${job.technician_name}</h4>
            <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 12px;">Total Bill: <b>₹${job.final_amount}</b> (Labour ₹${job.labour_cost} + Parts ₹${job.parts_cost} + Service ₹${job.service_charge})</p>
            <button class="btn btn-block btn-brown" onclick="window.userDesktopApp.handlePayment()">💳 Pay ₹${job.final_amount} via UPI / Card</button>
          </div>
        ` : ''}
      </div>
    `;
  }

  async handleRunDiagnosis() {
    const desc = document.getElementById('desktop-desc-input')?.value || 'AC cooling nahi kar raha';
    const loader = document.getElementById('desktop-diag-loader');
    const resultBox = document.getElementById('desktop-ai-result-box');

    if (loader) loader.style.display = 'block';
    if (resultBox) resultBox.style.display = 'none';

    try {
      const formData = new FormData();
      formData.append('description', desc);
      formData.append('location', 'Vaishali Nagar, Jaipur, Rajasthan');

      const fileInput = document.getElementById('desktop-file-input');
      if (fileInput && fileInput.files[0]) {
        formData.append('media', fileInput.files[0]);
      }

      await new Promise(r => setTimeout(r, 1000));
      const res = await ApiClient.post('/api/diagnose', formData);

      if (res && res.diagnosis) {
        this.currentDiagnosis = res.diagnosis;
        this.renderAIDiagnosisResult(res.diagnosis);
        if (loader) loader.style.display = 'none';
        if (resultBox) resultBox.style.display = 'block';
      }
    } catch (e) {
      console.error('Diagnosis failed:', e);
      if (loader) loader.style.display = 'none';
      alert('AI diagnosis failed');
    }
  }

  renderAIDiagnosisResult(d) {
    document.getElementById('res-issue-title').innerHTML = `${d.icon} ${d.detected_issue}`;
    document.getElementById('res-conf-badge').textContent = `${d.confidence}% Confidence`;
    document.getElementById('res-sev-badge').textContent = `Severity: ${d.severity}`;
    document.getElementById('res-cost-val').textContent = `₹${d.pricing.range_min.toLocaleString()} – ₹${d.pricing.range_max.toLocaleString()}`;

    const causesEl = document.getElementById('res-causes-list');
    if (causesEl) {
      causesEl.innerHTML = (d.possible_causes || []).map(c => `<li>${c}</li>`).join('');
    }

    const partsEl = document.getElementById('res-parts-chips');
    if (partsEl) {
      partsEl.innerHTML = (d.required_parts || []).map(p => `<span class="badge badge-brown" style="font-size: 11px;">${p}</span>`).join(' ');
    }
  }

  async loadNearbyTechnicians() {
    try {
      const res = await ApiClient.get('/api/technicians/nearby?category=AC+Repair');
      const container = document.getElementById('desktop-technicians-grid');
      if (!container || !res || !res.technicians) return;

      container.innerHTML = res.technicians.map(t => `
        <div class="tech-card-desktop animate-fade-in">
          <div>
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
              <img src="${t.avatar}" style="width: 54px; height: 54px; border-radius: 50%; object-fit: cover; border: 2px solid var(--accent-brown);" alt="${t.name}">
              <div>
                <h4 style="font-size: 16px; font-weight: 700; color: var(--primary-dark-green);">${t.name}</h4>
                <div style="font-size: 12px; color: #D97706; font-weight: 700;">⭐ ${t.rating} <span style="color: var(--text-muted); font-size: 11px;">(${t.reviews_count} reviews)</span></div>
                <div style="font-size: 12px; color: var(--muted-green); font-weight: 600;">${t.speciality}</div>
              </div>
            </div>
            <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--text-secondary); margin-bottom: 16px; background: var(--bg-soft-beige); padding: 8px 12px; border-radius: var(--radius-sm);">
              <span>📍 Distance: <b>${t.distance_km} km</b></span>
              <span>Visit Charge: <b>₹${t.visit_charge}</b></span>
            </div>
          </div>
          <button class="btn btn-block btn-brown" onclick="window.userDesktopApp.selectTechnician(${t.id}, '${t.name}')">
            Book Technician
          </button>
        </div>
      `).join('');
    } catch (e) {
      console.error('Error fetching technicians:', e);
    }
  }

  async selectTechnician(techId, techName) {
    const diag = this.currentDiagnosis || {
      category: 'AC Repair',
      detected_issue: 'AC Cooling Failure',
      severity: 'HIGH',
      confidence: 92,
      possible_causes: ['Refrigerant issue', 'Compressor overload', 'Filter blockage'],
      required_parts: ['Refrigerant', 'Filter', 'Electrical relay'],
      pricing: { labour: 500, parts: 800, service_charge: 150, range_min: 1200, range_max: 1800 }
    };

    try {
      const res = await ApiClient.post('/api/jobs', {
        user_id: this.userId,
        technician_id: techId,
        category: diag.category,
        title: diag.detected_issue,
        description: document.getElementById('desktop-desc-input')?.value || 'AC cooling problem',
        ai_confidence: diag.confidence,
        severity: diag.severity,
        possible_causes: diag.possible_causes,
        required_parts: diag.required_parts,
        estimated_cost_min: diag.pricing.range_min,
        estimated_cost_max: diag.pricing.range_max,
        labour_cost: diag.pricing.labour,
        parts_cost: diag.pricing.parts,
        service_charge: diag.pricing.service_charge,
        final_amount: diag.pricing.labour + diag.pricing.parts + diag.pricing.service_charge,
        address: 'Vaishali Nagar, Jaipur, Rajasthan'
      });

      if (res && res.job) {
        this.activeJob = res.job;
        this.renderActiveServiceRadar(res.job);
        window.scrollTo({ top: 0, behavior: 'smooth' });
        alert(`🎉 Technician ${techName} assigned! Tracking live updates.`);
      }
    } catch (e) {
      console.error('Failed to select tech:', e);
    }
  }

  async handlePayment() {
    if (!this.activeJob) return;
    try {
      const res = await ApiClient.post('/api/payments/process', {
        job_id: this.activeJob.id,
        payment_method: 'UPI',
        amount: this.activeJob.final_amount || 1450
      });

      if (res && res.success) {
        alert(`✅ Payment Successful!\nTransaction ID: ${res.transaction_id}\nAmount: ₹${res.amount}`);
        this.loadActiveJob();
      }
    } catch (e) {
      console.error('Payment error:', e);
    }
  }
}

window.userDesktopApp = new UserDesktopApp();
