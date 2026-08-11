'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Radio, Radar, Star, MapPin, Phone, UserCheck, ArrowRight, CheckCircle2, ShieldCheck } from 'lucide-react';
import { MOCK_TECHNICIANS } from '../../data/mockData';

export const Step4SmartDispatchScreen: React.FC = () => {
  const { activeJob, acceptJobByTech, setCurrentStep } = usePrototype();
  const [selectedTechId, setSelectedTechId] = useState<string>('tech-101');

  const isAssigned = activeJob?.status === 'ASSIGNED' || activeJob?.status === 'ON_THE_WAY' || activeJob?.status === 'ARRIVED';

  return (
    <div className="p-3.5 space-y-3 animate-fade-in pb-6 bg-[#F8F6F0]">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[9px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Radio className="w-3.5 h-3.5 animate-pulse text-amber-400" />
            <span>STEP 04 — SMART DISPATCH</span>
          </div>
          <h2 className="text-xs font-black tracking-tight">Proximity Technician Match (5 Results)</h2>
        </div>

        <span className="text-[9px] font-mono font-bold bg-emerald-800 text-emerald-100 px-2 py-0.5 rounded-full border border-emerald-400">
          RADIUS &lt; 5 KM
        </span>
      </div>

      {/* Radar Animation Box */}
      <div className="relative rounded-2xl overflow-hidden border-2 border-[#1B4332] bg-[#1C2520] h-28 shadow-md flex items-center justify-center p-3">
        <div className="absolute inset-0 bg-[radial-gradient(#2D5A43_1px,transparent_1px)] [background-size:16px_16px] opacity-40" />

        <div className="relative z-10 text-center space-y-1">
          <div className="w-10 h-10 rounded-full bg-[#1B4332] text-amber-300 mx-auto flex items-center justify-center shadow-xl border border-amber-400">
            <Radar className="w-5 h-5 animate-spin" style={{ animationDuration: '4s' }} />
          </div>
          <div className="bg-black/70 backdrop-blur px-2.5 py-0.5 rounded-xl text-[9px] font-mono text-emerald-300 font-bold border border-emerald-500/30">
            Haversine Matcher: Found 5 Verified Technicians Nearby
          </div>
        </div>
      </div>

      {/* 5 Matched Technicians List */}
      <div className="space-y-2">
        <span className="text-[10px] font-extrabold text-[#1B4332] uppercase tracking-wider block">
          Select Preferred Technician:
        </span>

        <div className="space-y-2 max-h-[300px] overflow-y-auto pr-0.5">
          {MOCK_TECHNICIANS.map((tech) => {
            const isSelected = selectedTechId === tech.id;
            return (
              <div
                key={tech.id}
                onClick={() => setSelectedTechId(tech.id)}
                className={`p-2.5 rounded-xl border transition-all cursor-pointer shadow-sm ${
                  isSelected
                    ? 'bg-white border-2 border-[#1B4332] ring-2 ring-[#1B4332]/20'
                    : 'bg-[#FFF8F1] border-[#1B4332]/15 hover:border-[#1B4332]/40'
                }`}
              >
                <div className="flex items-start gap-2.5">
                  <img
                    src={tech.avatar}
                    alt={tech.name}
                    className="w-11 h-11 rounded-xl object-cover border-2 border-[#1B4332] shrink-0"
                  />

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <h4 className="text-xs font-black text-[#1C2520] truncate">{tech.name}</h4>
                      <span className="text-[9px] font-bold text-amber-900 bg-amber-100 px-1.5 py-0.5 rounded flex items-center gap-0.5 border border-amber-300">
                        <Star className="w-2.5 h-2.5 fill-amber-500 text-amber-500" />
                        <span>{tech.rating}</span>
                      </span>
                    </div>

                    <p className="text-[10px] font-semibold text-[#7B4B2A] truncate">{tech.speciality}</p>

                    <div className="flex items-center justify-between mt-1 text-[9px] text-[#5D6D64]">
                      <span className="flex items-center gap-0.5 font-bold text-[#1B4332]">
                        <MapPin className="w-3 h-3 text-[#1B4332]" />
                        {tech.distanceKm} km away
                      </span>
                      <span className="font-bold text-emerald-800 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">
                        {tech.completedJobs} Jobs Done
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Dispatch Action Button */}
      {!isAssigned ? (
        <button
          onClick={() => acceptJobByTech(selectedTechId)}
          className="w-full py-2.5 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
        >
          <UserCheck className="w-4 h-4 text-amber-300" />
          <span>DISPATCH SELECTED TECHNICIAN</span>
        </button>
      ) : (
        <button
          onClick={() => setCurrentStep(5)}
          className="w-full py-2.5 rounded-xl bg-emerald-800 hover:bg-emerald-900 text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
        >
          <CheckCircle2 className="w-4 h-4 text-amber-300" />
          <span>TECHNICIAN DISPATCHED! VIEW LIVE TRACKING</span>
        </button>
      )}
    </div>
  );
};
