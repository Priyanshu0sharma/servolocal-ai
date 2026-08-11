'use client';

import React, { useState, useEffect } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Brain, Sparkles, AlertTriangle, ArrowRight, ShieldCheck, Cpu } from 'lucide-react';

export const Step2AIDiagnosisScreen: React.FC = () => {
  const { activeJob, setCurrentStep } = usePrototype();
  const [analyzing, setAnalyzing] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => setAnalyzing(false), 1200);
    return () => clearTimeout(timer);
  }, []);

  const diagnosis = activeJob?.aiDiagnosis || {
    detectedIssue: 'Possible AC Compressor High-Pressure Cutoff & Thermal Coil Overheat',
    category: 'Commercial HVAC & AC',
    severity: 'Critical Emergency' as const,
    confidence: 96.4,
  };

  const sampleImage =
    activeJob?.media[0]?.url ||
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&auto=format&fit=crop&q=80';

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Brain className="w-3.5 h-3.5" />
            <span>STEP 02 — MULTIMODAL AI</span>
          </div>
          <h2 className="text-sm font-black tracking-tight">AI Preliminary Diagnosis</h2>
        </div>

        <span className="text-[10px] font-mono font-bold bg-amber-400 text-slate-950 px-2 py-0.5 rounded-full">
          {diagnosis.confidence}% CONF
        </span>
      </div>

      {/* AI Vision Scanning Screen */}
      <div className="relative rounded-2xl overflow-hidden border-2 border-[#1B4332] bg-slate-950 aspect-video shadow-md flex items-center justify-center">
        <img src={sampleImage} alt="Faulty Machine" className="w-full h-full object-cover opacity-90" />

        {/* Animated Vision Bounding Box Overlay */}
        <div className="absolute inset-4 border-2 border-dashed border-amber-400 rounded-xl pointer-events-none flex flex-col justify-between p-2">
          <div className="flex justify-between items-start">
            <span className="bg-rose-600 text-white font-mono text-[9px] font-bold px-1.5 py-0.5 rounded shadow">
              [ANOMALY_DETECTED]
            </span>
            <span className="bg-black/70 text-amber-300 font-mono text-[9px] px-1.5 py-0.5 rounded">
              BOX: (140, 92, 320, 240)
            </span>
          </div>

          {analyzing && (
            <div className="w-full h-1 bg-gradient-to-r from-amber-400 via-rose-500 to-amber-400 animate-shimmer rounded-full" />
          )}

          <div className="text-[9px] font-mono text-emerald-300 bg-black/70 px-1.5 py-0.5 rounded w-fit">
            TensorFlow CNN v2.4 • Model Active
          </div>
        </div>
      </div>

      {/* Diagnosis Report Card */}
      <div className="bg-[#FFF8F1] p-4 rounded-2xl border border-[#1B4332]/15 space-y-3 shadow-sm">
        <div className="flex items-center justify-between">
          <span className="text-[10px] font-extrabold uppercase tracking-wider text-[#7B4B2A] bg-[#F4EAE2] px-2 py-0.5 rounded">
            AI DIAGNOSIS REPORT
          </span>
          <span className="text-[10px] font-bold text-rose-800 bg-rose-100 px-2 py-0.5 rounded border border-rose-300">
            {diagnosis.severity}
          </span>
        </div>

        <div>
          <h3 className="text-xs font-black text-[#1B4332] leading-snug">
            {diagnosis.detectedIssue}
          </h3>
          <p className="text-[11px] text-[#5D6D64] mt-1 leading-relaxed">
            Multi-modal vision analysis detected severe thermal discoloration & high-pressure switch lockout on condenser circuit.
          </p>
        </div>

        <div className="flex items-center gap-2 pt-2 border-t border-[#1B4332]/10 text-[10px] font-bold text-[#1B4332]">
          <ShieldCheck className="w-4 h-4 text-emerald-600" />
          <span>Verified against 12,000+ OEM industrial failure datasets.</span>
        </div>
      </div>

      {/* CTA Button */}
      <button
        onClick={() => setCurrentStep(3)}
        className="w-full py-3 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile"
      >
        <span>CONTINUE TO COST ESTIMATION</span>
        <ArrowRight className="w-4 h-4 text-amber-300" />
      </button>
    </div>
  );
};
