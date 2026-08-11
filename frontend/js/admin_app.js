/**
 * AETHERION - Admin Dashboard Controller
 */

class AdminApp {
  constructor() {
    this.adminId = 1;
    this.socket = new SocketClient('admin', this.adminId);
    this.metricsData = null;
  }

  async init() {
    console.log('🧑‍💼 Initializing Admin Dashboard...');
    this.socket.connect();
    this.bindSocketEvents();
    await this.loadMetrics();
  }

  bindSocketEvents() {
    this.socket.on('*', (event) => {
      console.log('⚡ [AdminApp] Live WebSocket Event received:', event);
      this.loadMetrics(); // Refresh data tables & active job counts live!
    });
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
        ? `https://ui-avatars.com/api/?name=${encodeURIComponent(t.name)}&background=7B4B2A&color=fff`
        : t.avatar;
      return `
        <div class="tech-row-compact animate-fade-in">
          <div class="tech-row-compact-left">
            <img src="${avatarSrc}" class="tech-avatar-mini" alt="${t.name}">
            <div>
              <div class="tech-name-mini">${t.name}</div>
              <div class="tech-rating-mini">⭐ ${t.rating} <span style="color: var(--text-muted); font-size: 10px;">(${t.jobs_count} Jobs)</span></div>
            </div>
          </div>
          <div style="font-size: 12px; font-weight: 700; color: var(--primary-dark-green);">
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
        ? `https://ui-avatars.com/api/?name=${encodeURIComponent(r.user_name)}&background=1B4332&color=fff`
        : r.user_avatar;
      return `
        <div class="review-item-compact animate-fade-in">
          <img src="${avatarSrc}" class="tech-avatar-mini" alt="${r.user_name}">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span style="font-size: 13px; font-weight: 700; color: var(--primary-dark-green);">${r.user_name}</span>
              <span style="font-size: 10px; color: var(--text-muted);">${r.date}</span>
            </div>
            <div style="color: #D97706; font-size: 11px; margin: 1px 0;">${'⭐'.repeat(Math.round(r.rating || 5))}</div>
            <div class="review-text-compact">"${r.comment}"</div>
          </div>
        </div>
      `;
    }).join('');
  }

  renderChart(chartData) {
    const svgEl = document.getElementById('jobs-overview-svg');
    if (!svgEl) return;

    // Build interactive SVG Dual-line Chart matching screenshot
    const width = 450;
    const height = 160;
    const padding = 25;

    const labels = chartData.labels; // 6 May .. 12 May
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

      dotsCompleted += `<circle cx="${x}" cy="${yComp}" r="3.5" fill="#1B4332" />`;
      dotsActive += `<circle cx="${x}" cy="${yAct}" r="3.5" fill="#7B4B2A" />`;

      xLabels += `<text x="${x}" y="${height - 5}" font-size="9" fill="#8E9E95" text-anchor="middle">${lbl}</text>`;
    });

    svgEl.innerHTML = `
      <defs>
        <linearGradient id="gradCompleted" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#1B4332" stop-opacity="0.25"/>
          <stop offset="100%" stop-color="#1B4332" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <!-- Grid lines -->
      <line x1="${padding}" y1="${getY(20)}" x2="${width - padding}" y2="${getY(20)}" stroke="#EBF0EC" stroke-width="1" />
      <line x1="${padding}" y1="${getY(40)}" x2="${width - padding}" y2="${getY(40)}" stroke="#EBF0EC" stroke-width="1" />
      <line x1="${padding}" y1="${getY(60)}" x2="${width - padding}" y2="${getY(60)}" stroke="#EBF0EC" stroke-width="1" />
      <!-- Completed Line -->
      <path d="${pathCompleted}" fill="none" stroke="#1B4332" stroke-width="2.5" />
      <!-- Active Line -->
      <path d="${pathActive}" fill="none" stroke="#7B4B2A" stroke-width="2.5" stroke-dasharray="3" />
      <!-- Dots -->
      ${dotsCompleted}
      ${dotsActive}
      <!-- X-Axis Labels -->
      ${xLabels}
    `;
  }
}

window.AdminApp = AdminApp;
