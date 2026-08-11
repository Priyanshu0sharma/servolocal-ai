'use client';

import React from 'react';
import { Wifi, Signal, Battery } from 'lucide-react';

interface PhoneFrameProps {
  children: React.ReactNode;
}

export const PhoneFrame: React.FC<PhoneFrameProps> = ({ children }) => {
  return (
    <div className="relative mx-auto my-auto max-w-[400px] w-full flex flex-col items-center">
      {/* iOS iPhone 16 Pro Titanium Chassis */}
      <div className="relative w-full h-[780px] max-h-[calc(100vh-100px)] bg-[#0C120E] rounded-[52px] p-2.5 shadow-2xl border-[5px] border-[#25382D] ring-1 ring-white/10 flex flex-col overflow-hidden backdrop-blur-2xl">
        
        {/* Hardware Buttons */}
        <div className="absolute -left-[8px] top-28 w-[3px] h-9 bg-slate-700 rounded-l-md" />
        <div className="absolute -left-[8px] top-42 w-[3px] h-12 bg-slate-700 rounded-l-md" />
        <div className="absolute -right-[8px] top-34 w-[3px] h-14 bg-slate-700 rounded-r-md" />

        {/* iOS Dynamic Island & Status Bar */}
        <div className="w-full bg-[#0C120E] h-7 flex items-center justify-between px-6 shrink-0 pt-1 text-white text-[10px] font-sans font-semibold z-40 rounded-t-[42px]">
          <span className="font-mono text-[11px]">9:41</span>

          {/* iOS Dynamic Island Pill */}
          <div className="w-24 h-4 bg-black rounded-full flex items-center justify-between px-2 border border-white/10 shadow-inner">
            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            <div className="w-2 h-2 rounded-full bg-[#1C2C22]" />
          </div>

          <div className="flex items-center gap-1.5 text-white/90">
            <Signal className="w-3 h-3" />
            <Wifi className="w-3 h-3" />
            <Battery className="w-3.5 h-3.5 fill-current" />
          </div>
        </div>

        {/* iOS Clean Screen Container */}
        <div className="flex-1 bg-[#F5F4F0] rounded-[42px] overflow-y-auto flex flex-col relative shadow-inner">
          {children}
        </div>

        {/* iOS Home Indicator Bar */}
        <div className="h-4 bg-[#0C120E] shrink-0 flex items-center justify-center rounded-b-[42px] z-40">
          <div className="w-32 h-1 bg-white/40 rounded-full" />
        </div>
      </div>
    </div>
  );
};
