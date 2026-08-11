'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { JobStatus } from '../../types/prototype';
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
    setCurrentStep,
    userProfile,
  } = usePrototype();

  const [chatInput, setChatInput] = useState('');
  const [techNotes, setTechNotes] = useState(
    'Replaced high-pressure cutoff switch with OEM assembly. Refrigerant loop vacuum purged & recharged. Operating pressure normal.'
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
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Tech Header Banner */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div className="flex items-center gap-3">
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
          </div>
        </div>

        {/* ONLINE / OFFLINE Switch */}
        <button
          onClick={() => toggleTechOnline(activeTech.id)}
          className={`px-3 py-1.5 rounded-xl font-extrabold text-[10px] flex items-center gap-1.5 shadow transition-all btn-tactile ${
            activeTech.isOnline
              ? 'bg-emerald-500 text-slate-950'
              : 'bg-rose-700 text-white'
          }`}
        >
          <Radio className={`w-3.5 h-3.5 ${activeTech.isOnline ? 'animate-pulse' : ''}`} />
          <span>{activeTech.isOnline ? 'ONLINE' : 'OFFLINE'}</span>
        </button>
      </div>

      {/* Active Job Alert */}
      {activeJob ? (
        <div className="bg-white p-4 rounded-2xl border-2 border-[#1B4332] shadow-xl space-y-3">
          <div className="flex items-center justify-between border-b border-[#1B4332]/10 pb-2">
            <div className="flex items-center gap-1.5">
              <Bell className="w-4 h-4 text-amber-600 animate-bounce" />
              <span className="text-xs font-black text-[#1B4332] uppercase">
                New Request ({activeJob.requestCode})
              </span>
            </div>
            <span className="font-mono text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-900 border border-amber-300">
              {activeJob.status}
            </span>
          </div>

          {/* Job Info Card */}
          <div className="bg-[#FFF8F1] p-3 rounded-xl border border-[#1B4332]/12 space-y-2 text-xs">
            <div className="flex items-center justify-between font-bold">
              <span className="text-[#1B4332] truncate">{activeJob.machineName}</span>
              <span className="text-rose-800 bg-rose-100 px-2 py-0.5 rounded text-[9px] uppercase">
                {activeJob.urgency}
              </span>
            </div>

            {/* AI Diagnosis Tag */}
            <div className="p-2 rounded-lg bg-emerald-50 border border-emerald-300 text-[10px] font-mono text-emerald-900">
              AI Diagnosis: {activeJob.aiDiagnosis.detectedIssue}
            </div>

            <div className="text-[#5D6D64] text-[11px] truncate">
              {activeJob.problemDescription}
            </div>

            <div className="flex items-center gap-1 text-[10px] font-semibold text-[#1C2520] pt-1 border-t border-[#1B4332]/10">
              <MapPin className="w-3.5 h-3.5 text-[#1B4332]" />
              <span className="truncate">{activeJob.location.address}</span>
            </div>
          </div>

          {/* Action Buttons */}
          {activeJob.status === 'DISPATCHING' ? (
            <button
              onClick={() => acceptJobByTech(activeTech.id)}
              className="w-full py-3 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
            >
              <CheckCircle2 className="w-4 h-4 text-amber-300" />
              <span>ACCEPT JOB & START NAVIGATION</span>
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
                    className={`py-1.5 rounded-lg text-[10px] font-bold transition-all btn-tactile border ${
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
                className="w-full py-2.5 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-bold flex items-center justify-center gap-2 shadow btn-tactile border border-amber-500/30"
              >
                <Camera className="w-3.5 h-3.5" />
                <span>UPLOAD PROOF & COMPLETE JOB</span>
              </button>
            </div>
          )}
        </div>
      ) : (
        <div className="bg-white p-6 rounded-2xl border border-[#1B4332]/15 text-center space-y-2">
          <Wrench className="w-8 h-8 text-[#7B4B2A] mx-auto animate-pulse" />
          <h3 className="text-xs font-extrabold text-[#1B4332]">Listening for Emergency Jobs...</h3>
          <p className="text-[11px] text-[#5D6D64]">
            When a customer submits a repair request in User view, it will pop up here live!
          </p>
        </div>
      )}
    </div>
  );
};
