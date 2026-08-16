/**
 * SERVOLOCAL AI - User Mobile App Controller
 * Full 18-Screen Interactive Flow Controller
 */

class UserApp {
  constructor() {
    this.userId = 1;
    this.userName = "Arjun Industries";
    this.userLocation = "Jaipur, Rajasthan";
    this.currentStepId = 'login';
    this.currentStepNum = 1;
    this.viewMode = 'phone'; // 'phone' or 'poster'
    this.isRecordingVoice = false;
    this.socket = typeof SocketClient !== 'undefined' ? new SocketClient('user', this.userId) : null;
  }

  async init() {
    console.log('🚀 Initializing SERVOLOCAL AI User App (18-Screen Flow)...');
    this.updateClock();
    setInterval(() => this.updateClock(), 30000);

    if (this.socket) {
      try {
        this.socket.connect();
      } catch (e) {
        console.log('Socket connect skipped');
      }
    }

    this.renderPosterGrid();
    this.navigateToStep('login', 1);
  }

  updateClock() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
    const clockEls = document.querySelectorAll('#current-clock-time');
    clockEls.forEach(el => el.textContent = timeStr);
  }

  switchViewMode(mode) {
    this.viewMode = mode;
    const phoneContainer = document.getElementById('phone-frame-container');
    const posterContainer = document.getElementById('poster-grid-container');
    const btnPhone = document.getElementById('mode-btn-phone');
    const btnPoster = document.getElementById('mode-btn-poster');

    if (mode === 'poster') {
      if (phoneContainer) phoneContainer.style.display = 'none';
      if (posterContainer) posterContainer.style.display = 'grid';
      if (btnPhone) btnPhone.classList.remove('active');
      if (btnPoster) btnPoster.classList.add('active');
      this.renderPosterGrid();
    } else {
      if (phoneContainer) phoneContainer.style.display = 'flex';
      if (posterContainer) posterContainer.style.display = 'none';
      if (btnPhone) btnPhone.classList.add('active');
      if (btnPoster) btnPoster.classList.remove('active');
    }
  }

  navigateToStep(stepId, stepNum) {
    console.log(`📱 [SERVOLOCAL] Navigating to Step ${stepNum}: ${stepId}`);
    this.currentStepId = stepId;
    this.currentStepNum = stepNum;

    // Update active pill button
    document.querySelectorAll('.step-pill').forEach(pill => {
      if (pill.getAttribute('data-step') === stepId) {
        pill.classList.add('active');
        pill.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
      } else {
        pill.classList.remove('active');
      }
    });

    // Update active section in phone frame
    document.querySelectorAll('#screens-viewport .screen-section').forEach(sec => {
      sec.classList.remove('active');
    });

    const targetSec = document.getElementById(`view-${stepId}`);
    if (targetSec) {
      targetSec.classList.add('active');
      targetSec.scrollTop = 0;
    }

    // Auto-advance logic for AI Analysis (Step 5) & Matching (Step 6)
    if (stepId === 'analysis') {
      clearTimeout(this.autoTimer);
      this.autoTimer = setTimeout(() => {
        this.navigateToStep('matching', 6);
      }, 2500);
    } else if (stepId === 'matching') {
      clearTimeout(this.autoTimer);
      this.autoTimer = setTimeout(() => {
        this.navigateToStep('bestmatch', 7);
      }, 2500);
    }
  }

  toggleVoiceRecording() {
    this.isRecordingVoice = !this.isRecordingVoice;
    const micLabel = document.getElementById('mic-status-label');
    if (micLabel) {
      micLabel.textContent = this.isRecordingVoice ? '● Recording voice...' : 'Tap to record';
      micLabel.style.color = this.isRecordingVoice ? '#EF4444' : '#6B7280';
    }
  }

  renderPosterGrid() {
    const posterContainer = document.getElementById('poster-grid-container');
    if (!posterContainer) return;

    const stepsData = [
      { num: 1, id: 'login', title: '1. Login' },
      { num: 2, id: 'home', title: '2. Home' },
      { num: 3, id: 'upload', title: '3. Upload Issue (Photo First)' },
      { num: 4, id: 'describe', title: '4. Describe Issue' },
      { num: 5, id: 'analysis', title: '5. AI Analysis' },
      { num: 6, id: 'matching', title: '6. Technician Matching' },
      { num: 7, id: 'bestmatch', title: '7. Best Match Found' },
      { num: 8, id: 'accepted', title: '8. Request Accepted' },
      { num: 9, id: 'tracking', title: '9. Live Tracking' },
      { num: 10, id: 'arrived', title: '10. Technician Arrived' },
      { num: 11, id: 'quote', title: '11. Repair Quote' },
      { num: 12, id: 'inprogress', title: '12. Repair In Progress' },
      { num: 13, id: 'completed', title: '13. Completed' },
      { num: 14, id: 'proof', title: '14. Before / After' },
      { num: 15, id: 'payment', title: '15. Payment' },
      { num: 16, id: 'success', title: '16. Payment Success' },
      { num: 17, id: 'review', title: '17. Rate & Review' },
      { num: 18, id: 'history', title: '18. Service History' }
    ];

    posterContainer.innerHTML = stepsData.map(step => {
      const sourceView = document.getElementById(`view-${step.id}`);
      const innerHtml = sourceView ? sourceView.innerHTML : `<div style="padding:20px;">Screen ${step.num}</div>`;
      return `
        <div class="poster-screen-card" onclick="userApp.switchViewMode('phone'); userApp.navigateToStep('${step.id}', ${step.num});">
          <div class="poster-screen-badge">${step.title}</div>
          <div style="margin-top: 40px; height: 100%; display: flex; flex-direction: column;">
            ${innerHtml}
          </div>
        </div>
      `;
    }).join('');
  }
}
