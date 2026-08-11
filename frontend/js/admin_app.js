/**
 * AETHERION - Production Admin Dashboard Controller
 */

class AdminApp {
  constructor() {
    this.adminId = 1;
    this.socket = new SocketClient('admin', this.adminId);
    this.metricsData = null;
    this.activeTab = 'tab-overview';
  }

  async init() {
    console.log('🧑‍💼 Initializing Executive Admin Dashboard...');
    this.socket.connect();
    this.bindSocketEvents();
    this.bindSidebarTabs();
    await this.loadMetrics();
    await this.loadUsersAndTechs();
  }

  bindSidebarTabs() {
    const links = document.querySelectorAll('.sidebar-link');
    links.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const tabId = link.getAttribute('data-tab');
        if (!tabId) return;

        // Active link styling
        links.forEach(l => l.classList.remove('active'));
        link.classList.add('active');

        // Show active pane
        document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
        const targetPane = document.getElementById(tabId);
        if (targetPane) targetPane.classList.add('active');

        this.activeTab = tabId;
      });
    });
  }

  bindSocketEvents() {
    this.socket.on('*', (event) => {
      console.log('⚡ [AdminApp] Live WebSocket Event received:', event);
      this.loadMetrics(); // Refresh data tables & active job counts live!
      this.logDispatchEvent(event);
    });
  }

  logDispatchEvent(event) {
    const logBox = document.getElementById('dispatch-live-log');
    if (!logBox) return;
    const time = new Date().toLocaleTimeString();
    const eventType = event.type || 'SOCKET_EVENT';
    const div = document.createElement('div');
    div.style.marginBottom = '6px';
    div.style.color = '#10B981';
    div.innerHTML = `[${time}] <b style="color:#F59E0B;">${eventType}</b>: ${JSON.stringify(event.job || event)}`;
    logBox.prepend(div);
  }

  async loadMetrics() {
    try {
      const res = await ApiClient.get('/api/admin/dashboard-metrics');
      if (res) {
        this.metricsData = res;
        this.renderStats(res.stats);
        this.renderRecentJobs(res.recent_jobs);
        this.renderTopTechnicians(res.top_technicians);
        this.renderReviews(res.recent_reviews);
        this.renderChart(res.chart_data);
      }
    } catch (err) {
      console.error('Failed to load admin metrics:', err);
    }
  }

  async loadUsersAndTechs() {
    try {
      const resUsers = await ApiClient.get('/api/admin/users');
      const tbody = document.getElementById('users-staff-tbody');
      if (!tbody || !resUsers || !resUsers.users) return;

      tbody.innerHTML = resUsers.users.map(u => `
        <tr class="animate-fade-in">
          <td><b>#${u.id}</b></td>
          <td><b>${u.name}</b></td>
          <td>${u.email}<br><span style="color: var(--text-secondary); font-size:11px;">${u.phone}</span></td>
          <td><span class="status-pill-table" style="background-color:rgba(59,130,246,0.1); color:#2563EB;">${u.role.toUpperCase()}</span></td>
          <td><b>${u.jobs_count} Jobs</b></td>
          <td><span class="status-pill-table status-completed">${u.status}</span></td>
          <td><button class="btn-primary" style="padding: 4px 10px; font-size: 11px;" onclick="alert('User details loaded for ${u.name}')">View Profile</button></td>
        </tr>
      `).join('');
    } catch (err) {
      console.error('Failed to load users directory:', err);
    }
  }

  async sendEmergencyBroadcast() {
    const msg = document.getElementById('emergency-msg-input').value;
    const type = document.getElementById('emergency-type-select').value;
    try {
      const res = await ApiClient.post('/api/admin/emergency-alert', { message: msg, type: type });
      alert('🚨 Emergency Alert successfully broadcasted to all connected devices!');
    } catch (err) {
      alert('Failed to send emergency alert.');
    }
  }

  async saveSurgeSettings() {
    const val = parseFloat(document.getElementById('surge-range').value);
    try {
      await ApiClient.post('/api/admin/update-settings', { surge_multiplier: val });
      alert(`⚡ Surge Multiplier updated to ${val}x!`);
    } catch (err) {
      alert('Failed to update surge settings.');
    }
  }

  renderStats(stats) {
    document.getElementById('stat-total-users').textContent = stats.total_users.toLocaleString();
    document.getElementById('stat-users-growth').textContent = stats.total_users_growth;

    document.getElementById('stat-technicians').textContent = stats.technicians.toLocaleString();
    document.getElementById('stat-tech-growth').textContent = stats.technicians_growth;

    document.getElementById('stat-active-jobs').textContent = stats.active_jobs;
    document.getElementById('stat-active-subtext').textContent = stats.active_jobs_subtext;

    document.getElementById('stat-completed-jobs').textContent = stats.completed_jobs.toLocaleString();
    document.getElementById('stat-completed-growth').textContent = stats.completed_jobs_growth;

    document.getElementById('stat-revenue').textContent = stats.revenue;
    document.getElementById('stat-revenue-growth').textContent = stats.revenue_growth;
  }

  renderRecentJobs(jobs) {
    const tbody = document.getElementById('recent-jobs-tbody');
    if (!tbody) return;

    tbody.innerHTML = jobs.map(j => {
      let statusClass = 'status-on-the-way';
      if (j.status === 'REPAIRING') statusClass = 'status-repairing';
      if (['COMPLETED', 'PAID'].includes(j.status)) statusClass = 'status-completed';

      return `
        <tr class="animate-fade-in">
          <td class="table-job-code">${j.job_code}</td>
          <td><b>${j.title}</b></td>
          <td>${j.user_name}</td>
          <td>${j.technician_name}</td>
          <td><span class="status-pill-table ${statusClass}">${j.status.replace(/_/g, ' ')}</span></td>
          <td><b>₹${(j.final_amount || 1450).toLocaleString()}</b></td>
        </tr>
      `;
    }).join('');
  }

  renderTopTechnicians(techs) {
    const container = document.getElementById('top-technicians-list');
    if (!container) return;

    container.innerHTML = techs.map(t => {
      const avatarSrc = (!t.avatar || t.avatar.includes('/static/'))
        ? `https://ui-avatars.com/api/?name=${encodeURIComponent(t.name)}&background=10B981&color=fff`
        : t.avatar;
      return `
        <div class="tech-row-compact animate-fade-in">
          <div class="tech-row-compact-left">
            <img src="${avatarSrc}" class="tech-avatar-mini" alt="${t.name}">
            <div>
              <div class="tech-name-mini">${t.name}</div>
              <div class="tech-rating-mini">⭐ ${t.rating} <span style="color: var(--text-secondary); font-size: 11px;">(${t.jobs_count} Jobs)</span></div>
            </div>
          </div>
          <div style="font-size: 13px; font-weight: 800; color: var(--primary-emerald);">
            ₹${(t.earnings || 42850).toLocaleString()}
          </div>
        </div>
      `;
    }).join('');
  }

  renderReviews(reviews) {
    const container = document.getElementById('recent-reviews-list');
    if (!container) return;

    container.innerHTML = reviews.map(r => {
      const avatarSrc = (!r.user_avatar || r.user_avatar.includes('/static/')) 
        ? `https://ui-avatars.com/api/?name=${encodeURIComponent(r.user_name)}&background=0A2E1D&color=fff`
        : r.user_avatar;
      return `
        <div class="review-item-compact animate-fade-in" style="display:flex; gap:10px; margin-bottom:12px;">
          <img src="${avatarSrc}" class="tech-avatar-mini" alt="${r.user_name}">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; gap: 10px;">
              <span style="font-size: 13px; font-weight: 700; color: var(--primary-dark-green);">${r.user_name}</span>
              <span style="font-size: 10px; color: var(--text-secondary);">${r.date}</span>
            </div>
            <div style="color: #F59E0B; font-size: 11px; margin: 2px 0;">${'⭐'.repeat(Math.round(r.rating || 5))}</div>
            <div style="font-size: 12px; color: var(--text-secondary);">"${r.comment}"</div>
          </div>
        </div>
      `;
    }).join('');
  }

  renderChart(chartData) {
    const svgEl = document.getElementById('jobs-overview-svg');
    if (!svgEl) return;

    const width = 450;
    const height = 180;
    const padding = 25;

    const labels = chartData.labels;
    const completed = chartData.completed;
    const active = chartData.active;

    const maxVal = 80;
    const stepX = (width - padding * 2) / (labels.length - 1);

    const getX = (idx) => padding + idx * stepX;
    const getY = (val) => height - padding - ((val / maxVal) * (height - padding * 2));

    let pathCompleted = '';
    let pathActive = '';
    let dotsCompleted = '';
    let dotsActive = '';
    let xLabels = '';

    labels.forEach((lbl, i) => {
      const x = getX(i);
      const yComp = getY(completed[i]);
      const yAct = getY(active[i]);

      pathCompleted += (i === 0 ? `M ${x} ${yComp}` : ` L ${x} ${yComp}`);
      pathActive += (i === 0 ? `M ${x} ${yAct}` : ` L ${x} ${yAct}`);

      dotsCompleted += `<circle cx="${x}" cy="${yComp}" r="4" fill="#10B981" />`;
      dotsActive += `<circle cx="${x}" cy="${yAct}" r="4" fill="#FF5200" />`;

      xLabels += `<text x="${x}" y="${height - 5}" font-size="10" fill="#64748B" font-weight="600" text-anchor="middle">${lbl}</text>`;
    });

    svgEl.innerHTML = `
      <defs>
        <linearGradient id="gradCompleted" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#10B981" stop-opacity="0.3"/>
          <stop offset="100%" stop-color="#10B981" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <line x1="${padding}" y1="${getY(20)}" x2="${width - padding}" y2="${getY(20)}" stroke="#E2E8F0" stroke-width="1" />
      <line x1="${padding}" y1="${getY(40)}" x2="${width - padding}" y2="${getY(40)}" stroke="#E2E8F0" stroke-width="1" />
      <line x1="${padding}" y1="${getY(60)}" x2="${width - padding}" y2="${getY(60)}" stroke="#E2E8F0" stroke-width="1" />
      <path d="${pathCompleted}" fill="none" stroke="#10B981" stroke-width="3" />
      <path d="${pathActive}" fill="none" stroke="#FF5200" stroke-width="3" stroke-dasharray="4" />
      ${dotsCompleted}
      ${dotsActive}
      ${xLabels}
    `;
  }
}

window.AdminApp = AdminApp;
