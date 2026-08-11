/**
 * AETHERION - Presentation Hub, Device Simulator & Role Portal Controller
 */

class HubController {
  constructor() {
    this.currentMode = 'portal';
    this.localIp = window.location.hostname;
  }

  async init() {
    console.log('🌟 Initializing Aetherion Simulator Hub & Portal...');
    this.fetchHealthInfo();
    this.bindControls();
  }

  async fetchHealthInfo() {
    try {
      const res = await ApiClient.get('/api/health');
      if (res && res.local_ip) {
        this.localIp = res.local_ip;
        const ipDisplay = document.getElementById('hub-ip-display');
        if (ipDisplay) {
          ipDisplay.textContent = `http://${res.local_ip}:8080`;
        }
      }
    } catch (e) {
      console.warn('Health check fetch failed:', e);
    }
  }

  bindControls() {
    // Mode Switcher Tabs
    document.querySelectorAll('.view-tab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const mode = btn.getAttribute('data-mode');
        this.switchStageMode(mode);
      });
    });

    // Portal Role Cards Click
    document.querySelectorAll('.portal-card').forEach(card => {
      card.addEventListener('click', () => {
        const target = card.getAttribute('data-target');
        if (target) {
          this.switchStageMode(target);
        }
      });
    });

    // 3-in-1 Stage Banner Button
    document.getElementById('btn-enter-stage')?.addEventListener('click', () => {
      this.switchStageMode('stage');
    });

    // Copy IP button
    const copyIpBtn = document.getElementById('btn-copy-ip');
    if (copyIpBtn) {
      copyIpBtn.addEventListener('click', () => {
        const url = `http://${this.localIp}:8080`;
        navigator.clipboard.writeText(url);
        alert(`Copied URL for Mobile Phone: ${url}`);
      });
    }

    // Fast Automated Demonstration Flow Triggers for Hackathon Jury Demo
    document.getElementById('demo-step-1')?.addEventListener('click', () => this.autoStep1_Diagnose());
    document.getElementById('demo-step-2')?.addEventListener('click', () => this.autoStep2_AssignTech());
    document.getElementById('demo-step-3')?.addEventListener('click', () => this.autoStep3_TechArrive());
    document.getElementById('demo-step-4')?.addEventListener('click', () => this.autoStep4_CompleteProof());
    document.getElementById('demo-step-5')?.addEventListener('click', () => this.autoStep5_PayAndReview());
  }

  switchStageMode(mode) {
    this.currentMode = mode;

    // Update active tab styles
    document.querySelectorAll('.view-tab-btn').forEach(btn => {
      if (btn.getAttribute('data-mode') === mode) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    // Sections
    const secPortal = document.getElementById('section-portal');
    const secUser = document.getElementById('section-user');
    const secTech = document.getElementById('section-tech');
    const secAdmin = document.getElementById('section-admin');
    const secStage = document.getElementById('section-stage');
    const demoBar = document.getElementById('hub-demo-bar');

    // Hide all
    if (secPortal) secPortal.style.display = 'none';
    if (secUser) secUser.style.display = 'none';
    if (secTech) secTech.style.display = 'none';
    if (secAdmin) secAdmin.style.display = 'none';
    if (secStage) secStage.style.display = 'none';
    if (demoBar) demoBar.style.display = 'none';

    // Show selected
    if (mode === 'portal') {
      if (secPortal) secPortal.style.display = 'flex';
    } else if (mode === 'user') {
      if (secUser) secUser.style.display = 'flex';
    } else if (mode === 'technician') {
      if (secTech) secTech.style.display = 'flex';
    } else if (mode === 'admin') {
      if (secAdmin) secAdmin.style.display = 'flex';
    } else if (mode === 'stage') {
      if (secStage) secStage.style.display = 'flex';
      if (demoBar) demoBar.style.display = 'flex';
    }
  }

  // --- Automation Helpers for 3-in-1 Stage ---
  async autoStep1_Diagnose() {
    const iframeUser = (document.getElementById('iframe-user-stage') || document.getElementById('iframe-user'))?.contentWindow;
    if (iframeUser && iframeUser.userApp) {
      iframeUser.userApp.showView('report');
      setTimeout(() => {
        iframeUser.userApp.handleRunDiagnosis();
      }, 500);
    }
  }

  async autoStep2_AssignTech() {
    const iframeUser = (document.getElementById('iframe-user-stage') || document.getElementById('iframe-user'))?.contentWindow;
    if (iframeUser && iframeUser.userApp) {
      await iframeUser.userApp.selectTechnician(1, 'Rahul Kumar');
    }
  }

  async autoStep3_TechArrive() {
    const iframeTech = (document.getElementById('iframe-tech-stage') || document.getElementById('iframe-tech'))?.contentWindow;
    if (iframeTech && iframeTech.techApp && iframeTech.techApp.activeJob) {
      await iframeTech.techApp.updateStatus(iframeTech.techApp.activeJob.id, 'ARRIVED');
    }
  }

  async autoStep4_CompleteProof() {
    const iframeTech = (document.getElementById('iframe-tech-stage') || document.getElementById('iframe-tech'))?.contentWindow;
    if (iframeTech && iframeTech.techApp && iframeTech.techApp.activeJob) {
      await iframeTech.techApp.handleUploadProof();
    }
  }

  async autoStep5_PayAndReview() {
    const iframeUser = (document.getElementById('iframe-user-stage') || document.getElementById('iframe-user'))?.contentWindow;
    if (iframeUser && iframeUser.userApp) {
      await iframeUser.userApp.handlePayment();
    }
  }
}

window.HubController = HubController;
