'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { PITCH_DECK_STEPS, TECH_WORKFLOW_STEPS } from '../../data/mockData';
import { CoreStepId } from '../../types/prototype';
import {
  UploadCloud,
  Brain,
  Calculator,
  Radio,
  Wrench,
  CheckCircle2,
  User,
  Bell,
  Navigation,
  FileText,
  Camera,
  IndianRupee
} from 'lucide-react';

const ICON_MAP: Record<string, React.ElementType> = {
  UploadCloud,
  Brain,
  Calculator,
  Radio,
  Wrench,
  CheckCircle2,
  Bell,
  Navigation,
  FileText,
  Camera,
  IndianRupee
};

export const LeftStepsPanel: React.FC = () => {
  const { currentStep, setCurrentStep, activeRole, setActiveRole } = usePrototype();

  const stepsList = activeRole === 'technician' ? TECH_WORKFLOW_STEPS : PITCH_DECK_STEPS;

  return (
    <aside className="hidden lg:flex w-72 bg-[#F5EEE6] border-r border-[#1B4332]/15 flex-col shrink-0 overflow-hidden">
      {/* Workflow Header */}
      <div className="p-4 border-b border-[#1B4332]/15 bg-[#FFF8F1]">
        <div className="flex items-center justify-between">
          <span className="text-[10px] font-extrabold uppercase tracking-widest text-[#7B4B2A] bg-[#F4EAE2] px-2 py-0.5 rounded-full">
            {activeRole === 'technician' ? 'TECHNICIAN PROTOCOL' : 'SERVOLOCAL AI WORKFLOW'}
          </span>
          <span className="text-xs font-mono font-bold text-[#1B4332]">
            {currentStep || 1}/06
          </span>
        </div>
        <h2 className="text-sm font-extrabold text-[#1B4332] mt-1 uppercase tracking-wide">
          {activeRole === 'technician' ? 'Technician Dispatch Steps' : '6 Core Workflow Steps'}
        </h2>
      </div>

      {/* Role Selection Switcher Cards */}
      <div className="p-3 bg-[#EBF2EE] border-b border-[#1B4332]/15 space-y-2">
        <label className="text-[10px] font-bold text-[#1B4332] uppercase tracking-wider block">
          Role Controller
        </label>
        <div className="grid grid-cols-2 gap-2">
          <button
            onClick={() => {
              setActiveRole('user');
              setCurrentStep(1);
            }}
            className={`py-2 px-3 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all btn-tactile ${
              activeRole === 'user'
                ? 'bg-[#1B4332] text-white shadow-md ring-1 ring-amber-400'
                : 'bg-white text-[#5D6D64] hover:bg-[#F5EEE6]'
            }`}
          >
            <User className="w-3.5 h-3.5" />
            <span>USER</span>
          </button>

          <button
            onClick={() => {
              setActiveRole('technician');
            }}
            className={`py-2 px-3 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all btn-tactile ${
              activeRole === 'technician'
                ? 'bg-[#7B4B2A] text-white shadow-md ring-1 ring-amber-400'
                : 'bg-white text-[#5D6D64] hover:bg-[#F5EEE6]'
            }`}
          >
            <Wrench className="w-3.5 h-3.5" />
            <span>TECH</span>
          </button>
        </div>
      </div>

      {/* 6 Core Workflow Steps (Updates dynamically for Tech vs User) */}
      <div className="flex-1 overflow-y-auto p-3 space-y-2">
        {stepsList.map((step) => {
          const IconComp = ICON_MAP[step.icon] || UploadCloud;
          const isActive = currentStep === step.id;
          const isPassed = currentStep > step.id;

          return (
            <button
              key={step.id}
              onClick={() => setCurrentStep(step.id as CoreStepId)}
              className={`w-full text-left p-3 rounded-2xl transition-all duration-200 flex items-center gap-3 border relative btn-tactile ${
                isActive
                  ? 'bg-[#1B4332] text-white border-[#1B4332] shadow-lg ring-2 ring-amber-500/50 scale-[1.02]'
                  : isPassed
                  ? 'bg-[#FFF8F1] text-[#1B4332] border-[#1B4332]/20 hover:bg-[#EBF2EE]'
                  : 'bg-white/60 text-[#1C2520] border-transparent hover:bg-white'
              }`}
            >
              {/* Step Number Badge */}
              <div
                className={`w-8 h-8 rounded-xl flex items-center justify-center font-mono text-xs font-bold shrink-0 transition-transform ${
                  isActive
                    ? 'bg-[#7B4B2A] text-amber-200 shadow-inner'
                    : isPassed
                    ? 'bg-[#2D5A43] text-white'
                    : 'bg-[#F5EEE6] text-[#4C6B5D]'
                }`}
              >
                {step.number}
              </div>

              {/* Step Info */}
              <div className="flex-1 min-w-0">
                <span
                  className={`text-xs font-bold block truncate ${
                    isActive ? 'text-white' : 'text-[#1C2520]'
                  }`}
                >
                  {step.title}
                </span>
                <span
                  className={`text-[10px] block truncate ${
                    isActive ? 'text-emerald-200' : 'text-[#5D6D64]'
                  }`}
                >
                  {step.shortTitle}
                </span>
              </div>

              <IconComp
                className={`w-4 h-4 shrink-0 ${
                  isActive ? 'text-amber-300' : isPassed ? 'text-[#2D5A43]' : 'text-[#4C6B5D]'
                }`}
              />
            </button>
          );
        })}
      </div>
    </aside>
  );
};
