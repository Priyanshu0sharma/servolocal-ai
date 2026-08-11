'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { ShieldCheck, User, Wrench, RefreshCw, Layers, ExternalLink, Activity } from 'lucide-react';

export const RoleSwitcherHeader: React.FC = () => {
  const { activeRole, setActiveRole, currentStep, activeJob, resetPrototype } = usePrototype();

  return (
    <header className="h-16 bg-[#1B4332] text-white border-b border-[#2D5A43] px-4 md:px-6 flex items-center justify-between shrink-0 shadow-md z-30">
      {/* Brand logo & tagline */}
      <div className="flex items-center gap-3">
        <div className="w-9 h-9 rounded-lg bg-[#7B4B2A] flex items-center justify-center font-bold text-white shadow-inner border border-amber-600/30">
          A
        </div>
        <div>
          <div className="flex items-center gap-2">
            <span className="font-extrabold tracking-wider text-base uppercase bg-clip-text text-transparent bg-gradient-to-r from-amber-100 via-cream to-amber-200">
              AETHERION
            </span>
            <span className="bg-[#7B4B2A]/70 text-[#F5EEE6] text-[10px] font-semibold px-2 py-0.5 rounded-full uppercase tracking-widest border border-amber-500/20">
              PROTOTYPE
            </span>
          </div>
          <p className="text-[11px] text-emerald-200/70 hidden sm:block">
            Next-Gen Industrial Repair & Technician Dispatch Protocol
          </p>
        </div>
      </div>

      {/* Center Role Toggle Controls */}
      <div className="flex items-center bg-[#143527] p-1 rounded-xl border border-emerald-900/60 shadow-inner">
        <button
          onClick={() => setActiveRole('user')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all btn-tactile ${
            activeRole === 'user'
              ? 'bg-[#7B4B2A] text-white shadow-sm'
              : 'text-emerald-200/70 hover:text-white hover:bg-emerald-800/40'
          }`}
        >
          <User className="w-3.5 h-3.5" />
          <span>User Tab</span>
        </button>

        <button
          onClick={() => setActiveRole('technician')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all btn-tactile ${
            activeRole === 'technician'
              ? 'bg-[#7B4B2A] text-white shadow-sm'
              : 'text-emerald-200/70 hover:text-white hover:bg-emerald-800/40'
          }`}
        >
          <Wrench className="w-3.5 h-3.5" />
          <span>Technician Tab</span>
        </button>

        <button
          onClick={() => setActiveRole('dual')}
          className={`hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all btn-tactile ${
            activeRole === 'dual'
              ? 'bg-[#7B4B2A] text-white shadow-sm'
              : 'text-emerald-200/70 hover:text-white hover:bg-emerald-800/40'
          }`}
          title="Show User and Technician side-by-side"
        >
          <Layers className="w-3.5 h-3.5" />
          <span>Dual Split</span>
        </button>
      </div>

      {/* Right Controls: Realtime Sync Status & Reset */}
      <div className="flex items-center gap-3">
        {/* Realtime Live Pulse */}
        <div className="hidden lg:flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-950/60 border border-emerald-600/30 text-[11px] text-emerald-300">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
          </span>
          <span className="font-mono">Sync: ACTIVE</span>
        </div>

        {/* Reset Prototype button */}
        <button
          onClick={resetPrototype}
          className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-emerald-900/50 hover:bg-rose-900/60 text-emerald-200 hover:text-rose-100 text-xs font-medium border border-emerald-700/40 hover:border-rose-500/40 transition-all btn-tactile"
          title="Reset local storage and restart prototype"
        >
          <RefreshCw className="w-3.5 h-3.5" />
          <span className="hidden sm:inline">Reset</span>
        </button>

        {/* Top-Right Executive Admin Panel Shortcut */}
        <a
          href="http://localhost:8080/admin"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 text-white text-xs font-bold shadow-lg shadow-emerald-500/30 transition-all transform hover:scale-105 border border-emerald-300/30"
          title="Open Full Desktop Executive Admin Panel"
        >
          <ShieldCheck className="w-4 h-4 text-emerald-100" />
          <span>Admin Command</span>
          <ExternalLink className="w-3 h-3 text-emerald-200 ml-0.5" />
        </a>
      </div>
    </header>
  );
};

