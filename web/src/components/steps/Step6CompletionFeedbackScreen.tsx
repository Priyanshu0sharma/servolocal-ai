'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Award, Star, CheckCircle2, ShieldCheck, Download, RefreshCw, Send } from 'lucide-react';

export const Step6CompletionFeedbackScreen: React.FC = () => {
  const { activeJob, submitRating, resetPrototype, setCurrentStep } = usePrototype();

  const [stars, setStars] = useState(5);
  const [feedback, setFeedback] = useState(
    'Vikram arrived in 12 mins, identified high-pressure cutoff anomaly, replaced pressure switch assembly & restored full refrigeration performance.'
  );
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    submitRating(stars, feedback);
    setSubmitted(true);
  };

  const finalCost = activeJob?.aiDiagnosis.estimatedTotal || 4499;

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-3.5 rounded-2xl shadow-md border border-[#7B4B2A]/40 flex items-center justify-between">
        <div>
          <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
            <Award className="w-3.5 h-3.5" />
            <span>STEP 06 — COMPLETION & PROOF</span>
          </div>
          <h2 className="text-sm font-black tracking-tight">Digital Repair Proof</h2>
        </div>

        <span className="text-[10px] font-mono font-bold bg-amber-400 text-slate-950 px-2 py-0.5 rounded-full uppercase">
          JOB COMPLETED
        </span>
      </div>

      {/* Before & After Proof Photos */}
      <div className="bg-[#FFF8F1] p-3.5 rounded-2xl border border-[#1B4332]/15 space-y-2.5 shadow-sm">
        <h3 className="text-[11px] font-extrabold text-[#7B4B2A] uppercase tracking-wider">
          Visual Repair Proof Certificate
        </h3>

        <div className="grid grid-cols-2 gap-2">
          <div className="space-y-1">
            <span className="text-[9px] font-bold text-[#5D6D64] block">BEFORE (Issue)</span>
            <div className="aspect-video rounded-xl overflow-hidden border border-[#1B4332]/20 bg-slate-900">
              <img
                src={
                  activeJob?.media[0]?.url ||
                  'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&auto=format&fit=crop&q=80'
                }
                alt="Before repair"
                className="w-full h-full object-cover"
              />
            </div>
          </div>

          <div className="space-y-1">
            <span className="text-[9px] font-bold text-emerald-800 block">AFTER (Restored)</span>
            <div className="aspect-video rounded-xl overflow-hidden border border-emerald-500/40 bg-slate-900">
              <img
                src="https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=80"
                alt="After repair"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>

        {/* Final Amount */}
        <div className="p-2.5 rounded-xl bg-white border border-[#1B4332]/10 flex items-center justify-between text-xs font-bold">
          <span>Final Total Paid:</span>
          <span className="font-mono text-[#7B4B2A] text-sm">
            ₹{finalCost.toLocaleString('en-IN')}
          </span>
        </div>
      </div>

      {/* Rating & Feedback Form */}
      <form onSubmit={handleSubmit} className="bg-white p-3.5 rounded-2xl border border-[#1B4332]/15 space-y-2.5 shadow-sm">
        <label className="text-[11px] font-bold text-[#1B4332] uppercase tracking-wider block text-center">
          Rate Technician Performance
        </label>

        {/* Star Control */}
        <div className="flex items-center justify-center gap-1.5">
          {[1, 2, 3, 4, 5].map((starNum) => (
            <button
              key={starNum}
              type="button"
              onClick={() => setStars(starNum)}
              className="p-1 hover:scale-110 btn-tactile"
            >
              <Star
                className={`w-6 h-6 ${
                  stars >= starNum ? 'fill-amber-400 text-amber-500' : 'text-gray-300'
                }`}
              />
            </button>
          ))}
        </div>

        <textarea
          rows={2}
          value={feedback}
          onChange={(e) => setFeedback(e.target.value)}
          className="w-full px-3 py-2 rounded-xl border border-[#1B4332]/20 text-xs bg-[#FFF8F1] text-[#1C2520]"
        />

        <button
          type="submit"
          className="w-full py-2.5 rounded-xl bg-[#1B4332] hover:bg-[#143527] text-white text-xs font-bold flex items-center justify-center gap-2 shadow btn-tactile"
        >
          <Send className="w-3.5 h-3.5 text-amber-300" />
          <span>{submitted ? 'Rating Saved!' : 'Confirm & Submit Feedback'}</span>
        </button>
      </form>

      {/* Reset Session CTA */}
      <button
        type="button"
        onClick={resetPrototype}
        className="w-full py-2.5 rounded-xl bg-[#F5EEE6] hover:bg-[#EBF2EE] text-[#7B4B2A] text-xs font-bold flex items-center justify-center gap-2 border border-[#7B4B2A]/20 transition-all btn-tactile"
      >
        <RefreshCw className="w-3.5 h-3.5" />
        <span>Reset Prototype Session</span>
      </button>
    </div>
  );
};
