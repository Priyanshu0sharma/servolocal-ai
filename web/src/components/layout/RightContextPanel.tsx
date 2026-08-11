'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { PITCH_DECK_STEPS } from '../../data/mockData';
import {
  ChevronLeft,
  ChevronRight,
  Brain,
  Calculator,
  Radio,
  Wrench,
  CheckCircle2,
  Cpu,
  Zap,
  Info,
  ShieldCheck,
} from 'lucide-react';

export const RightContextPanel: React.FC = () => {
  const {
    currentStep,
    goToNextStep,
    goToPrevStep,
    activeRole,
    activeJob,
    activeTech,
    toggleTechOnline,
  } = usePrototype();

  const stepData = PITCH_DECK_STEPS.find((s) => s.id === currentStep) || PITCH_DECK_STEPS[0];

  return (
    <aside className="w-full lg:w-80 bg-[#FFF8F1] border-l border-[#1B4332]/15 flex flex-col shrink-0 overflow-y-auto">
      {/* Context Header */}
      <div className="p-4 border-b border-[#1B4332]/15 bg-[#F5EEE6]">
        <div className="flex items-center justify-between mb-1">
          <span className="text-[10px] font-extrabold uppercase tracking-widest px-2 py-0.5 rounded bg-[#7B4B2A] text-white">
            CONTEXT PANEL
          </span>
          <span className="text-xs font-mono font-semibold text-[#4C6B5D]">
            STEP {stepData.number}
          </span>
        </div>
        <h2 className="text-sm font-bold text-[#1B4332] mt-1">{stepData.title}</h2>
      </div>

      <div className="p-4 space-y-4 flex-1">
        {/* Pitch Deck Concept Box */}
        <div className="bg-white p-3.5 rounded-xl border border-[#1B4332]/12 shadow-sm space-y-1.5">
          <div className="flex items-center gap-1.5 text-xs font-bold text-[#1B4332]">
            <Info className="w-4 h-4 text-[#7B4B2A]" />
            <span>ServoLocal AI Protocol</span>
          </div>
          <p className="text-xs text-[#5D6D64] leading-relaxed">
            {stepData.description}
          </p>
        </div>

        {/* Dynamic Context per Step */}
        {currentStep === 1 && (
          <div className="bg-[#EBF2EE] p-3.5 rounded-xl border border-[#1B4332]/20 space-y-2 text-xs">
            <div className="font-bold text-[#1B4332]">Issue Upload Engine</div>
            <p className="text-[#5D6D64]">
              Supports high-resolution equipment photos & MP4 video streams up to 50 MB.
            </p>
            <div className="flex items-center justify-between text-[11px] font-mono pt-1 text-emerald-800">
              <span>GPS Geolocation:</span>
              <span className="font-bold">19.076 N, 72.877 E</span>
            </div>
          </div>
        )}

        {currentStep === 2 && (
          <div className="bg-[#EBF2EE] p-3.5 rounded-xl border border-[#1B4332]/20 space-y-2 text-xs">
            <div className="flex items-center justify-between text-[#1B4332] font-bold">
              <span>Multimodal AI Vision</span>
              <span className="text-emerald-700 font-mono">96.4% Conf</span>
            </div>
            <p className="text-[#5D6D64]">
              CNN model detects compressor coil micro-leaks & thermal overload anomalies.
            </p>
            <div className="p-2 rounded-lg bg-white border border-[#1B4332]/10 font-mono text-[10px] text-slate-800">
              Class: HVAC_COMPRESSOR_TRIP
            </div>
          </div>
        )}

        {currentStep === 3 && (
          <div className="bg-[#FFF8F1] p-3.5 rounded-xl border border-amber-600/30 space-y-2 text-xs">
            <div className="font-bold text-[#7B4B2A]">Predictive Pricing Engine</div>
            <p className="text-[#5D6D64]">
              Calculates OEM parts cost + certified labor rate + 18% GST before repair begins.
            </p>
            {activeJob?.aiDiagnosis && (
              <div className="text-xs font-mono font-bold text-[#1B4332] pt-1">
                Est Total: ₹{activeJob.aiDiagnosis.estimatedTotal.toLocaleString('en-IN')}
              </div>
            )}
          </div>
        )}

        {currentStep === 4 && (
          <div className="bg-[#EBF2EE] p-3.5 rounded-xl border border-[#1B4332]/20 space-y-2 text-xs">
            <div className="font-bold text-[#1B4332]">Smart Proximity Dispatch</div>
            <p className="text-[#5D6D64]">
              Haversine formula matches closest available technician in real-time.
            </p>
            <div className="flex items-center justify-between text-[11px] font-mono text-emerald-800">
              <span>Radius:</span>
              <span className="font-bold">&lt; 10 km</span>
            </div>
          </div>
        )}

        {currentStep === 5 && (
          <div className="bg-white p-3.5 rounded-xl border border-[#1B4332]/15 shadow-sm space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-[#1B4332]">Tech Online Toggle</span>
              <span
                className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                  activeTech.isOnline
                    ? 'bg-emerald-100 text-emerald-800'
                    : 'bg-rose-100 text-rose-800'
                }`}
              >
                {activeTech.isOnline ? 'ONLINE' : 'OFFLINE'}
              </span>
            </div>
            <div className="flex items-center justify-between pt-1">
              <span className="text-xs text-[#5D6D64]">{activeTech.name}</span>
              <button
                onClick={() => toggleTechOnline(activeTech.id)}
                className="px-3 py-1 rounded-lg text-xs font-bold bg-[#1B4332] text-white hover:bg-[#143527] btn-tactile"
              >
                Toggle
              </button>
            </div>
          </div>
        )}

        {currentStep === 6 && (
          <div className="bg-emerald-50 p-3.5 rounded-xl border border-emerald-300 space-y-2 text-xs text-emerald-900">
            <div className="font-bold flex items-center gap-1">
              <ShieldCheck className="w-4 h-4 text-emerald-700" />
              <span>Digital Proof Generated</span>
            </div>
            <p className="text-emerald-800 text-[11px]">
              90-day warranty certificate & PDF tax invoice stored in tamper-proof log.
            </p>
          </div>
        )}

        {/* Technical Architecture Hint */}
        <div className="bg-[#1C2520] text-emerald-300 p-3 rounded-xl border border-emerald-900 font-mono text-[11px] space-y-1">
          <span className="text-[10px] text-emerald-400 font-semibold uppercase block">
            Tech Implementation
          </span>
          <p className="break-all">{stepData.technicalDetails}</p>
        </div>
      </div>

      {/* Prev / Next Step Controls */}
      <div className="p-4 border-t border-[#1B4332]/15 bg-[#F5EEE6] flex items-center justify-between gap-2">
        <button
          onClick={goToPrevStep}
          disabled={currentStep === 1}
          className="flex-1 py-2 px-3 rounded-xl bg-white border border-[#1B4332]/20 text-[#1B4332] text-xs font-bold flex items-center justify-center gap-1 disabled:opacity-40 hover:bg-[#EBF2EE] btn-tactile"
        >
          <ChevronLeft className="w-4 h-4" />
          <span>Previous</span>
        </button>

        <button
          onClick={goToNextStep}
          disabled={currentStep === 6}
          className="flex-1 py-2 px-3 rounded-xl bg-[#1B4332] text-white text-xs font-bold flex items-center justify-center gap-1 disabled:opacity-40 hover:bg-[#143527] btn-tactile shadow"
        >
          <span>Next Step</span>
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </aside>
  );
};
