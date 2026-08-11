/**
 * AETHERION - Technician Mobile App Controller
 */

class TechApp {
  constructor() {
    this.techId = 1; // Rahul Kumar
    this.activeJob = null;
    this.socket = new SocketClient('technician', this.techId);
    this.isOnline = true;
    this.recognition = null;
  }

  async init() {
    console.log('🔧 Initializing Technician App...');
    this.socket.connect();
    this.bindSocketEvents();
    this.bindDomEvents();
    this.initSpeechRecognition();
    await this.loadDashboardStats();
  }

  initSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = false;
      this.recognition.lang = 'hi-IN'; // Hindi / Hinglish recognition

      this.recognition.onstart = () => {
        const btn = document.getElementById('voice-speak-btn');
        if (btn) btn.classList.add('recording');
        const statusTxt = document.getElementById('voice-status-text');
        if (statusTxt) statusTxt.textContent = 'Listening... (Speak Hindi/English)';
      };

      this.recognition.onresult = async (event) => {
        const transcript = event.results[0][0].transcript;
        console.log('🗣️ Voice Transcript:', transcript);
        const statusTxt = document.getElementById('voice-status-text');
        if (statusTxt) statusTxt.textContent = `Recognized: "${transcript}"`;
        await this.sendVoiceCommand(transcript);
      };

