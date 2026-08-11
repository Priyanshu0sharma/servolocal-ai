'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Calculator, CheckCircle2, ArrowRight, ShieldCheck, FileText } from 'lucide-react';

export const Step3CostEstimationScreen: React.FC = () => {
  const { activeJob, setCurrentStep } = usePrototype();

  const parts = activeJob?.aiDiagnosis.recommendedParts || [
    { name: 'OEM Sensor & Safety Filter Assembly', estimatedCost: 250, inStock: true },
    { name: 'Terminal Connector & Insulated Wire Kit', estimatedCost: 150, inStock: true },
  ];

  const subtotal = parts.reduce((sum, p) => sum + p.estimatedCost, 0) + 249; // ₹249 Labor
  const tax = Math.round(subtotal * 0.18);
  const total = subtotal + tax;

  return (
    <div className="p-3.5 space-y-3 animate-fade-in pb-6 bg-[#F5F4F0]">
      {/* Screen Title */}
      <div className="bg-[#0F382B] text-white p-3 rounded-2xl shadow-sm border border-emerald-800/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[9px] font-mono text-emerald-300 font-bold uppercase tracking-wider">
            <Calculator className="w-3.5 h-3.5" />
            <span>STEP 03 — TRANSPARENT PRICING</span>
          </div>
          <h2 className="text-xs font-black tracking-tight">Affordable Cost & Parts Estimation</h2>
        </div>

        <span className="text-[9px] font-mono font-bold bg-[#7B4B2A] text-white px-2 py-0.5 rounded-full border border-amber-400">
          GUARANTEED BEST PRICE
        </span>
      </div>

      {/* Recommended Parts List */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-200/80 space-y-2.5 shadow-sm">
        <h3 className="text-[10px] font-extrabold text-[#7B4B2A] uppercase tracking-wider">
          AI Verified Parts & Service Charges
        </h3>

        <div className="space-y-1.5">
          {parts.map((p, idx) => (
            <div
              key={idx}
              className="p-2.5 rounded-xl bg-[#F8F7F3] border border-slate-200 flex items-center justify-between text-xs"
            >
              <div>
                <p className="font-bold text-[#1C2520]">{p.name}</p>
                <span className="text-[9px] font-bold text-emerald-700 bg-emerald-100 px-1.5 py-0.2 rounded">
                  IN STOCK
                </span>
              </div>
              <span className="font-mono font-bold text-[#0F382B]">
                ₹{p.estimatedCost.toLocaleString('en-IN')}
              </span>
            </div>
          ))}
        </div>

        {/* Labor & Total Summary */}
        <div className="pt-2 border-t border-slate-100 space-y-1 text-xs text-[#1C2520]">
          <div className="flex justify-between">
            <span className="text-[#5D6D64]">Certified Technician Labor Fee:</span>
            <span className="font-mono font-bold">₹249</span>
          </div>
          <div className="flex justify-between">
            <span className="text-[#5D6D64]">GST (18% Statutory Tax):</span>
            <span className="font-mono font-bold">₹{tax.toLocaleString('en-IN')}</span>
          </div>
          <div className="flex justify-between font-black text-sm text-[#0F382B] pt-2 border-t border-slate-200">
            <span>Final Estimated Total:</span>
            <span className="font-mono text-[#7B4B2A]">₹{total.toLocaleString('en-IN')}</span>
          </div>
        </div>
      </div>

      {/* Transparent Pricing Disclaimer */}
      <div className="p-2.5 bg-emerald-50 rounded-xl border border-emerald-200 text-[10px] text-emerald-900 flex items-center gap-2">
        <CheckCircle2 className="w-4 h-4 text-emerald-700 shrink-0" />
        <span>No hidden charges! 100% upfront transparent billing guaranteed.</span>
      </div>

      {/* CTA Button */}
      <button
        onClick={() => setCurrentStep(4)}
        className="w-full py-2.5 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-black flex items-center justify-center gap-2 shadow transition-all btn-tactile"
      >
        <span>CONTINUE TO DISPATCH</span>
        <ArrowRight className="w-4 h-4 text-amber-200" />
      </button>
    </div>
  );
};
