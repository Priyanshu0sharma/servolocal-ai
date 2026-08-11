'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import {
  Wrench,
  Radio,
  Bell,
  CheckCircle2,
  MapPin,
  Camera,
  IndianRupee,
  History,
  TrendingUp,
  UserCheck,
  Briefcase,
  Award,
  CheckCircle,
  Star
} from 'lucide-react';

export const TechDashboard: React.FC = () => {
  const {
    activeTech,
    toggleTechOnline,
    activeJob,
    acceptJobByTech,
    updateJobStatus,
    completeJobByTech,
  } = usePrototype();

  const [activeTab, setActiveTab] = useState<'jobs' | 'history' | 'payments' | 'profile'>('jobs');

  const handleCompleteRepair = () => {
    completeJobByTech({
      beforeUrl:
        activeJob?.media[0]?.url ||
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&auto=format&fit=crop&q=80',
      afterUrl:
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80',
      technicianNotes: 'Replaced safety sensor & performed vacuum recharge. Operating pressure restored.',
    });
  };

  const completedWorkHistory = [
    {
      id: 'WORK-9041',
      title: 'Daikin VRV Chiller Valve Replacement',
      category: 'Commercial HVAC & AC',
      date: '10 Aug 2026',
      customer: 'Aarav Sharma',
      payout: '₹ 650.00',
      rating: 5.0,
      status: 'COMPLETED'
    },
    {
      id: 'WORK-9035',
      title: 'Split AC Gas Leak Repair & Gas Top-up',
      category: 'Air Conditioner',
      date: '08 Aug 2026',
      customer: 'Priya Verma',
      payout: '₹ 450.00',
      rating: 4.9,
      status: 'COMPLETED'
    },
    {
      id: 'WORK-9022',
      title: 'Washing Machine Motor Belt Fix',
      category: 'Washing Machine',
      date: '05 Aug 2026',
      customer: 'Sunita Patel',
      payout: '₹ 350.00',
      rating: 4.8,
      status: 'COMPLETED'
    },
    {
      id: 'WORK-9011',
      title: 'RO Water Purifier Filter Cartridge Swap',
      category: 'Water Purifier',
      date: '02 Aug 2026',
      customer: 'Rohan Mehta',
      payout: '₹ 280.00',
      rating: 5.0,
      status: 'COMPLETED'
    }
  ];

  return (
    <div className="p-3.5 space-y-3 animate-fade-in pb-6 bg-[#F5F4F0] min-h-full font-sans">
      {/* iOS Sleek Header Card */}
      <div className="bg-[#0F382B] text-white p-3 rounded-2xl shadow-sm border border-emerald-800/40 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <img
            src={activeTech.avatar}
            alt={activeTech.name}
            className="w-10 h-10 rounded-xl object-cover border-2 border-emerald-400 shrink-0"
          />
          <div>
            <div className="flex items-center gap-1 text-[9px] font-mono text-emerald-300 font-bold uppercase">
              <span>TECH PORTAL • ★ {activeTech.rating}</span>
            </div>
            <h2 className="text-xs font-black truncate">{activeTech.name}</h2>
            <p className="text-[10px] text-emerald-200/80 truncate">{activeTech.speciality}</p>
          </div>
        </div>

        {/* ONLINE / OFFLINE Switch */}
        <button
          onClick={() => toggleTechOnline(activeTech.id)}
          className={`px-2.5 py-1 rounded-xl font-extrabold text-[10px] flex items-center gap-1 shadow transition-all btn-tactile ${
            activeTech.isOnline
              ? 'bg-emerald-400 text-slate-950'
              : 'bg-rose-700 text-white'
          }`}
        >
          <Radio className={`w-3 h-3 ${activeTech.isOnline ? 'animate-pulse' : ''}`} />
          <span>{activeTech.isOnline ? 'ONLINE' : 'OFFLINE'}</span>
        </button>
      </div>

      {/* iOS Segmented Navigation Tabs */}
      <div className="grid grid-cols-4 gap-1 bg-[#E8E6E0] p-1 rounded-xl border border-slate-200 text-center">
        <button
          onClick={() => setActiveTab('jobs')}
          className={`py-1.5 rounded-lg text-[9px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'jobs' ? 'bg-[#0F382B] text-white shadow' : 'text-[#1C2520]'
          }`}
        >
          <Briefcase className="w-3 h-3" />
          <span>Jobs</span>
        </button>

        <button
          onClick={() => setActiveTab('history')}
          className={`py-1.5 rounded-lg text-[9px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'history' ? 'bg-[#0F382B] text-white shadow' : 'text-[#1C2520]'
          }`}
        >
          <History className="w-3 h-3" />
          <span>History</span>
        </button>

        <button
          onClick={() => setActiveTab('payments')}
          className={`py-1.5 rounded-lg text-[9px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'payments' ? 'bg-[#0F382B] text-white shadow' : 'text-[#1C2520]'
          }`}
        >
          <IndianRupee className="w-3 h-3" />
          <span>Payouts</span>
        </button>

        <button
          onClick={() => setActiveTab('profile')}
          className={`py-1.5 rounded-lg text-[9px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'profile' ? 'bg-[#0F382B] text-white shadow' : 'text-[#1C2520]'
          }`}
        >
          <UserCheck className="w-3 h-3" />
          <span>Profile</span>
        </button>
      </div>

      {/* TAB 1: ACTIVE & INCOMING JOBS */}
      {activeTab === 'jobs' && (
        <div className="space-y-3">
          {activeJob ? (
            <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-sm space-y-3">
              <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                <div className="flex items-center gap-1.5">
                  <Bell className="w-4 h-4 text-amber-600 animate-bounce" />
                  <span className="text-xs font-black text-[#0F382B] uppercase">
                    Dispatch Request ({activeJob.requestCode})
                  </span>
                </div>
                <span className="font-mono text-[9px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-900 border border-amber-300">
                  {activeJob.status}
                </span>
              </div>

              {/* Job Details Card */}
              <div className="bg-[#F8F7F3] p-3 rounded-xl border border-slate-200 space-y-2 text-xs">
                <div className="flex items-center justify-between font-bold">
                  <span className="text-[#0F382B] truncate">{activeJob.machineName}</span>
                  <span className="text-rose-800 bg-rose-100 px-2 py-0.5 rounded text-[9px] uppercase">
                    {activeJob.urgency}
                  </span>
                </div>

                <div className="p-2 rounded-lg bg-emerald-50 border border-emerald-300 text-[10px] font-mono text-emerald-900">
                  AI Diagnosis: {activeJob.aiDiagnosis.detectedIssue}
                </div>

                <div className="text-[#5D6D64] text-[11px] truncate">
                  {activeJob.problemDescription}
                </div>

                <div className="flex items-center justify-between pt-1 border-t border-slate-200 text-[10px] font-bold">
                  <div className="flex items-center gap-1 text-[#1C2520] truncate">
                    <MapPin className="w-3.5 h-3.5 text-[#0F382B]" />
                    <span className="truncate">{activeJob.location.address}</span>
                  </div>
                  <span className="text-[#7B4B2A] bg-amber-100 px-1.5 py-0.5 rounded">
                    Est: ₹499 - ₹699
                  </span>
                </div>
              </div>

              {/* Job Action Buttons */}
              {activeJob.status === 'DISPATCHING' ? (
                <button
                  onClick={() => acceptJobByTech(activeTech.id)}
                  className="w-full py-2.5 rounded-xl bg-[#0F382B] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow transition-all btn-tactile"
                >
                  <CheckCircle2 className="w-4 h-4 text-emerald-300" />
                  <span>ACCEPT JOB & NAVIGATE</span>
                </button>
              ) : (
                <div className="space-y-2">
                  <span className="text-[10px] font-bold text-[#0F382B] uppercase block">
                    Update Service Status:
                  </span>

                  <div className="grid grid-cols-3 gap-1">
                    {(['ON_THE_WAY', 'ARRIVED', 'REPAIR_IN_PROGRESS'] as const).map((st) => (
                      <button
                        key={st}
                        onClick={() => updateJobStatus(st)}
                        className={`py-1.5 rounded-lg text-[9px] font-bold transition-all btn-tactile border ${
                          activeJob.status === st
                            ? 'bg-[#0F382B] text-white border-[#0F382B]'
                            : 'bg-white text-[#1C2520] border-slate-200'
                        }`}
                      >
                        {st.replace(/_/g, ' ')}
                      </button>
                    ))}
                  </div>

                  {/* Complete Job Trigger */}
                  <button
                    onClick={handleCompleteRepair}
                    className="w-full py-2 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-bold flex items-center justify-center gap-2 shadow btn-tactile"
                  >
                    <Camera className="w-3.5 h-3.5" />
                    <span>UPLOAD PROOF & COMPLETE</span>
                  </button>
                </div>
              )}
            </div>
          ) : (
            <div className="bg-white p-5 rounded-2xl border border-slate-200 text-center space-y-2 shadow-sm">
              <Wrench className="w-8 h-8 text-[#7B4B2A] mx-auto animate-pulse" />
              <h3 className="text-xs font-extrabold text-[#0F382B]">Listening for Emergency Jobs...</h3>
              <p className="text-[10px] text-[#5D6D64]">
                When a customer submits a repair request in User view, it will pop up here live!
              </p>
            </div>
          )}
        </div>
      )}

      {/* TAB 2: TECHNICIAN WORK HISTORY */}
      {activeTab === 'history' && (
        <div className="space-y-2">
          <div className="bg-white p-3 rounded-2xl border border-slate-200 space-y-2 shadow-sm">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2">
              <h4 className="text-xs font-black text-[#0F382B] flex items-center gap-1.5">
                <Award className="w-3.5 h-3.5 text-[#7B4B2A]" />
                <span>Completed Work History</span>
              </h4>
              <span className="text-[9px] font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                4 Jobs Completed
              </span>
            </div>

            <div className="space-y-2 max-h-72 overflow-y-auto">
              {completedWorkHistory.map((w) => (
                <div
                  key={w.id}
                  className="p-2.5 rounded-xl bg-[#F8F7F3] border border-slate-200 space-y-1 text-xs"
                >
                  <div className="flex items-center justify-between font-bold">
                    <span className="text-[#0F382B] truncate">{w.title}</span>
                    <span className="text-emerald-800 bg-emerald-100 px-1.5 py-0.2 rounded text-[9px]">
                      {w.status}
                    </span>
                  </div>

                  <div className="flex items-center justify-between text-[10px] text-[#5D6D64]">
                    <span>Cust: {w.customer} • {w.date}</span>
                    <span className="font-bold text-amber-800 flex items-center gap-0.5">
                      <Star className="w-2.5 h-2.5 fill-amber-500 text-amber-500" />
                      {w.rating}
                    </span>
                  </div>

                  <div className="flex items-center justify-between pt-1 border-t border-slate-200/80 text-[10px]">
                    <span className="text-slate-500">{w.category}</span>
                    <span className="font-extrabold text-[#7B4B2A]">Earned: {w.payout}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* TAB 3: PAYMENTS & EARNINGS HISTORY */}
      {activeTab === 'payments' && (
        <div className="space-y-3">
          {/* Affordable Earnings Overview Cards */}
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-[#0F382B] text-white p-3 rounded-xl shadow border border-emerald-500/30">
              <div className="flex items-center justify-between text-[10px] font-bold text-emerald-300">
                <span>TODAY'S PAYOUT</span>
                <TrendingUp className="w-3.5 h-3.5" />
              </div>
              <p className="text-base font-black mt-1">₹ 850.00</p>
              <p className="text-[9px] text-emerald-200/70">2 Jobs Completed</p>
            </div>

            <div className="bg-[#7B4B2A] text-white p-3 rounded-xl shadow border border-amber-400/30">
              <div className="flex items-center justify-between text-[10px] font-bold text-amber-200">
                <span>WEEKLY TOTAL</span>
                <IndianRupee className="w-3.5 h-3.5" />
              </div>
              <p className="text-base font-black mt-1">₹ 4,850.00</p>
              <p className="text-[9px] text-amber-100/70">Instant UPI Transfer</p>
            </div>
          </div>

          <div className="bg-white p-3 rounded-2xl border border-slate-200 space-y-2 shadow-sm">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2">
              <h4 className="text-xs font-black text-[#0F382B] flex items-center gap-1.5">
                <History className="w-3.5 h-3.5 text-[#7B4B2A]" />
                <span>UPI / Bank Payout History</span>
              </h4>
              <span className="text-[9px] font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                Direct Sync
              </span>
            </div>

            <div className="space-y-2 max-h-60 overflow-y-auto">
              {[
                { id: 'PAY-101', job: 'Daikin Chiller Repair', amount: '₹ 650.00', date: '10 Aug 2026', status: 'PAID' },
                { id: 'PAY-102', job: 'Split AC Service', amount: '₹ 450.00', date: '08 Aug 2026', status: 'PAID' },
                { id: 'PAY-103', job: 'Washing Machine Belt', amount: '₹ 350.00', date: '05 Aug 2026', status: 'PAID' },
              ].map((p) => (
                <div key={p.id} className="p-2 rounded-xl bg-[#F8F7F3] border border-slate-200 flex items-center justify-between text-xs">
                  <div>
                    <div className="font-bold text-[#0F382B]">{p.job}</div>
                    <div className="text-[9px] text-slate-500">{p.date} • {p.id}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-extrabold text-[#7B4B2A]">{p.amount}</div>
                    <span className="text-[8px] font-bold bg-emerald-100 text-emerald-800 px-1.5 py-0.2 rounded">
                      {p.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* TAB 4: TECHNICIAN PROFILE */}
      {activeTab === 'profile' && (
        <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3 shadow-sm text-xs">
          <div className="flex items-center gap-3 border-b border-slate-100 pb-3">
            <img
              src={activeTech.avatar}
              alt={activeTech.name}
              className="w-14 h-14 rounded-2xl object-cover border-2 border-[#0F382B]"
            />
            <div>
              <h3 className="font-black text-sm text-[#0F382B]">{activeTech.name}</h3>
              <p className="text-[11px] text-[#7B4B2A] font-bold">{activeTech.speciality}</p>
              <p className="text-[10px] text-[#5D6D64]">{activeTech.vehicle}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-center">
            <div className="p-2.5 bg-[#F8F7F3] rounded-xl border border-slate-200">
              <span className="text-[10px] text-[#5D6D64] block">Jobs Completed</span>
              <span className="font-black text-sm text-[#0F382B]">{activeTech.completedJobs}</span>
            </div>

            <div className="p-2.5 bg-[#F8F7F3] rounded-xl border border-slate-200">
              <span className="text-[10px] text-[#5D6D64] block">Rating Score</span>
              <span className="font-black text-sm text-[#7B4B2A]">★ {activeTech.rating} / 5.0</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