      this.recognition.onend = () => {
        const btn = document.getElementById('voice-speak-btn');
        if (btn) btn.classList.remove('recording');
      };
    }
  }

  bindSocketEvents() {
    this.socket.on('JOB_CREATED', (data) => {
      console.log('🔔 [TechApp] New incoming job alert:', data);
      if (this.isOnline && data.job) {
        this.showIncomingJobModal(data.job);
      }
    });

    this.socket.on('PAYMENT_SUCCESSFUL', (data) => {
      console.log('💰 [TechApp] Payment received:', data);
      alert(`🎉 Payment of ₹${data.job?.final_amount || 1450} received successfully!`);
      this.loadDashboardStats();
    });
  }

  bindDomEvents() {
    // Online toggle
    const toggleBtn = document.getElementById('tech-online-toggle');
    if (toggleBtn) {
      toggleBtn.addEventListener('change', async (e) => {
        this.isOnline = e.target.checked;
        await ApiClient.post(`/api/technicians/${this.techId}/toggle-status`);
        const statusLabel = document.getElementById('tech-status-label');
        if (statusLabel) statusLabel.textContent = this.isOnline ? 'ONLINE' : 'OFFLINE';
      });
    }

    // Voice speak button
    const voiceBtn = document.getElementById('voice-speak-btn');
    if (voiceBtn) {
      voiceBtn.addEventListener('click', () => {
        if (this.recognition) {
          this.recognition.start();
        } else {
          // Fallback simulation prompt
          const mockVoice = prompt('Enter technician voice command (Hinglish/English):', 'Main location par pahunch gaya hoon');
          if (mockVoice) this.sendVoiceCommand(mockVoice);
        }
      });
    }

    // Quick Voice action buttons
    document.querySelectorAll('.voice-chip').forEach(chip => {
      chip.addEventListener('click', () => {
        const cmd = chip.getAttribute('data-cmd');
        this.sendVoiceCommand(cmd);
      });
    });

    // Proof submit form
    const proofForm = document.getElementById('proof-upload-form');
    if (proofForm) {
      proofForm.addEventListener('submit', (e) => {
        e.preventDefault();
        this.handleUploadProof();
      });
    }
  }

  async loadDashboardStats() {
    try {
      const res = await ApiClient.get(`/api/technicians/${this.techId}/dashboard-stats`);
      if (res) {
        document.getElementById('tech-earnings-today').textContent = `₹${res.today_earnings?.toLocaleString()}`;
        document.getElementById('tech-earnings-week').textContent = `₹${res.week_earnings?.toLocaleString()}`;
        document.getElementById('tech-earnings-month').textContent = `₹${res.month_earnings?.toLocaleString()}`;
        document.getElementById('tech-today-jobs-count').textContent = res.today_jobs;
        document.getElementById('tech-pending-count').textContent = res.pending_requests;
        document.getElementById('tech-rating-val').textContent = `⭐ ${res.rating}`;

        if (res.active_jobs && res.active_jobs.length > 0) {
          const activeJobId = res.active_jobs[0].id;
          const jobRes = await ApiClient.get(`/api/jobs/${activeJobId}`);
          if (jobRes) {
            this.activeJob = jobRes;
            this.renderActiveRepairView();
          }
        }
      }
    } catch (err) {
      console.error('Failed to load tech stats:', err);
    }
  }

  showIncomingJobModal(job) {
    const modal = document.getElementById('incoming-job-modal');
    if (!modal) return;

    document.getElementById('incoming-job-title').textContent = job.title;
    document.getElementById('incoming-job-cust').textContent = job.user_name || 'Priyanshu';
    document.getElementById('incoming-job-dist').textContent = `📍 ${job.technician_distance || 2.4} km away`;
    document.getElementById('incoming-job-cost').textContent = `₹${job.estimated_cost_min} – ₹${job.estimated_cost_max}`;

    modal.style.display = 'flex';

    document.getElementById('btn-accept-job').onclick = async () => {
      modal.style.display = 'none';
      await this.updateStatus(job.id, 'ACCEPTED');
      this.activeJob = job;
      this.renderActiveRepairView();
    };

    document.getElementById('btn-reject-job').onclick = () => {
      modal.style.display = 'none';
    };
  }

  async updateStatus(jobId, newStatus) {
    try {
      const res = await ApiClient.post(`/api/jobs/${jobId}/status`, {
        status: newStatus,
        technician_id: this.techId
      });
      if (res && res.job) {
        this.activeJob = res.job;
        this.renderActiveRepairView();
      }
    } catch (err) {
      console.error('Error updating status:', err);
    }
  }

  async sendVoiceCommand(transcript) {
    if (!this.activeJob) return;
    try {
      const res = await ApiClient.post('/api/voice/process', {
        job_id: this.activeJob.id,
        transcript: transcript
      });
      if (res && res.job) {
        this.activeJob = res.job;
        this.renderActiveRepairView();
        const toast = document.getElementById('voice-toast');
        if (toast) {
          toast.textContent = `🎙 Voice Action: ${res.parsed.status_message}`;
          toast.style.display = 'block';
          setTimeout(() => { toast.style.display = 'none'; }, 3000);
        }
      }
    } catch (err) {
      console.error('Voice command error:', err);
    }
  }

  renderActiveRepairView() {
    if (!this.activeJob) return;
    const job = this.activeJob;

    document.getElementById('active-job-cust-name').textContent = job.user_name || 'Priyanshu';
    document.getElementById('active-job-problem').textContent = job.title;
    document.getElementById('active-job-code').textContent = job.job_code;
    document.getElementById('active-job-status-pill').textContent = job.status.replace(/_/g, ' ');

    // Stepper active states
    const stepMap = {
      'ACCEPTED': 1,
      'ON_THE_WAY': 2,
      'ARRIVED': 3,
      'REPAIRING': 4,
      'COMPLETED': 5
    };
    const currentStep = stepMap[job.status] || 1;

    ['btn-step-ontheway', 'btn-step-arrived', 'btn-step-repairing', 'btn-step-proof'].forEach((btnId, idx) => {
      const btn = document.getElementById(btnId);
      if (btn) {
        if (idx + 1 < currentStep) {
          btn.style.backgroundColor = 'var(--muted-green-light)';
          btn.style.color = 'var(--primary-dark-green)';
        } else if (idx + 1 === currentStep) {
          btn.style.backgroundColor = 'var(--accent-brown)';
          btn.style.color = '#FFFFFF';
        }
      }
    });

    // If repairing is in progress, show proof form
    const proofCard = document.getElementById('tech-proof-upload-card');
    if (proofCard) {
      proofCard.style.display = (job.status === 'REPAIRING' || job.status === 'COMPLETED') ? 'block' : 'none';
    }
  }

  async handleUploadProof() {
    if (!this.activeJob) return;
    const formData = new FormData();
    formData.append('parts_used', document.getElementById('proof-parts-input')?.value || 'Air Filter, Relay');

    const beforeFile = document.getElementById('proof-before-file')?.files[0];
    const afterFile = document.getElementById('proof-after-file')?.files[0];

    if (beforeFile) formData.append('before_image', beforeFile);
    if (afterFile) formData.append('after_image', afterFile);

    try {
      const res = await ApiClient.post(`/api/jobs/${this.activeJob.id}/proof`, formData);
      if (res && res.job) {
        this.activeJob = res.job;
        alert('✅ Repair proof submitted! The customer has been prompted for payment.');
        this.renderActiveRepairView();
        this.loadDashboardStats();
      }
    } catch (err) {
      console.error('Proof upload failed:', err);
    }
  }
}

window.TechApp = TechApp;
