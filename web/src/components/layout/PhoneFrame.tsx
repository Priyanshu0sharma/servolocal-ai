'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Wifi, Signal, Battery, Home, Wrench, MessageSquare, User, Activity } from 'lucide-react';

interface PhoneFrameProps {
  children: React.ReactNode;
}

export const PhoneFrame: React.FC<PhoneFrameProps> = ({ children }) => {
  const { currentStep, setCurrentStep, activeRole } = usePrototype();

  return (
    <div className="relative mx-auto my-auto max-w-[380px] w-full flex flex-col items-center">
      {/* Phone Outer Chassis */}
      <div className="relative w-full h-[720px] bg-[#141C18] rounded-[48px] p-3 shadow-2xl border-[6px] border-[#2C4C66]/80 ring-1 ring-white/20 flex flex-col overflow-hidden backdrop-blur-xl group">
        {/* Device Side Buttons simulation */}
        <div className="absolute -left-[9px] top-28 w-[3px] h-8 bg-slate-700 rounded-l-md" />
        <div className="absolute -left-[9px] top-40 w-[3px] h-12 bg-slate-700 rounded-l-md" />
        <div className="absolute -right-[9px] top-32 w-[3px] h-14 bg-slate-700 rounded-r-md" />

        {/* Dynamic Island / Speaker Notch */}
        <div className="w-full bg-[#1C2520] h-6 flex items-center justify-between px-6 shrink-0 pt-1 text-white text-[10px] font-mono z-40 rounded-t-[36px]">
          <span>9:41</span>
          <div className="w-20 h-4 bg-black rounded-full flex items-center justify-center border border-white/10 gap-1.5 shadow-inner">
            <span className="w-2 h-2 rounded-full bg-slate-900 border border-slate-700" />
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
          </div>
          <div className="flex items-center gap-1.5 text-emerald-400">
            <Signal className="w-3 h-3" />
            <Wifi className="w-3 h-3" />
            <Battery className="w-3.5 h-3.5" />
          </div>
        </div>

        {/* Actual Mobile App Screen Container */}
        <div className="flex-1 bg-[#F8F6F0] rounded-[36px] overflow-y-auto flex flex-col relative shadow-inner">
          {children}
        </div>

        {/* Phone Bottom Home Indicator */}
        <div className="h-5 bg-[#1C2520] shrink-0 flex items-center justify-center rounded-b-[36px] z-40">
          <div className="w-32 h-1 bg-white/40 rounded-full" />
        </div>
      </div>
    </div>
  );
};
