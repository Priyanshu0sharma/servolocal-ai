/**
 * AETHERION - User Mobile App Controller
 * Full 33-Step Lifecycle with Rich Micro-Interactions & Tactile Feedback
 */

class UserApp {
  constructor() {
    this.userId = 1; // Priyanshu Sharma
    this.userName = "Priyanshu Sharma";
    this.userPhone = "+91 98765 43210";
    this.activeJob = null;
    this.socket = new SocketClient('user', this.userId);
    
    // Booking Form State
    this.bookingState = {
      category: "AC / HVAC",
      equipmentName: "Split AC",
      brand: "Voltas",
      model: "183V EY (1.5 Ton)",
      age: "3 Years",
      issueDescription: "AC chal raha hai lekin cooling nahi ho rahi aur outdoor unit se noise aa rahi hai.",
      locationCity: "Vaishali Nagar, Jaipur, Rajasthan",
      locationBuilding: "Hostel Block B / Flat 304",
      locationFloor: "3rd Floor, Room 304",
      locationNotes: "Gate no. 2 se entry karna, opposite cafeteria",
      photosCount: 3,
      voiceTranscript: "Bhai AC on hai par hawa bilkul thandi nahi de raha."
    };

    this.selectedPaymentMethod = 'UPI';
    this.selectedRating = 5;
    this.onboardingIndex = 1;
    this.isRecordingVoice = false;
  }

  async init() {
    console.log('🚀 Initializing Complete Aetherion User App...');
    this.updateClock();
    setInterval(() => this.updateClock(), 60000);

    this.socket.connect();
    this.bindSocketEvents();
    this.bindDomEvents();

    // Auto-advance Splash after 1.2s to Onboarding
    setTimeout(() => {
      this.showView('onboarding');
    }, 1200);

    await this.loadActiveJob();
  }

