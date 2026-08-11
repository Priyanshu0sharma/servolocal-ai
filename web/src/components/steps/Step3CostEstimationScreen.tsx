'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Calculator, CheckCircle2, ArrowRight, ShieldCheck, FileText } from 'lucide-react';

export const Step3CostEstimationScreen: React.FC = () => {
  const { activeJob, setCurrentStep } = usePrototype();

  const parts = activeJob?.aiDiagnosis.recommendedParts || [
    { name: 'OEM High-Pressure Cutoff Switch', estimatedCost: 1850, inStock: true },
    { name: 'R-410A Refrigerant Charge (1.2 kg)', estimatedCost: 1200, inStock: true },
    { name: 'Thermal Overload Relay Filter', estimatedCost: 450, inStock: true },
  ];

  const subtotal = parts.reduce((sum, p) => sum + p.estimatedCost, 0) + 999;
  const tax = Math.round(subtotal * 0.18);
  const total = subtotal + tax;

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Calculator className="w-3.5 h-3.5" />
            <span>STEP 03 — PREDICTIVE PRICING</span>
          </div>
          <h2 className="text-sm font-black tracking-tight">Cost & Parts Estimation</h2>
        </div>

        <span className="text-[10px] font-mono font-bold bg-[#7B4B2A] text-white px-2 py-0.5 rounded-full border border-amber-400">
          PRE-REPAIR ESTIMATE
        </span>
      </div>

      {/* Recommended Parts List */}
      <div className="bg-[#FFF8F1] p-4 rounded-2xl border border-[#1B4332]/15 space-y-3 shadow-sm">
        <h3 className="text-[11px] font-extrabold text-[#7B4B2A] uppercase tracking-wider">
          AI Predicted OEM Parts Required
        </h3>

        <div className="space-y-1.5">
          {parts.map((p, idx) => (
            <div
              key={idx}
              className="p-2.5 rounded-xl bg-white border border-[#1B4332]/10 flex items-center justify-between text-xs"
            >
              <div>
                <p className="font-bold text-[#1C2520]">{p.name}</p>
                <span className="text-[9px] font-bold text-emerald-700 bg-emerald-100 px-1.5 py-0.2 rounded">
                  IN STOCK (Hub #4)
                </span>
              </div>
              <span className="font-mono font-bold text-[#1B4332]">
                ₹{p.estimatedCost.toLocaleString('en-IN')}
              </span>
            </div>
          ))}
        </div>

        {/* Labor & Total Summary */}
        <div className="pt-2 border-t border-[#1B4332]/10 space-y-1 text-xs text-[#1C2520]">
          <div className="flex justify-between">
            <span className="text-[#5D6D64]">Certified Labor (1.5 hrs):</span>
            <span className="font-mono">₹999</span>
          </div>
          <div className="flex justify-between">
            <span className="text-[#5D6D64]">GST (18% Statutory Tax):</span>
            <span className="font-mono">₹{tax.toLocaleString('en-IN')}</span>
          </div>
          <div className="flex justify-between font-black text-sm text-[#1B4332] pt-2 border-t border-[#1B4332]/15">
            <span>Estimated Total:</span>
            <span className="font-mono text-[#7B4B2A]">₹{total.toLocaleString('en-IN')}</span>
          </div>
        </div>
      </div>

      {/* Transparent Pricing Disclaimer */}
      <div className="p-3 bg-[#EBF2EE] rounded-xl border border-[#1B4332]/20 text-[11px] text-[#1C2520] flex items-center gap-2">
        <CheckCircle2 className="w-4 h-4 text-emerald-700 shrink-0" />
        <span>No hidden charges. Estimate verified by ServoLocal AI before technician dispatch.</span>
      </div>

      {/* CTA Button */}
      <button
        onClick={() => setCurrentStep(4)}
        className="w-full py-3 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile border border-amber-500/30"
      >
        <span>CONTINUE TO SMART DISPATCH</span>
        <ArrowRight className="w-4 h-4 text-amber-200" />
      </button>
    </div>
  );
};
