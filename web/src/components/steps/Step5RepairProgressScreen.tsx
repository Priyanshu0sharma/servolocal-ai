'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { JobStatus } from '../../types/prototype';
import { Wrench, MapPin, Navigation, Send, MessageSquare, CheckCircle2, ArrowRight } from 'lucide-react';

export const Step5RepairProgressScreen: React.FC = () => {
  const { activeJob, updateJobStatus, sendChatMessage, activeRole, setCurrentStep } = usePrototype();

  const [chatInput, setChatInput] = useState('');

  const currentStatus: JobStatus = activeJob?.status || 'ON_THE_WAY';

  const statuses: { key: JobStatus; label: string }[] = [
    { key: 'ASSIGNED', label: 'Assigned' },
    { key: 'ON_THE_WAY', label: 'On The Way' },
    { key: 'ARRIVED', label: 'Arrived' },
    { key: 'REPAIR_IN_PROGRESS', label: 'Repairing' },
  ];

  const getStatusIndex = (st: JobStatus) => {
    const idx = statuses.findIndex((s) => s.key === st);
    return idx >= 0 ? idx : 1;
  };

  const currentIndex = getStatusIndex(currentStatus);

  const handleSendChat = (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim()) return;
    sendChatMessage(chatInput);
    setChatInput('');
  };

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Wrench className="w-3.5 h-3.5" />
            <span>STEP 05 — REPAIR IN PROGRESS</span>
          </div>
          <h2 className="text-sm font-black tracking-tight">Live Status & Navigation</h2>
        </div>

        <span className="text-[10px] font-mono font-bold bg-amber-400 text-slate-950 px-2.5 py-0.5 rounded-full uppercase">
          {currentStatus.replace(/_/g, ' ')}
        </span>
      </div>

      {/* Simulated Live GPS Map */}
      <div className="relative rounded-2xl overflow-hidden border-2 border-[#1B4332] bg-[#1C2520] h-44 shadow-md flex flex-col justify-between p-3 text-white">
        <div className="absolute inset-0 bg-[radial-gradient(#2D5A43_1px,transparent_1px)] [background-size:16px_16px] opacity-40" />

        <div className="relative z-10 flex items-center justify-between bg-black/60 backdrop-blur p-2 rounded-xl border border-white/10 text-[10px]">
          <div className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
            <span className="font-bold">Live GPS Telemetry</span>
          </div>
          <span className="font-mono text-emerald-300">ETA: 8 mins</span>
        </div>

        {/* Route Line Graphic */}
        <div className="relative z-10 my-auto flex items-center justify-between px-6">
          <div className="text-center">
            <div className="w-8 h-8 rounded-full bg-[#7B4B2A] text-white mx-auto flex items-center justify-center shadow border border-amber-400">
              <Navigation className="w-4 h-4 animate-pulse" />
            </div>
            <span className="text-[9px] font-bold text-emerald-200 mt-1 block">Tech Van</span>
          </div>

          <div className="flex-1 mx-3 h-0.5 border-t-2 border-dashed border-emerald-400 relative">
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-emerald-900 text-emerald-200 text-[8px] font-mono px-1.5 py-0.2 rounded border border-emerald-500/40">
              0.8 km
            </div>
          </div>

          <div className="text-center">
            <div className="w-8 h-8 rounded-full bg-[#1B4332] text-amber-300 mx-auto flex items-center justify-center shadow border border-amber-400">
              <MapPin className="w-4 h-4" />
            </div>
            <span className="text-[9px] font-bold text-amber-200 mt-1 block">Facility</span>
          </div>
        </div>
      </div>

      {/* Stepper Progression Buttons */}
      <div className="space-y-1.5">
        <label className="text-[11px] font-bold text-[#1C2520] block">Status Progression</label>
        <div className="grid grid-cols-2 gap-1.5">
          {statuses.map((st, idx) => {
            const isPassed = idx <= currentIndex;
            const isCurrent = idx === currentIndex;
            return (
              <button
                key={st.key}
                type="button"
                onClick={() => updateJobStatus(st.key)}
                className={`p-2 rounded-xl text-left text-[11px] font-bold transition-all btn-tactile border flex items-center justify-between ${
                  isCurrent
                    ? 'bg-[#1B4332] text-white border-[#1B4332] shadow ring-1 ring-amber-400'
                    : isPassed
                    ? 'bg-[#EBF2EE] text-[#1B4332] border-[#1B4332]/30'
                    : 'bg-white text-[#5D6D64] border-[#1B4332]/10'
                }`}
              >
                <span>{st.label}</span>
                {isPassed && <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400 shrink-0" />}
              </button>
            );
          })}
        </div>
      </div>

      {/* Real-time Chat Box */}
      <div className="bg-[#FFF8F1] p-3 rounded-2xl border border-[#1B4332]/15 space-y-2">
        <div className="flex items-center justify-between text-[11px] font-bold text-[#1B4332]">
          <span className="flex items-center gap-1">
            <MessageSquare className="w-3.5 h-3.5 text-[#7B4B2A]" />
            <span>2-Way Realtime Chat</span>
          </span>
          <span className="text-[9px] font-mono text-emerald-700">Sync Active</span>
        </div>

        <div className="space-y-1.5 max-h-28 overflow-y-auto p-2 bg-white rounded-xl border border-[#1B4332]/10 text-[11px]">
          {(activeJob?.chatMessages || []).map((msg) => (
            <div key={msg.id} className="leading-snug">
              <span className="font-bold text-[#7B4B2A]">{msg.senderName}: </span>
              <span className="text-[#1C2520]">{msg.text}</span>
            </div>
          ))}
        </div>

        <form onSubmit={handleSendChat} className="flex gap-1.5">
          <input
            type="text"
            placeholder="Type message..."
            value={chatInput}
            onChange={(e) => setChatInput(e.target.value)}
            className="flex-1 px-3 py-1.5 rounded-xl text-xs border border-[#1B4332]/20 bg-white"
          />
          <button
            type="submit"
            className="p-2 rounded-xl bg-[#1B4332] text-white flex items-center justify-center btn-tactile"
          >
            <Send className="w-3.5 h-3.5" />
          </button>
        </form>
      </div>

      {/* CTA Button */}
      <button
        onClick={() => setCurrentStep(6)}
        className="w-full py-3 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile border border-amber-500/30"
      >
        <span>COMPLETE REPAIR & GENERATE PROOF</span>
        <ArrowRight className="w-4 h-4 text-amber-200" />
      </button>
    </div>
  );
};
