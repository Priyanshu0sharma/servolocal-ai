'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import {
  Users,
  Wrench,
  Zap,
  CheckCircle,
  IndianRupee,
  AlertTriangle,
  Search,
  Shield,
  TrendingUp,
  Radio,
  Sliders,
  Settings,
  RefreshCw,
  Bell
} from 'lucide-react';

export const AdminDashboardView: React.FC = () => {
  const { technicians, activeJob, setNotification } = usePrototype();
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'dispatch' | 'emergency' | 'settings'>('overview');
  const [searchQuery, setSearchQuery] = useState('');
  const [emergencyMsg, setEmergencyMsg] = useState('⚠️ HIGH DEMAND SURGE: Weather delay in Sector 4. Technician arrival extended by 10 mins.');
  const [emergencyType, setEmergencyType] = useState('SURGE');
  const [surgeMultiplier, setSurgeMultiplier] = useState(1.25);
  const [aiConfidence, setAiConfidence] = useState(85);
  const [serviceRadius, setServiceRadius] = useState(15);

  const mockUsers = [
    { id: 'USR-101', name: 'Alex Mercer', email: 'alex.mercer@apex.com', phone: '+91 98200 44123', role: 'User', jobsCount: 5, status: 'Active' },
    { id: 'USR-102', name: 'Aarav Patel', email: 'aarav.p@gmail.com', phone: '+91 91234 56789', role: 'User', jobsCount: 2, status: 'Active' },
    { id: 'USR-103', name: 'Neha Verma', email: 'neha.v@yahoo.com', phone: '+91 99887 76655', role: 'User', jobsCount: 8, status: 'Active' },
    { id: 'USR-104', name: 'Rahul Tailor', email: 'rahul.t@aetherion.ai', phone: '+91 63750 19104', role: 'Lead Admin', jobsCount: 24, status: 'Active' },
    { id: 'USR-105', name: 'Priyanshu Sharma', email: 'priyanshu@aetherion.ai', phone: '+91 98765 43210', role: 'Admin', jobsCount: 19, status: 'Active' },
  ];

  const handleBroadcastAlert = () => {
    setNotification({
      title: `🚨 EMERGENCY BROADCAST (${emergencyType})`,
      message: emergencyMsg,
      type: 'warning'
    });
    alert('🚨 Emergency Alert broadcasted to all connected devices live!');
  };

  return (
    <div className="flex flex-col w-full h-full bg-[#0F172A] text-slate-100 overflow-y-auto min-h-screen">
      {/* Top Admin Header */}
      <header className="h-16 bg-[#0A2E1D] border-b border-emerald-900/40 px-6 flex items-center justify-between shrink-0 sticky top-0 z-20">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-amber-500 flex items-center justify-center font-extrabold text-white text-lg shadow-lg border border-white/20">
            ⬡
          </div>
          <div>
            <h1 className="font-extrabold text-base tracking-wider text-white flex items-center gap-2">
              AETHERION <span className="text-[10px] bg-emerald-500/30 text-emerald-300 font-bold px-2 py-0.5 rounded-full border border-emerald-400/30 uppercase">Executive Command</span>
            </h1>
            <p className="text-xs text-emerald-300/70 font-mono">System Status: ONLINE • WebSocket Active</p>
          </div>
        </div>

        {/* Global Search Bar */}
        <div className="hidden md:flex items-center gap-2 bg-[#0F172A] border border-slate-700/60 rounded-full px-4 py-1.5 w-80 text-xs focus-within:border-emerald-500 transition-all">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search users, technicians, jobs..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="bg-transparent border-none outline-none text-slate-100 w-full"
          />
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-3">
          <button
            onClick={handleBroadcastAlert}
            className="flex items-center gap-1.5 bg-gradient-to-r from-rose-600 to-red-600 hover:from-rose-500 hover:to-red-500 text-white font-bold text-xs px-3.5 py-1.5 rounded-full shadow-lg shadow-rose-600/30 animate-pulse border border-rose-400/30"
          >
            <AlertTriangle className="w-3.5 h-3.5" />
            <span>Emergency Broadcast</span>
          </button>

          <div className="flex items-center gap-2.5 bg-slate-800/80 border border-slate-700/60 rounded-full px-3 py-1">
            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100" className="w-7 h-7 rounded-full object-cover border border-emerald-500" alt="Admin" />
            <span className="text-xs font-bold text-slate-200">Rahul Tailor ▾</span>
          </div>
        </div>
      </header>

      {/* Navigation Sub-Header */}
      <nav className="bg-[#0A2E1D]/90 border-b border-emerald-900/30 px-6 flex items-center gap-2 text-xs font-semibold overflow-x-auto shrink-0">
        <button
          onClick={() => setActiveTab('overview')}
          className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-all ${
            activeTab === 'overview'
              ? 'border-emerald-400 text-emerald-300 font-bold bg-emerald-950/40'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          <TrendingUp className="w-4 h-4" />
          <span>Dashboard Overview</span>
        </button>

        <button
          onClick={() => setActiveTab('users')}
          className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-all ${
            activeTab === 'users'
              ? 'border-emerald-400 text-emerald-300 font-bold bg-emerald-950/40'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          <Users className="w-4 h-4" />
          <span>Users & Technicians</span>
        </button>

        <button
          onClick={() => setActiveTab('dispatch')}
          className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-all ${
            activeTab === 'dispatch'
              ? 'border-emerald-400 text-emerald-300 font-bold bg-emerald-950/40'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          <Zap className="w-4 h-4" />
          <span>Live Dispatch Stream</span>
        </button>

        <button
          onClick={() => setActiveTab('emergency')}
          className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-all ${
            activeTab === 'emergency'
              ? 'border-emerald-400 text-emerald-300 font-bold bg-emerald-950/40'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          <Radio className="w-4 h-4 text-amber-400" />
          <span>Emergency & Surge Control</span>
        </button>

        <button
          onClick={() => setActiveTab('settings')}
          className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-all ${
            activeTab === 'settings'
              ? 'border-emerald-400 text-emerald-300 font-bold bg-emerald-950/40'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          <Settings className="w-4 h-4" />
          <span>Platform Settings</span>
        </button>
      </nav>

      {/* Main Admin Body Area */}
      <main className="flex-1 p-6 space-y-6 max-w-7xl mx-auto w-full">
        {/* TAB 1: OVERVIEW */}
        {activeTab === 'overview' && (
          <div className="space-y-6 animate-fadeIn">
            {/* 5 KPI Metric Cards */}
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-4 flex justify-between items-start shadow-md hover:border-emerald-500/40 transition-all">
                <div>
                  <p className="text-[11px] font-semibold text-slate-400">Total Users</p>
                  <p className="text-2xl font-extrabold text-white mt-1">1,248</p>
                  <p className="text-[10px] font-bold text-emerald-400 mt-1">+12% this month</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                  <Users className="w-5 h-5" />
                </div>
              </div>

              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-4 flex justify-between items-start shadow-md hover:border-emerald-500/40 transition-all">
                <div>
                  <p className="text-[11px] font-semibold text-slate-400">Verified Techs</p>
                  <p className="text-2xl font-extrabold text-white mt-1">184</p>
                  <p className="text-[10px] font-bold text-emerald-400 mt-1">+8% onboarding</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
                  <Wrench className="w-5 h-5" />
                </div>
              </div>

              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-4 flex justify-between items-start shadow-md hover:border-emerald-500/40 transition-all">
                <div>
                  <p className="text-[11px] font-semibold text-slate-400">Active Dispatch</p>
                  <p className="text-2xl font-extrabold text-amber-400 mt-1">32</p>
                  <p className="text-[10px] font-bold text-emerald-400 mt-1">Live in progress</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
                  <Zap className="w-5 h-5" />
                </div>
              </div>

              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-4 flex justify-between items-start shadow-md hover:border-emerald-500/40 transition-all">
                <div>
                  <p className="text-[11px] font-semibold text-slate-400">Completed Jobs</p>
                  <p className="text-2xl font-extrabold text-white mt-1">4,892</p>
                  <p className="text-[10px] font-bold text-emerald-400 mt-1">+15% completed</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                  <CheckCircle className="w-5 h-5" />
                </div>
              </div>

              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-4 flex justify-between items-start shadow-md hover:border-emerald-500/40 transition-all">
                <div>
                  <p className="text-[11px] font-semibold text-slate-400">Total Revenue</p>
                  <p className="text-2xl font-extrabold text-emerald-400 mt-1">₹8.42 Lakh</p>
                  <p className="text-[10px] font-bold text-emerald-400 mt-1">+18% net growth</p>
                </div>
                <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                  <IndianRupee className="w-5 h-5" />
                </div>
              </div>
            </div>

            {/* Middle Grid: Live Job Stream & Analytics */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Active Dispatch Table */}
              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-5 space-y-4">
                <div className="flex justify-between items-center">
                  <h3 className="font-extrabold text-sm text-white flex items-center gap-2">
                    <Zap className="w-4 h-4 text-amber-400" /> Live Service Fulfillment Stream
                  </h3>
                  <span className="text-[10px] font-mono font-bold text-emerald-400 bg-emerald-950/60 border border-emerald-600/30 px-2.5 py-1 rounded-full">
                    ● WEBSOCKET LIVE
                  </span>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs text-slate-300">
                    <thead className="bg-slate-900/60 text-slate-400 uppercase text-[10px] tracking-wider border-b border-slate-700/60">
                      <tr>
                        <th className="py-2.5 px-3">Job ID</th>
                        <th className="py-2.5 px-3">Appliance Issue</th>
                        <th className="py-2.5 px-3">Customer</th>
                        <th className="py-2.5 px-3">Technician</th>
                        <th className="py-2.5 px-3">Status</th>
                        <th className="py-2.5 px-3">Cost</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-700/40">
                      {activeJob ? (
                        <tr className="bg-emerald-950/30 font-semibold">
                          <td className="py-3 px-3 text-amber-400">{activeJob.requestCode}</td>
                          <td className="py-3 px-3">{activeJob.machineName}</td>
                          <td className="py-3 px-3">{activeJob.user.name}</td>
                          <td className="py-3 px-3">{activeJob.assignedTechnician?.name || 'Searching...'}</td>
                          <td className="py-3 px-3">
                            <span className="bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full text-[10px] font-bold">
                              {activeJob.status}
                            </span>
                          </td>
                          <td className="py-3 px-3 text-white font-bold">₹{activeJob.aiDiagnosis.estimatedTotal}</td>
                        </tr>
                      ) : null}

                      <tr className="hover:bg-slate-700/30">
                        <td className="py-3 px-3 text-amber-400 font-bold">#SERVO-8492</td>
                        <td className="py-3 px-3 font-semibold text-white">Daikin VRV Outdoor Chiller</td>
                        <td className="py-3 px-3">Aarav Patel</td>
                        <td className="py-3 px-3">Rajesh Kumar</td>
                        <td className="py-3 px-3">
                          <span className="bg-amber-500/20 text-amber-300 border border-amber-500/30 px-2 py-0.5 rounded-full text-[10px] font-bold">
                            REPAIRING
                          </span>
                        </td>
                        <td className="py-3 px-3 text-white font-bold">₹4,499</td>
                      </tr>

                      <tr className="hover:bg-slate-700/30">
                        <td className="py-3 px-3 text-amber-400 font-bold">#SERVO-8491</td>
                        <td className="py-3 px-3 font-semibold text-white">LG Inverter Washing Machine</td>
                        <td className="py-3 px-3">Neha Verma</td>
                        <td className="py-3 px-3">Vikram Singh</td>
                        <td className="py-3 px-3">
                          <span className="bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full text-[10px] font-bold">
                            ON THE WAY
                          </span>
                        </td>
                        <td className="py-3 px-3 text-white font-bold">₹2,850</td>
                      </tr>

                      <tr className="hover:bg-slate-700/30">
                        <td className="py-3 px-3 text-amber-400 font-bold">#SERVO-8490</td>
                        <td className="py-3 px-3 font-semibold text-white">Samsung Double Door Fridge</td>
                        <td className="py-3 px-3">Rohan Gupta</td>
                        <td className="py-3 px-3">Amit Sharma</td>
                        <td className="py-3 px-3">
                          <span className="bg-blue-500/20 text-blue-300 border border-blue-500/30 px-2 py-0.5 rounded-full text-[10px] font-bold">
                            COMPLETED
                          </span>
                        </td>
                        <td className="py-3 px-3 text-white font-bold">₹1,950</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Verified Technicians Status */}
              <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-5 space-y-4">
                <h3 className="font-extrabold text-sm text-white flex items-center gap-2">
                  <Wrench className="w-4 h-4 text-emerald-400" /> Active Field Technicians
                </h3>

                <div className="space-y-3">
                  {technicians.map((t) => (
                    <div key={t.id} className="flex items-center justify-between p-3 rounded-xl bg-slate-900/60 border border-slate-700/40">
                      <div className="flex items-center gap-3">
                        <img src={t.avatar} className="w-9 h-9 rounded-full object-cover border-2 border-emerald-400" alt={t.name} />
                        <div>
                          <p className="font-bold text-xs text-white">{t.name}</p>
                          <p className="text-[11px] text-slate-400">{t.speciality} • ⭐ {t.rating} ({t.completedJobs} Jobs)</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${t.isOnline ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-700 text-slate-400'}`}>
                          {t.isOnline ? '● ONLINE' : 'OFFLINE'}
                        </span>
                        <p className="text-xs font-extrabold text-emerald-400 mt-1">₹{(t.completedJobs * 1250).toLocaleString()}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* TAB 2: USERS & TECHNICIANS DIRECTORY */}
        {activeTab === 'users' && (
          <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-6 space-y-4 animate-fadeIn">
            <h3 className="font-extrabold text-base text-white flex items-center gap-2">
              <Users className="w-5 h-5 text-emerald-400" /> User & Technician Master Directory
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-slate-300">
                <thead className="bg-slate-900/80 text-slate-400 uppercase text-[10px] tracking-wider border-b border-slate-700">
                  <tr>
                    <th className="py-3 px-4">User ID</th>
                    <th className="py-3 px-4">Name</th>
                    <th className="py-3 px-4">Contact Info</th>
                    <th className="py-3 px-4">Role</th>
                    <th className="py-3 px-4">Jobs</th>
                    <th className="py-3 px-4">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-700/50">
                  {mockUsers.map((u) => (
                    <tr key={u.id} className="hover:bg-slate-700/40">
                      <td className="py-3 px-4 font-bold text-amber-400">{u.id}</td>
                      <td className="py-3 px-4 font-bold text-white">{u.name}</td>
                      <td className="py-3 px-4">{u.email}<br/><span className="text-[10px] text-slate-400">{u.phone}</span></td>
                      <td className="py-3 px-4">
                        <span className="bg-blue-500/20 text-blue-300 border border-blue-500/30 px-2 py-0.5 rounded-full text-[10px] font-bold">
                          {u.role}
                        </span>
                      </td>
                      <td className="py-3 px-4 font-bold text-slate-200">{u.jobsCount} Jobs</td>
                      <td className="py-3 px-4">
                        <span className="bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full text-[10px] font-bold">
                          {u.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* TAB 3: DISPATCH LOG */}
        {activeTab === 'dispatch' && (
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4 font-mono text-xs text-slate-200 animate-fadeIn">
            <h3 className="font-extrabold text-sm text-emerald-400 flex items-center gap-2 font-sans">
              <Zap className="w-4 h-4" /> Real-time Proximity Dispatch Terminal Stream
            </h3>
            <div className="bg-black/60 p-4 rounded-xl space-y-2 border border-slate-800 h-80 overflow-y-auto">
              <p className="text-emerald-400">[09:41:02] ENGINE_INIT: Smart dispatch matching pipeline active across 45 sectors.</p>
              <p className="text-blue-400">[09:41:15] GPS_PING: Technician Rajesh Kumar (0.8 km away) location synced.</p>
              <p className="text-amber-400">[09:41:30] AI_DIAGNOSIS: PCB Inverter Board High Pressure Fault verified with 96.4% confidence.</p>
              <p className="text-emerald-400">[09:42:01] WEBSOCKET_BROADCAST: Job #SERVO-8492 broadcasted to nearest 3 verified technicians.</p>
              <p className="text-purple-400">[09:42:12] DISPATCH_MATCH: Rajesh Kumar accepted job #SERVO-8492. ETA 12 minutes.</p>
            </div>
          </div>
        )}

        {/* TAB 4: EMERGENCY CONTROL */}
        {activeTab === 'emergency' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 animate-fadeIn">
            <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-6 space-y-4">
              <h3 className="font-extrabold text-sm text-rose-400 flex items-center gap-2">
                <AlertTriangle className="w-4 h-4" /> System Emergency Alert Broadcast
              </h3>
              <p className="text-xs text-slate-400">Send an instant push alert banner to all customer & technician apps.</p>
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-300">Alert Message</label>
                <input
                  type="text"
                  value={emergencyMsg}
                  onChange={(e) => setEmergencyMsg(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-3 text-xs text-white outline-none focus:border-emerald-500"
                />
              </div>
              <button
                onClick={handleBroadcastAlert}
                className="w-full bg-gradient-to-r from-rose-600 to-red-600 hover:from-rose-500 hover:to-red-500 text-white font-bold text-xs py-3 rounded-xl shadow-lg"
              >
                Push Emergency Broadcast Now
              </button>
            </div>

            <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-6 space-y-4">
              <h3 className="font-extrabold text-sm text-amber-400 flex items-center gap-2">
                <Sliders className="w-4 h-4" /> Dynamic Surge Pricing Multiplier
              </h3>
              <p className="text-xs text-slate-400">Adjust demand-based price surge multiplier in real time.</p>
              <div className="space-y-2">
                <div className="flex justify-between text-xs font-bold">
                  <span className="text-slate-300">Surge Multiplier</span>
                  <span className="text-amber-400 font-extrabold">{surgeMultiplier}x</span>
                </div>
                <input
                  type="range"
                  min="1.0"
                  max="3.0"
                  step="0.05"
                  value={surgeMultiplier}
                  onChange={(e) => setSurgeMultiplier(parseFloat(e.target.value))}
                  className="w-full accent-amber-500"
                />
              </div>
              <button
                onClick={() => alert(`Surge multiplier saved at ${surgeMultiplier}x`)}
                className="w-full bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-extrabold text-xs py-3 rounded-xl shadow-lg"
              >
                Apply Surge Pricing Multiplier
              </button>
            </div>
          </div>
        )}

        {/* TAB 5: SETTINGS */}
        {activeTab === 'settings' && (
          <div className="bg-slate-800/90 border border-slate-700/60 rounded-2xl p-6 space-y-4 max-w-xl animate-fadeIn">
            <h3 className="font-extrabold text-sm text-emerald-400 flex items-center gap-2">
              <Settings className="w-4 h-4" /> AI Diagnostic & Platform Configuration
            </h3>
            <div className="space-y-4 text-xs">
              <div className="space-y-1">
                <label className="font-bold text-slate-300">Minimum AI Diagnostic Confidence Threshold (%)</label>
                <input
                  type="number"
                  value={aiConfidence}
                  onChange={(e) => setAiConfidence(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-2.5 text-white"
                />
              </div>
              <div className="space-y-1">
                <label className="font-bold text-slate-300">Max Technician Dispatch Radius (km)</label>
                <input
                  type="number"
                  value={serviceRadius}
                  onChange={(e) => setServiceRadius(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-2.5 text-white"
                />
              </div>
              <button
                onClick={() => alert('Platform Settings Saved!')}
                className="bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold px-4 py-2.5 rounded-xl shadow-md"
              >
                Save Settings
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