  updateClock() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
    const clockEl = document.getElementById('current-clock-time');
    if (clockEl) clockEl.textContent = timeStr;
  }

  showToast(message, icon = '✓') {
    let toast = document.getElementById('app-mobile-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'app-mobile-toast';
      toast.className = 'mobile-toast';
      document.querySelector('.mobile-frame').appendChild(toast);
    }
    toast.innerHTML = `<span>${icon}</span> <span>${message}</span>`;
    toast.classList.add('show');
    clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => {
      toast.classList.remove('show');
    }, 2200);
  }

  showView(viewId) {
    console.log(`📱 [UserApp] Navigating to view: ${viewId}`);
    document.querySelectorAll('.screen-section').forEach(sec => {
      sec.classList.remove('active');
    });

    const targetSection = document.getElementById(`view-${viewId}`);
    if (targetSection) {
      targetSection.classList.add('active');
      targetSection.scrollTop = 0;
    }

    // Highlight bottom navigation tabs if applicable
    document.querySelectorAll('.nav-item').forEach(item => {
      if (item.getAttribute('data-nav') === viewId) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });
  }

  bindSocketEvents() {
    this.socket.on('STATUS_UPDATED', (data) => {
      console.log('⚡ [UserApp] Real-time Status Update received:', data);
      if (data.job) {
        this.activeJob = data.job;
        this.handleStatusProgression(data.job.status);
      }
    });

    this.socket.on('PROOF_SUBMITTED', (data) => {
      console.log('📸 [UserApp] Real-time Proof Submitted:', data);
      if (data.job) {
        this.activeJob = data.job;
        this.showToast('Technician submitted completion proof!', '📸');
        this.showView('proof-review');
      }
    });

    this.socket.on('PAYMENT_SUCCESSFUL', (data) => {
      if (data.job) {
        this.activeJob = data.job;
        this.showToast('Payment successful!', '💳');
      }
    });
  }

  handleStatusProgression(status) {
    if (status === 'ACCEPTED' || status === 'ON_THE_WAY') {
      this.showView('live-tracking');
      this.showToast('Technician is on the way!', '🛵');
    } else if (status === 'ARRIVED') {
      this.showToast('Technician arrived at doorstep!', '📍');
      this.showView('tech-arrived');
    } else if (status === 'REPAIRING') {
      this.showToast('Repair in progress...', '🔧');
      this.showView('repair-progress');
    } else if (status === 'COMPLETED') {
      this.showToast('Repair completed by technician!', '✓');
      this.showView('proof-review');
    }
    this.renderActiveJobWidget();
  }

  bindDomEvents() {
    // 1. Onboarding Carousel Buttons
    document.getElementById('btn-skip-onboarding')?.addEventListener('click', () => {
      this.showToast('Skipped onboarding');
      this.showView('auth');
    });

    document.getElementById('btn-next-onboarding')?.addEventListener('click', () => {
      this.onboardingIndex++;
      if (this.onboardingIndex > 3) {
        this.showView('auth');
      } else {
        this.updateOnboardingSlide(this.onboardingIndex);
      }
    });

    // Carousel dots direct click
    document.querySelectorAll('.onboarding-dots .dot').forEach((dot, idx) => {
      dot.addEventListener('click', () => {
        this.onboardingIndex = idx + 1;
        this.updateOnboardingSlide(this.onboardingIndex);
      });
    });

    // 2. Auth & OTP Flow
    document.getElementById('btn-send-otp')?.addEventListener('click', () => {
      const phone = document.getElementById('input-phone').value;
      document.getElementById('display-otp-phone').textContent = `+91 ${phone}`;
      document.getElementById('auth-phone-step').style.display = 'none';
      document.getElementById('auth-otp-step').style.display = 'block';
      this.showToast('OTP sent: 123456', '🔑');
      
      // Auto focus first OTP box
      const firstOtp = document.querySelector('.otp-box');
      if (firstOtp) firstOtp.focus();
    });

    // OTP Input auto-advance
    const otpInputs = document.querySelectorAll('.otp-box');
    otpInputs.forEach((input, index) => {
      input.addEventListener('input', (e) => {
        if (e.target.value.length === 1 && index < otpInputs.length - 1) {
          otpInputs[index + 1].focus();
        }
      });
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && !e.target.value && index > 0) {
          otpInputs[index - 1].focus();
        }
      });
    });

    document.getElementById('btn-verify-otp')?.addEventListener('click', () => {
      this.showToast('Login Verified Successfully! Welcome Priyanshu', '🎉');
      this.showView('location-perm');
    });

    // 3. Location Permission
    document.getElementById('btn-use-current-location')?.addEventListener('click', () => {
      this.showToast('Location set to Jaipur, Rajasthan', '📍');
      this.showView('home');
    });
    document.getElementById('btn-enter-location-manual')?.addEventListener('click', () => {
      this.showToast('Location set manually', '📍');
      this.showView('home');
    });

    // 4. Home Screen Actions
    document.getElementById('home-hero-report-btn')?.addEventListener('click', () => this.showView('select-category'));
    document.getElementById('home-how-it-works-btn')?.addEventListener('click', () => this.showView('onboarding'));

    // Category Grid click on Home
    document.querySelectorAll('.category-card').forEach(card => {
      card.addEventListener('click', () => {
        document.querySelectorAll('.category-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        const cat = card.getAttribute('data-cat');
        this.bookingState.category = cat;
        this.showToast(`Selected: ${cat}`, '❄️');
        setTimeout(() => this.showView('select-category'), 150);
      });
    });

    // Bottom Navigation with Bounce Animation
    document.querySelectorAll('.nav-item').forEach(item => {
      item.addEventListener('click', () => {
        const nav = item.getAttribute('data-nav');
        document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
        item.classList.add('active');

        if (nav === 'home') this.showView('home');
        else if (nav === 'services') this.showView('select-category');
        else if (nav === 'jobs') this.showView('history');
        else if (nav === 'notifications') this.showView('notifications');
        else if (nav === 'profile') this.showView('profile');
      });
    });

    // 5. Step 1: Category Selection Options
    document.querySelectorAll('.category-select-option').forEach(opt => {
      opt.addEventListener('click', () => {
        document.querySelectorAll('.category-select-option').forEach(o => {
          o.classList.remove('active');
          o.querySelector('span[style*="font-weight: bold"]')?.remove();
        });
        opt.classList.add('active');
        opt.insertAdjacentHTML('beforeend', '<span style="color: var(--primary-dark-green); font-weight: bold;">✓</span>');
        this.bookingState.category = opt.getAttribute('data-category');
        this.showToast(`Category: ${this.bookingState.category}`);
      });
    });
    document.getElementById('btn-step1-next')?.addEventListener('click', () => this.showView('upload-media'));

    // 6. Step 2: Interactive Angle Tags Toggle
    document.querySelectorAll('.angle-tags-row .angle-tag').forEach(tag => {
      tag.addEventListener('click', () => {
        tag.classList.toggle('active');
        const text = tag.textContent.replace('✓', '').trim();
        if (tag.classList.contains('active')) {
          tag.innerHTML = `✓ ${text}`;
          this.showToast(`Included: ${text}`);
        } else {
          tag.innerHTML = `+ ${text}`;
        }
      });
    });

    // Media upload simulation buttons
    document.querySelectorAll('#upload-media-box button').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.showToast(`${btn.textContent} captured! Photo added.`, '📸');
      });
    });

    document.getElementById('btn-step2-next')?.addEventListener('click', () => this.showView('machine-details'));

    // 7. Step 3: Problem symptom chips & Voice Recording
    document.querySelectorAll('#view-machine-details .angle-tag').forEach(chip => {
      chip.addEventListener('click', () => {
        chip.parentElement.querySelectorAll('.angle-tag').forEach(c => c.classList.remove('active'));
        chip.classList.add('active');
        this.showToast(`Selected: ${chip.textContent}`);
      });
    });

    // Voice record button toggle
    const voiceBtn = document.getElementById('btn-user-voice-record');
    if (voiceBtn) {
      voiceBtn.addEventListener('click', () => {
        this.isRecordingVoice = !this.isRecordingVoice;
        if (this.isRecordingVoice) {
          voiceBtn.classList.add('recording');
          this.showToast('Listening in Hindi/English... Speak now', '🎙️');
          document.getElementById('user-voice-transcript').textContent = 'Listening: "AC se cooling nahi ho rahi..."';
          setTimeout(() => {
            voiceBtn.classList.remove('recording');
            this.isRecordingVoice = false;
            document.getElementById('user-voice-transcript').textContent = '"Bhai AC on hai par thandi hawa nahi de raha aur outdoor unit se noise aa rahi hai."';
            this.showToast('Voice recorded successfully!', '✓');
          }, 2000);
        }
      });
    }

    document.getElementById('btn-step3-next')?.addEventListener('click', () => {
      this.bookingState.equipmentName = document.getElementById('input-equip-name').value;
      this.bookingState.brand = document.getElementById('input-equip-brand').value;
      this.bookingState.model = document.getElementById('input-equip-model').value;
      this.bookingState.age = document.getElementById('input-equip-age').value;
      this.bookingState.issueDescription = document.getElementById('input-issue-text').value;
      this.showView('service-location');
    });

    // 8. Step 4: Service Location Next
    document.getElementById('btn-step4-next')?.addEventListener('click', () => {
      this.bookingState.locationCity = document.getElementById('input-loc-city').value;
      this.bookingState.locationBuilding = document.getElementById('input-loc-building').value;
      this.bookingState.locationFloor = document.getElementById('input-loc-floor').value;
      this.bookingState.locationNotes = document.getElementById('input-loc-notes').value;

      // Populate Review Card
      document.getElementById('review-cat-badge').textContent = this.bookingState.category;
      document.getElementById('review-equip-title').textContent = `${this.bookingState.brand} ${this.bookingState.equipmentName} (${this.bookingState.age})`;
      document.getElementById('review-issue-desc').textContent = this.bookingState.issueDescription;
      document.getElementById('review-loc-text').textContent = `${this.bookingState.locationBuilding}, ${this.bookingState.locationCity}`;

      this.showView('review-request');
    });

    // 9. Step 5: Trigger AI Diagnosis
    document.getElementById('btn-trigger-ai-diagnosis')?.addEventListener('click', () => {
      this.runAiDiagnosisFlow();
    });

    // Find Technicians button click
    document.getElementById('btn-find-technicians')?.addEventListener('click', () => {
      this.runTechnicianMatchingFlow();
    });

    // Tracking flow buttons
    document.getElementById('btn-go-live-tracking')?.addEventListener('click', () => this.showView('live-tracking'));
    document.getElementById('btn-open-contact-modal')?.addEventListener('click', () => this.showToast('Calling Rahul Kumar (+91 98765 43210)...', '📞'));
    document.getElementById('btn-tracking-call')?.addEventListener('click', () => this.showToast('Calling Rahul Kumar (+91 98765 43210)...', '📞'));
    document.getElementById('btn-top-contact')?.addEventListener('click', () => this.showToast('Calling Rahul Kumar (+91 98765 43210)...', '📞'));

    // Simulation helper buttons
    document.getElementById('sim-tech-arrived')?.addEventListener('click', () => {
      this.showToast('Simulated: Technician arrived at doorstep!', '📍');
      this.showView('tech-arrived');
    });
    document.getElementById('sim-tech-inspect')?.addEventListener('click', () => {
      this.showToast('Simulated: Inspection complete! Quotation ready.', '📋');
      this.showView('quote-approval');
    });

    // Arrival to Quote
    document.getElementById('btn-view-final-quote')?.addEventListener('click', () => this.showView('quote-approval'));

    // Approve Quote
    document.getElementById('btn-approve-repair')?.addEventListener('click', () => {
      this.showToast('Quote Approved! Repair in progress.', '🔨');
      this.showView('repair-progress');
    });
    document.getElementById('btn-reject-repair')?.addEventListener('click', () => {
      this.showToast('Quote rejected. Contacting support.', '⚠️');
      this.showView('home');
    });

    // Repair progress to proof
    document.getElementById('btn-view-digital-proof')?.addEventListener('click', () => this.showView('proof-review'));

    // Proof to payment
    document.getElementById('btn-proceed-to-pay')?.addEventListener('click', () => this.showView('payment'));

    // Payment method selector
    document.querySelectorAll('.payment-option').forEach(opt => {
      opt.addEventListener('click', () => {
        document.querySelectorAll('.payment-option').forEach(o => {
          o.classList.remove('active');
          o.querySelector('span[style*="font-weight: bold"]')?.remove();
        });
        opt.classList.add('active');
        opt.insertAdjacentHTML('beforeend', '<span style="color: var(--primary-dark-green); font-weight: bold;">✓</span>');
        this.selectedPaymentMethod = opt.getAttribute('data-method');
        this.showToast(`Selected payment: ${this.selectedPaymentMethod}`, '💳');
      });
    });

    // Submit Payment
    document.getElementById('btn-submit-payment')?.addEventListener('click', () => this.processPayment());

    // Star Rating
    document.querySelectorAll('.star-item').forEach(star => {
      star.addEventListener('click', () => {
        const val = parseInt(star.getAttribute('data-val'));
        this.selectedRating = val;
        document.querySelectorAll('.star-item').forEach((s, idx) => {
          s.style.color = (idx < val) ? '#D97706' : '#D1D5DB';
        });
        this.showToast(`Rated ${val} Stars! ⭐`);
      });
    });

    // Submit Review
    document.getElementById('btn-submit-review')?.addEventListener('click', () => {
      this.showToast('Thank you! Review recorded.', '🌟');
      this.showView('receipt');
    });

    // Download Receipt
    document.getElementById('btn-download-receipt')?.addEventListener('click', () => {
      this.showToast('Official PDF Receipt downloaded to device!', '📥');
    });
  }

  updateOnboardingSlide(slideNum) {
    document.querySelectorAll('.onboarding-slide').forEach((s, i) => {
      s.classList.toggle('active', i === slideNum - 1);
    });
    document.querySelectorAll('.dot').forEach((d, i) => {
      d.classList.toggle('active', i === slideNum - 1);
    });
  }

  async runAiDiagnosisFlow() {
    this.showView('ai-analyzing');
    this.showToast('AI multi-modal models analyzing images...', '🧠');
    
    // Simulate AI Multi-modal scanner
    setTimeout(async () => {
      try {
        const formData = new FormData();
        formData.append('description', this.bookingState.issueDescription);
        formData.append('location', this.bookingState.locationCity);
        
        const res = await ApiClient.post('/api/diagnose', formData);
        if (res && res.diagnosis) {
          const diag = res.diagnosis;
          document.getElementById('diag-detected-title').textContent = `${diag.icon || '❄️'} ${diag.detected_issue}`;
          document.getElementById('diag-confidence-pill').textContent = `${diag.confidence || 92}% AI Confidence`;
          document.getElementById('diag-severity-pill').textContent = `${diag.severity || 'HIGH'} SEVERITY`;
          
          if (diag.possible_causes) {
            document.getElementById('diag-causes-list').innerHTML = diag.possible_causes.map(c => `<li>${c}</li>`).join('');
          }
          if (diag.required_parts) {
            document.getElementById('diag-parts-chips').innerHTML = diag.required_parts.map(p => `<span class="angle-tag active">${p}</span>`).join('');
          }
        }
      } catch (err) {
        console.warn('AI diagnose call fallback:', err);
      }
      this.showToast('AI Diagnosis Complete!', '✓');
      this.showView('ai-result');
    }, 1800);
  }

  async runTechnicianMatchingFlow() {
    this.showView('tech-searching');
    this.showToast('Scanning nearby technicians...', '📡');

    // Create Job in backend
    try {
      const payload = {
        user_id: this.userId,
        category: this.bookingState.category,
        title: "AC Cooling Failure",
        description: this.bookingState.issueDescription,
        address: `${this.bookingState.locationBuilding}, ${this.bookingState.locationCity}`,
        final_amount: 1450.0
      };

      const res = await ApiClient.post('/api/jobs', payload);
      if (res && res.job) {
        this.activeJob = res.job;
      }
    } catch (e) {
      console.warn('Create job API call:', e);
    }

    // Auto-match after radar scan
    setTimeout(() => {
      this.showToast('Rahul Kumar accepted your job!', '👨‍🔧');
      this.showView('tech-found');
      this.renderActiveJobWidget();
    }, 2200);
  }

  async processPayment() {
    const btn = document.getElementById('btn-submit-payment');
    if (btn) btn.textContent = 'Processing Payment... 🔒';

    setTimeout(async () => {
      try {
        if (this.activeJob) {
          await ApiClient.post('/api/payments/process', {
            job_id: this.activeJob.id,
            payment_method: this.selectedPaymentMethod,
            amount: 1450.0
          });
        }
      } catch (err) {
        console.warn('Payment API call:', err);
      }
      this.showToast('₹1,450.00 Paid Successfully via ' + this.selectedPaymentMethod, '🎉');
      this.showView('rating');
    }, 1200);
  }

  async loadActiveJob() {
    try {
      const res = await ApiClient.get('/api/jobs/active/user/1');
      if (res && res.job) {
        this.activeJob = res.job;
        this.renderActiveJobWidget();
      }
    } catch (e) {
      console.log('No active job found initially');
    }
  }

  renderActiveJobWidget() {
    const container = document.getElementById('home-active-job-container');
    if (!container) return;

    if (!this.activeJob) {
      container.innerHTML = '';
      return;
    }

    container.innerHTML = `
      <div class="active-service-widget" style="border: 2px solid var(--primary-dark-green);">
        <div class="active-service-header">
          <span style="font-size: 11px; font-weight: 800; color: var(--primary-dark-green);">ACTIVE SERVICE (${this.activeJob.job_code || '#1022'})</span>
          <span class="active-status-badge">
            <span class="pulse-dot"></span> ${this.activeJob.status}
          </span>
        </div>
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div>
            <h4 style="font-size: 14px; font-weight: 800; color: var(--primary-dark-green);">${this.activeJob.title || 'AC Repair'}</h4>
            <span style="font-size: 11px; color: var(--text-secondary);">Technician: Rahul Kumar (2.4 km)</span>
          </div>
          <button class="btn-primary" style="width: auto; padding: 8px 14px; font-size: 11px;" onclick="userApp.showView('live-tracking')">Track Live 🗺️</button>
        </div>
      </div>
    `;
  }

  showReceiptModal(code, title, amount) {
    document.getElementById('rec-job-code').textContent = code;
    document.getElementById('rec-total-amount').textContent = `₹${amount.toLocaleString()}`;
    this.showToast(`Viewing receipt for ${code}`, '📄');
    this.showView('receipt');
  }

  logout() {
    this.showToast('Logged out');
    this.showView('auth');
  }
}

window.UserApp = UserApp;
