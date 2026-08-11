'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { User, Wrench, ArrowRight, ShieldCheck, Sparkles } from 'lucide-react';

export const LandingPortalScreen: React.FC = () => {
  const { setActiveRole, setCurrentStep } = usePrototype();

  const handleUserLogin = () => {
    setActiveRole('user');
    setCurrentStep(1);
  };

  const handleTechLogin = () => {
    setActiveRole('technician');
  };

  return (
    <div className="flex-1 flex flex-col justify-between p-6 bg-gradient-to-b from-[#FBF8F3] via-[#F5F2EC] to-[#EAE6DF] text-center select-none min-h-full">
      {/* Top Brand Logo Section */}
      <div className="pt-6 space-y-3">
        <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#0F382B] to-[#1C5340] text-amber-300 mx-auto flex items-center justify-center text-3xl shadow-xl border border-emerald-700/30">
          ⬡
        </div>

        <div>
          <h1 className="text-2xl font-black tracking-tight text-[#0F382B]">AETHERION</h1>
          <p className="text-xs font-semibold text-[#5D6D64] mt-1 max-w-[260px] mx-auto leading-relaxed">
            AI-Powered On-Demand Appliance Repair & Service Dispatch
          </p>
        </div>
      </div>

      {/* Center Role Buttons */}
      <div className="space-y-3.5 my-auto py-6">
        {/* Customer Login Card */}
        <div
          onClick={handleUserLogin}
          className="bg-white p-4 rounded-2xl border-2 border-[#0F382B]/10 hover:border-[#0F382B] flex items-center gap-3.5 cursor-pointer text-left shadow-sm hover:shadow-md transition-all group btn-tactile"
        >
          <div className="w-12 h-12 rounded-xl bg-[#F4EAE2] text-[#7B4B2A] flex items-center justify-center text-xl shrink-0 group-hover:scale-105 transition-transform">
            👤
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-extrabold text-sm text-[#0F382B] group-hover:text-[#7B4B2A] transition-colors">
              Customer Login
            </h3>
            <p className="text-[11px] text-[#5D6D64] leading-snug">
              AI diagnosis, upfront cost & live technician tracking
            </p>
          </div>
          <ArrowRight className="w-4 h-4 text-[#0F382B] group-hover:translate-x-1 transition-transform shrink-0" />
        </div>

        {/* Technician Login Card */}
        <div
          onClick={handleTechLogin}
          className="bg-white p-4 rounded-2xl border-2 border-[#0F382B]/10 hover:border-[#0F382B] flex items-center gap-3.5 cursor-pointer text-left shadow-sm hover:shadow-md transition-all group btn-tactile"
        >
          <div className="w-12 h-12 rounded-xl bg-[#E8F2EC] text-[#0F382B] flex items-center justify-center text-xl shrink-0 group-hover:scale-105 transition-transform">
            👨‍🔧
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-extrabold text-sm text-[#0F382B] transition-colors">
              Technician Login
            </h3>
            <p className="text-[11px] text-[#5D6D64] leading-snug">
              Job dispatch, voice assistant & digital proof upload
            </p>
          </div>
          <ArrowRight className="w-4 h-4 text-[#0F382B] group-hover:translate-x-1 transition-transform shrink-0" />
        </div>
      </div>

      {/* Footer Badge */}
      <div className="pb-4 flex items-center justify-center gap-2 text-[11px] font-bold text-[#5D6D64]">
        <span className="w-2 h-2 rounded-full bg-emerald-600 animate-ping" />
        <span>Ready for Interactive Prototype Testing</span>
      </div>
    </div>
  );
};
