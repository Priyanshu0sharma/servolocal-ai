'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { MOCK_PAYMENT_RECORDS } from '../../data/mockData';
import {
  Wrench,
  Radio,
  Bell,
  CheckCircle2,
  MapPin,
  MessageSquare,
  Navigation,
  ShieldCheck,
  Send,
  Camera,
  IndianRupee,
  History,
  TrendingUp,
  CreditCard,
  UserCheck,
  Briefcase
} from 'lucide-react';

export const TechDashboard: React.FC = () => {
  const {
    activeTech,
    toggleTechOnline,
    activeJob,
    acceptJobByTech,
    updateJobStatus,
    sendChatMessage,
    completeJobByTech,
  } = usePrototype();

  const [activeTab, setActiveTab] = useState<'jobs' | 'payments' | 'profile'>('jobs');
  const [chatInput, setChatInput] = useState('');
  const [techNotes, setTechNotes] = useState(
    'Replaced high-pressure cutoff switch with OEM assembly. Vacuum purged refrigerant loop & recharged. Operating pressure normal.'
  );

  const handleSendChat = (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim()) return;
    sendChatMessage(chatInput, 'technician');
    setChatInput('');
  };

  const handleCompleteRepair = () => {
    completeJobByTech({
      beforeUrl:
        activeJob?.media[0]?.url ||
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&auto=format&fit=crop&q=80',
      afterUrl:
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80',
      technicianNotes: techNotes,
    });
  };

  return (
    <div className="p-3 space-y-3 animate-fade-in pb-6 bg-[#F8F6F0]">
      {/* Tech Header Banner */}
      <div className="bg-[#1B4332] text-white p-3 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <img
            src={activeTech.avatar}
            alt={activeTech.name}
            className="w-10 h-10 rounded-xl object-cover border-2 border-amber-400 shrink-0"
          />
          <div>
            <div className="flex items-center gap-1 text-[9px] font-mono text-amber-300 font-bold uppercase">
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

      {/* Navigation Sub-Tabs */}
      <div className="grid grid-cols-3 gap-1 bg-[#EAE6DF] p-1 rounded-xl border border-[#1B4332]/10 text-center">
        <button
          onClick={() => setActiveTab('jobs')}
          className={`py-1.5 rounded-lg text-[10px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'jobs'
              ? 'bg-[#1B4332] text-white shadow'
              : 'text-[#1C2520] hover:bg-white/50'
          }`}
        >
          <Briefcase className="w-3 h-3" />
          <span>Jobs</span>
        </button>

        <button
          onClick={() => setActiveTab('payments')}
          className={`py-1.5 rounded-lg text-[10px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'payments'
              ? 'bg-[#1B4332] text-white shadow'
              : 'text-[#1C2520] hover:bg-white/50'
          }`}
        >
          <IndianRupee className="w-3 h-3" />
          <span>Payments</span>
        </button>

        <button
          onClick={() => setActiveTab('profile')}
          className={`py-1.5 rounded-lg text-[10px] font-extrabold transition-all flex items-center justify-center gap-1 ${
            activeTab === 'profile'
              ? 'bg-[#1B4332] text-white shadow'
              : 'text-[#1C2520] hover:bg-white/50'
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
            <div className="bg-white p-3.5 rounded-2xl border-2 border-[#1B4332] shadow-xl space-y-3">
              <div className="flex items-center justify-between border-b border-[#1B4332]/10 pb-2">
                <div className="flex items-center gap-1.5">
                  <Bell className="w-4 h-4 text-amber-600 animate-bounce" />
                  <span className="text-xs font-black text-[#1B4332] uppercase">
                    Dispatch Request ({activeJob.requestCode})
                  </span>
                </div>
                <span className="font-mono text-[9px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-900 border border-amber-300">
                  {activeJob.status}
                </span>
              </div>

              {/* Job Details Card */}
              <div className="bg-[#FFF8F1] p-3 rounded-xl border border-[#1B4332]/12 space-y-2 text-xs">
                <div className="flex items-center justify-between font-bold">
                  <span className="text-[#1B4332] truncate">{activeJob.machineName}</span>
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

                <div className="flex items-center justify-between pt-1 border-t border-[#1B4332]/10 text-[10px] font-bold">
                  <div className="flex items-center gap-1 text-[#1C2520] truncate">
                    <MapPin className="w-3.5 h-3.5 text-[#1B4332]" />
                    <span className="truncate">{activeJob.location.address}</span>
                  </div>
                  <span className="text-[#7B4B2A] bg-amber-100 px-1.5 py-0.5 rounded">
                    Est: ₹{activeJob.aiDiagnosis.estimatedTotal}
                  </span>
                </div>
              </div>

              {/* Job Action Buttons */}
              {activeJob.status === 'DISPATCHING' ? (
                <button
                  onClick={() => acceptJobByTech(activeTech.id)}
                  className="w-full py-2.5 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
                >
                  <CheckCircle2 className="w-4 h-4 text-amber-300" />
                  <span>ACCEPT JOB & NAVIGATE</span>
                </button>
              ) : (
                <div className="space-y-2">
                  <span className="text-[10px] font-bold text-[#1B4332] uppercase block">
                    Update Service Status:
                  </span>

                  <div className="grid grid-cols-3 gap-1">
                    {(['ON_THE_WAY', 'ARRIVED', 'REPAIR_IN_PROGRESS'] as const).map((st) => (
                      <button
                        key={st}
                        onClick={() => updateJobStatus(st)}
                        className={`py-1.5 rounded-lg text-[9px] font-bold transition-all btn-tactile border ${
                          activeJob.status === st
                            ? 'bg-[#1B4332] text-white border-[#1B4332]'
                            : 'bg-[#FFF8F1] text-[#1C2520] border-[#1B4332]/15'
                        }`}
                      >
                        {st.replace(/_/g, ' ')}
                      </button>
                    ))}
                  </div>

                  {/* Complete Job Trigger */}
                  <button
                    onClick={handleCompleteRepair}
                    className="w-full py-2 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-bold flex items-center justify-center gap-2 shadow btn-tactile border border-amber-500/30"
                  >
                    <Camera className="w-3.5 h-3.5" />
                    <span>UPLOAD PROOF & COMPLETE JOB</span>
                  </button>
                </div>
              )}
            </div>
          ) : (
            <div className="bg-white p-5 rounded-2xl border border-[#1B4332]/15 text-center space-y-2 shadow-sm">
              <Wrench className="w-8 h-8 text-[#7B4B2A] mx-auto animate-pulse" />
              <h3 className="text-xs font-extrabold text-[#1B4332]">Listening for Emergency Jobs...</h3>
              <p className="text-[10px] text-[#5D6D64]">
                When a customer submits a repair request in User view, it will pop up here live!
              </p>
            </div>
          )}
        </div>
      )}

      {/* TAB 2: PAYMENTS & EARNINGS HISTORY */}
      {activeTab === 'payments' && (
        <div className="space-y-3">
          {/* Earnings Overview Cards */}
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-[#1B4332] text-white p-3 rounded-xl shadow border border-emerald-500/30">
              <div className="flex items-center justify-between text-[10px] font-bold text-amber-300">
                <span>TODAY'S PAYOUT</span>
                <TrendingUp className="w-3.5 h-3.5" />
              </div>
              <p className="text-base font-black mt-1">₹ 2,350.00</p>
              <p className="text-[9px] text-emerald-200/70">2 Jobs Completed</p>
            </div>

            <div className="bg-[#7B4B2A] text-white p-3 rounded-xl shadow border border-amber-400/30">
              <div className="flex items-center justify-between text-[10px] font-bold text-amber-200">
                <span>WEEKLY TOTAL</span>
                <IndianRupee className="w-3.5 h-3.5" />
              </div>
              <p className="text-base font-black mt-1">₹ 14,800.00</p>
              <p className="text-[9px] text-amber-100/70">Instant UPI Sync</p>
            </div>
          </div>

          {/* Payment History List */}
          <div className="bg-white p-3 rounded-2xl border border-[#1B4332]/15 space-y-2 shadow-sm">
            <div className="flex items-center justify-between border-b border-[#1B4332]/10 pb-2">
              <h4 className="text-xs font-black text-[#1B4332] flex items-center gap-1.5">
                <History className="w-3.5 h-3.5 text-[#7B4B2A]" />
                <span>Transaction & Payout History</span>
              </h4>
              <span className="text-[9px] font-bold text-[#7B4B2A] bg-amber-50 px-2 py-0.5 rounded border border-amber-200">
                Direct UPI / Bank
              </span>
            </div>

            <div className="space-y-2 max-h-64 overflow-y-auto">
              {MOCK_PAYMENT_RECORDS.map((rec) => (
                <div
                  key={rec.id}
                  className="p-2.5 rounded-xl bg-[#FFF8F1] border border-[#1B4332]/10 flex items-center justify-between text-xs hover:border-[#1B4332]/30 transition-all"
                >
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-1.5 font-bold text-[#1B4332]">
                      <span>{rec.customerName}</span>
                      <span className="text-[9px] font-mono font-normal text-[#5D6D64]">
                        ({rec.jobId})
                      </span>
                    </div>
                    <p className="text-[10px] text-[#5D6D64]">{rec.machineCategory}</p>
                    <p className="text-[9px] text-slate-400 font-mono">{rec.date}</p>
                  </div>

                  <div className="text-right space-y-0.5">
                    <p className="font-black text-[#1B4332] text-xs">₹{rec.techPayout.toFixed(2)}</p>
                    <span
                      className={`inline-block text-[8px] font-bold px-1.5 py-0.5 rounded ${
                        rec.status === 'PAID'
                          ? 'bg-emerald-100 text-emerald-800 border border-emerald-300'
                          : 'bg-amber-100 text-amber-800 border border-amber-300'
                      }`}
                    >
                      {rec.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* TAB 3: TECHNICIAN PROFILE */}
      {activeTab === 'profile' && (
        <div className="bg-white p-4 rounded-2xl border border-[#1B4332]/15 space-y-3 shadow-sm text-xs">
          <div className="flex items-center gap-3 border-b border-[#1B4332]/10 pb-3">
            <img
              src={activeTech.avatar}
              alt={activeTech.name}
              className="w-14 h-14 rounded-2xl object-cover border-2 border-[#1B4332]"
            />
            <div>
              <h3 className="font-black text-sm text-[#1B4332]">{activeTech.name}</h3>
              <p className="text-[11px] text-[#7B4B2A] font-bold">{activeTech.speciality}</p>
              <p className="text-[10px] text-[#5D6D64]">{activeTech.vehicle}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-center">
            <div className="p-2 bg-[#FFF8F1] rounded-xl border border-[#1B4332]/10">
              <span className="text-[10px] text-[#5D6D64] block">Jobs Completed</span>
              <span className="font-black text-sm text-[#1B4332]">{activeTech.completedJobs}</span>
            </div>

            <div className="p-2 bg-[#FFF8F1] rounded-xl border border-[#1B4332]/10">
              <span className="text-[10px] text-[#5D6D64] block">Rating Score</span>
              <span className="font-black text-sm text-[#7B4B2A]">★ {activeTech.rating} / 5.0</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
