'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Radio, Radar, Star, MapPin, Phone, UserCheck, ArrowRight } from 'lucide-react';

export const Step4SmartDispatchScreen: React.FC = () => {
  const { activeJob, acceptJobByTech, setCurrentStep, technicians } = usePrototype();

  const tech = activeJob?.assignedTechnician || technicians[0];
  const isAssigned = activeJob?.status === 'ASSIGNED' || activeJob?.status === 'ON_THE_WAY';

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Radio className="w-3.5 h-3.5 animate-pulse text-amber-400" />
            <span>STEP 04 — SMART DISPATCH</span>
          </div>
          <h2 className="text-sm font-black tracking-tight">Proximity Technician Match</h2>
        </div>

        <span className="text-[10px] font-mono font-bold bg-emerald-800 text-emerald-100 px-2 py-0.5 rounded-full border border-emerald-400">
          RADIUS &lt; 2 KM
        </span>
      </div>

      {/* Radar Animation Box */}
      <div className="relative rounded-2xl overflow-hidden border-2 border-[#1B4332] bg-[#1C2520] h-40 shadow-md flex items-center justify-center p-4">
        <div className="absolute inset-0 bg-[radial-gradient(#2D5A43_1px,transparent_1px)] [background-size:16px_16px] opacity-40" />

        <div className="relative z-10 text-center space-y-2">
          <div className="w-14 h-14 rounded-full bg-[#1B4332] text-amber-300 mx-auto flex items-center justify-center shadow-xl border border-amber-400 animate-radar">
            <Radar className="w-7 h-7 animate-spin" style={{ animationDuration: '5s' }} />
          </div>
          <div className="bg-black/70 backdrop-blur px-3 py-1 rounded-xl text-[10px] font-mono text-emerald-300 font-bold border border-emerald-500/30">
            Dispatch Engine: Haversine Matcher Active
          </div>
        </div>
      </div>

      {/* Matched Technician Profile Card */}
      <div className="bg-[#FFF8F1] p-4 rounded-2xl border border-[#1B4332]/15 space-y-3 shadow-sm">
        <div className="flex items-start gap-3">
          <img
            src={tech.avatar}
            alt={tech.name}
            className="w-14 h-14 rounded-xl object-cover border-2 border-[#1B4332] shrink-0"
          />
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between">
              <h3 className="text-xs font-bold text-[#1C2520] truncate">{tech.name}</h3>
              <span className="text-[10px] font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded-full flex items-center gap-0.5">
                <Star className="w-3 h-3 fill-amber-500 text-amber-500" />
                <span>{tech.rating}</span>
              </span>
            </div>
            <p className="text-[11px] font-semibold text-[#7B4B2A]">{tech.speciality}</p>

            <div className="flex items-center gap-2 text-[10px] text-[#5D6D64] mt-1">
              <MapPin className="w-3 h-3 text-[#1B4332]" />
              <span>{tech.distanceKm} km away • ETA 15 mins</span>
            </div>
          </div>
        </div>

        <div className="p-2.5 rounded-xl bg-white border border-[#1B4332]/10 text-[11px] text-[#1C2520] font-medium flex items-center justify-between">
          <span>Vehicle: {tech.vehicle}</span>
          <span className="font-bold text-emerald-700 bg-emerald-100 px-2 py-0.5 rounded">
            VERIFIED TECH
          </span>
        </div>
      </div>

      {/* Actions */}
      {!isAssigned ? (
        <button
          onClick={() => acceptJobByTech(tech.id)}
          className="w-full py-3 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
        >
          <UserCheck className="w-4 h-4 text-amber-300" />
          <span>REQUEST TECHNICIAN DISPATCH</span>
        </button>
      ) : (
        <button
          onClick={() => setCurrentStep(5)}
          className="w-full py-3 rounded-xl bg-emerald-800 hover:bg-emerald-900 text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
        >
          <span>TECHNICIAN ASSIGNED! GO TO TRACKING</span>
          <ArrowRight className="w-4 h-4" />
        </button>
      )}
    </div>
  );
};
