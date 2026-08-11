'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { AuthModal } from '../auth/AuthModal';
import { AdminDashboardView } from '../admin/AdminDashboardView';
import { TechDashboard } from '../technician/TechDashboard';
import { RealtimeNotification } from '../common/RealtimeNotification';

import { LandingPortalScreen } from '../steps/LandingPortalScreen';
import { Step1IssueUploadScreen } from '../steps/Step1IssueUploadScreen';
import { Step2AIDiagnosisScreen } from '../steps/Step2AIDiagnosisScreen';
import { Step3CostEstimationScreen } from '../steps/Step3CostEstimationScreen';
import { Step4SmartDispatchScreen } from '../steps/Step4SmartDispatchScreen';
import { Step5RepairProgressScreen } from '../steps/Step5RepairProgressScreen';
import { Step6CompletionFeedbackScreen } from '../steps/Step6CompletionFeedbackScreen';


import {
  Wrench,
  User,
  ShieldCheck,
  LayoutDashboard,
  Zap,
  Clock,
  CreditCard,
  Settings,
  LogOut,
  Bell,
  Search,
  CheckCircle2,
  AlertTriangle,
  ChevronRight,
  Layers
} from 'lucide-react';

export const ProductionWebLayout: React.FC = () => {
  const { currentStep, setCurrentStep, activeRole, setActiveRole, userProfile, activeJob, resetPrototype } = usePrototype();
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [sidebarTab, setSidebarTab] = useState<'repair_flow' | 'requests' | 'technicians' | 'admin' | 'settings'>('repair_flow');

  const renderActiveStepComponent = () => {
    switch (currentStep) {
      case 0:
        return <LandingPortalScreen />;
      case 1:
        return <Step1IssueUploadScreen />;
      case 2:
        return <Step2AIDiagnosisScreen />;
      case 3:
        return <Step3CostEstimationScreen />;
      case 4:
        return <Step4SmartDispatchScreen />;
      case 5:
        return <Step5RepairProgressScreen />;
      case 6:
        return <Step6CompletionFeedbackScreen />;
      default:
        return <Step1IssueUploadScreen />;
    }
  };

  const stepsList = [
    { id: 1, title: '1. Report Issue', subtitle: 'Photo / Video & Symptoms' },
    { id: 2, title: '2. AI Diagnosis', subtitle: 'Computer Vision Analysis' },
    { id: 3, title: '3. Cost & Parts', subtitle: 'Itemized Pricing Matrix' },
    { id: 4, title: '4. Smart Dispatch', subtitle: 'Nearest Technician Match' },
    { id: 5, title: '5. Repair Tracking', subtitle: 'Live Location & Status' },
    { id: 6, title: '6. Completion', subtitle: 'Digital Proof & Signature' },
  ];

  return (
    <div className="flex flex-col h-screen w-screen bg-[#0F172A] text-slate-100 overflow-hidden">
      {/* AUTH MODAL */}
      <AuthModal isOpen={isAuthOpen} onClose={() => setIsAuthOpen(false)} />

      {/* TOP HEADER BAR */}
      <header className="h-16 bg-[#0A2E1D] border-b border-emerald-900/40 px-6 flex items-center justify-between shrink-0 z-30">
        {/* Brand */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-amber-500 flex items-center justify-center font-extrabold text-white text-lg shadow-lg border border-white/20">
            ⬡
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-extrabold tracking-wider text-base uppercase text-white">
                ServoLocal AI
              </span>
              <span className="bg-emerald-500/20 text-emerald-300 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-widest border border-emerald-500/30">
                Production SaaS
              </span>
            </div>
            <p className="text-[11px] text-emerald-300/70 hidden sm:block">
              AI-Powered Industrial Emergency Repair & Dispatch Operations
            </p>
          </div>
        </div>

        {/* Center Role Switcher Control Bar */}
        <div className="flex items-center bg-slate-900/80 p-1 rounded-2xl border border-slate-700/60 shadow-inner">
          <button
            onClick={() => {
              setActiveRole('user');
              setSidebarTab('repair_flow');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
              activeRole === 'user'
                ? 'bg-emerald-600 text-white shadow-md'
                : 'text-slate-400 hover:text-white hover:bg-slate-800'
            }`}
          >
            <User className="w-3.5 h-3.5" />
            <span>Customer Workspace</span>
          </button>

          <button
            onClick={() => {
              setActiveRole('technician');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
              activeRole === 'technician'
                ? 'bg-amber-600 text-white shadow-md'
                : 'text-slate-400 hover:text-white hover:bg-slate-800'
            }`}
          >
            <Wrench className="w-3.5 h-3.5" />
            <span>Technician Portal</span>
          </button>

          <button
            onClick={() => {
              setActiveRole('admin');
              setSidebarTab('admin');
            }}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
              activeRole === 'admin'
                ? 'bg-blue-600 text-white shadow-md'
                : 'text-slate-400 hover:text-white hover:bg-slate-800'
            }`}
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Admin Command</span>
          </button>
        </div>

        {/* Right Controls */}
        <div className="flex items-center gap-3">
          <div className="hidden lg:flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-950/60 border border-emerald-600/30 text-[11px] text-emerald-300">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
            </span>
            <span className="font-mono">Sync: ACTIVE</span>
          </div>

          <button
            onClick={() => setIsAuthOpen(true)}
            className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-xs font-bold text-slate-200 transition-all"
          >
            <img src={userProfile.avatar} className="w-5 h-5 rounded-full object-cover" alt="User" />
            <span>{userProfile.name.split(' ')[0]}</span>
          </button>
        </div>
      </header>

      <RealtimeNotification />

      {/* RENDER ADMIN DASHBOARD FULL SCREEN IF ADMIN ROLE ACTIVE */}
      {activeRole === 'admin' ? (
        <div className="flex-1 overflow-hidden">
          <AdminDashboardView />
        </div>
      ) : activeRole === 'technician' ? (
        <div className="flex-1 overflow-y-auto bg-slate-950 p-6 flex justify-center">
          <div className="max-w-2xl w-full">
            <TechDashboard />
          </div>
        </div>
      ) : (
        /* CUSTOMER PRODUCTION SAAS WORKSPACE */
        <div className="flex-1 flex overflow-hidden">
          {/* LEFT SAAS NAVIGATION SIDEBAR */}
          <aside className="w-64 bg-[#0A2E1D]/90 border-r border-emerald-900/30 flex flex-col shrink-0 p-4 space-y-6">
            <div className="space-y-1">
              <span className="text-[10px] font-bold uppercase tracking-wider text-emerald-400 block px-2">Navigation Workspace</span>
              <nav className="space-y-1 text-xs font-semibold">
                <button
                  onClick={() => setSidebarTab('repair_flow')}
                  className={`w-full flex items-center justify-between p-2.5 rounded-xl transition-all ${
                    sidebarTab === 'repair_flow'
                      ? 'bg-emerald-600 text-white font-bold shadow-md'
                      : 'text-slate-300 hover:bg-slate-800/60'
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <Zap className="w-4 h-4 text-amber-400" />
                    <span>Emergency Repair Flow</span>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 opacity-60" />
                </button>

                <button
                  onClick={() => setSidebarTab('requests')}
                  className={`w-full flex items-center justify-between p-2.5 rounded-xl transition-all ${
                    sidebarTab === 'requests'
                      ? 'bg-emerald-600 text-white font-bold shadow-md'
                      : 'text-slate-300 hover:bg-slate-800/60'
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <Clock className="w-4 h-4 text-emerald-400" />
                    <span>My Repair Requests</span>
                  </div>
                  <span className="bg-emerald-950 text-emerald-300 text-[10px] font-mono font-bold px-2 py-0.5 rounded-full">
                    {activeJob ? '1 Active' : '0'}
                  </span>
                </button>

                <button
                  onClick={() => setSidebarTab('technicians')}
                  className={`w-full flex items-center justify-between p-2.5 rounded-xl transition-all ${
                    sidebarTab === 'technicians'
                      ? 'bg-emerald-600 text-white font-bold shadow-md'
                      : 'text-slate-300 hover:bg-slate-800/60'
                  }`}
                >
                  <div className="flex items-center gap-2">
                    <Wrench className="w-4 h-4 text-blue-400" />
                    <span>Technicians & Payouts</span>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 opacity-60" />
                </button>

                <button
                  onClick={() => {
                    setActiveRole('admin');
                    setSidebarTab('admin');
                  }}
                  className="w-full flex items-center justify-between p-2.5 rounded-xl text-slate-300 hover:bg-slate-800/60 transition-all"
                >
                  <div className="flex items-center gap-2">
                    <ShieldCheck className="w-4 h-4 text-purple-400" />
                    <span>Executive Admin Panel</span>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 opacity-60" />
                </button>
              </nav>
            </div>

            {/* STEP PROGRESS BAR */}
            <div className="p-3.5 rounded-2xl bg-slate-900/90 border border-slate-800 space-y-3">
              <div className="flex justify-between items-center text-xs font-bold">
                <span className="text-emerald-400">Workflow Progress</span>
                <span className="font-mono text-amber-400">Step {currentStep}/6</span>
              </div>

              <div className="space-y-1.5">
                {stepsList.map((st) => (
                  <button
                    key={st.id}
                    onClick={() => {
                      setSidebarTab('repair_flow');
                      setCurrentStep(st.id as any);
                    }}
                    className={`w-full text-left p-2 rounded-xl text-[11px] font-semibold flex items-center justify-between transition-all ${
                      currentStep === st.id
                        ? 'bg-emerald-600 text-white font-bold shadow-md'
                        : currentStep > st.id
                        ? 'bg-emerald-950/60 text-emerald-300 border border-emerald-800/40'
                        : 'text-slate-400 hover:bg-slate-800/50'
                    }`}
                  >
                    <span>{st.title}</span>
                    {currentStep > st.id && <CheckCircle2 className="w-3 h-3 text-emerald-400" />}
                  </button>
                ))}
              </div>
            </div>

            {/* RESET BUTTON */}
            <button
              onClick={resetPrototype}
              className="mt-auto w-full py-2 bg-slate-900 hover:bg-rose-950 text-slate-400 hover:text-rose-300 border border-slate-800 rounded-xl text-xs font-bold transition-all"
            >
              Reset Session State
            </button>
          </aside>

          {/* MAIN SAAS CONTENT WORKSPACE */}
          <main className="flex-1 overflow-y-auto p-6 bg-[#0F172A]">
            {sidebarTab === 'repair_flow' && (
              <div className="max-w-4xl mx-auto space-y-6">
                {/* STEP CONTENT IN FULL WIDTH DESKTOP SAAS CARD */}
                <div className="bg-slate-900/90 border border-slate-800 rounded-3xl p-6 shadow-2xl space-y-4">
                  {renderActiveStepComponent()}
                </div>
              </div>
            )}

            {sidebarTab === 'requests' && (
              <div className="max-w-4xl mx-auto space-y-6 animate-fadeIn">
                <div className="bg-slate-900/90 border border-slate-800 rounded-3xl p-6 space-y-4">
                  <h2 className="text-base font-extrabold text-white flex items-center gap-2">
                    <Clock className="w-5 h-5 text-emerald-400" /> Active & Historical Repair Requests
                  </h2>

                  {activeJob ? (
                    <div className="p-4 rounded-2xl bg-slate-950 border border-emerald-500/30 space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-xs font-mono font-bold text-amber-400">{activeJob.requestCode}</span>
                        <span className="bg-emerald-500/20 text-emerald-300 text-xs font-bold px-3 py-1 rounded-full border border-emerald-500/30">
                          {activeJob.status}
                        </span>
                      </div>
                      <h3 className="font-extrabold text-sm text-white">{activeJob.machineName}</h3>
                      <p className="text-xs text-slate-300">{activeJob.problemDescription}</p>
                      <div className="flex justify-between items-center pt-2 border-t border-slate-800 text-xs font-bold text-slate-400">
                        <span>Technician: {activeJob.assignedTechnician?.name || 'Searching...'}</span>
                        <span className="text-white">Est. Total: ₹{activeJob.aiDiagnosis.estimatedTotal}</span>
                      </div>
                    </div>
                  ) : (
                    <p className="text-xs text-slate-400">No active repair requests. Click "Report Issue" to initiate AI diagnosis.</p>
                  )}
                </div>
              </div>
            )}

            {sidebarTab === 'technicians' && (
              <div className="max-w-4xl mx-auto space-y-6 animate-fadeIn">
                <div className="bg-slate-900/90 border border-slate-800 rounded-3xl p-6 space-y-4">
                  <h2 className="text-base font-extrabold text-white flex items-center gap-2">
                    <Wrench className="w-5 h-5 text-blue-400" /> Verified Field Technicians & Razorpay Bank Payouts
                  </h2>

                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs text-slate-300">
                      <thead className="bg-slate-950 text-slate-400 uppercase text-[10px] tracking-wider border-b border-slate-800">
                        <tr>
                          <th className="py-3 px-4">Technician</th>
                          <th className="py-3 px-4">Speciality</th>
                          <th className="py-3 px-4">Rating</th>
                          <th className="py-3 px-4">Bank Payout Info</th>
                          <th className="py-3 px-4">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-800">
                        <tr className="hover:bg-slate-800/40">
                          <td className="py-3 px-4 font-bold text-white">Rajesh Kumar</td>
                          <td className="py-3 px-4">Commercial HVAC & Chiller</td>
                          <td className="py-3 px-4 text-amber-400 font-bold">⭐ 4.9 (142 Jobs)</td>
                          <td className="py-3 px-4 font-mono text-[11px]">HDFC Bank • A/C 9182...7890<br/><span className="text-emerald-400 font-bold">UPI: rajesh@okaxis</span></td>
                          <td className="py-3 px-4"><span className="bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full font-bold">VERIFIED</span></td>
                        </tr>
                        <tr className="hover:bg-slate-800/40">
                          <td className="py-3 px-4 font-bold text-white">Vikram Singh</td>
                          <td className="py-3 px-4">Washing Machine & Motors</td>
                          <td className="py-3 px-4 text-amber-400 font-bold">⭐ 4.8 (98 Jobs)</td>
                          <td className="py-3 px-4 font-mono text-[11px]">SBI • A/C 4512...3341<br/><span className="text-emerald-400 font-bold">UPI: vikram@sbi</span></td>
                          <td className="py-3 px-4"><span className="bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full font-bold">VERIFIED</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            )}
          </main>
        </div>
      )}
    </div>
  );
};
