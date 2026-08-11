'use client';

import React, { useState } from 'react';
import { PrototypeProvider, usePrototype } from '../context/PrototypeContext';
import { RoleSwitcherHeader } from '../components/layout/RoleSwitcherHeader';
import { LeftStepsPanel } from '../components/layout/LeftStepsPanel';
import { PhoneFrame } from '../components/layout/PhoneFrame';
import { RightContextPanel } from '../components/layout/RightContextPanel';
import { RealtimeNotification } from '../components/common/RealtimeNotification';

import { LandingPortalScreen } from '../components/steps/LandingPortalScreen';
import { Step1IssueUploadScreen } from '../components/steps/Step1IssueUploadScreen';
import { Step2AIDiagnosisScreen } from '../components/steps/Step2AIDiagnosisScreen';
import { Step3CostEstimationScreen } from '../components/steps/Step3CostEstimationScreen';
import { Step4SmartDispatchScreen } from '../components/steps/Step4SmartDispatchScreen';
import { Step5RepairProgressScreen } from '../components/steps/Step5RepairProgressScreen';
import { Step6CompletionFeedbackScreen } from '../components/steps/Step6CompletionFeedbackScreen';

import { TechDashboard } from '../components/technician/TechDashboard';
import { AdminDashboardView } from '../components/admin/AdminDashboardView';

function MainPresentationShell() {
  const { currentStep, activeRole } = usePrototype();

  const renderActivePhoneScreen = () => {
    switch (currentStep) {
      case 0:
        return <LandingPortalScreen />;
      case 1:
        return <Step1IssueUploadScreen />;
      case 2:
        return <Step2AIDiagnosisScreen />;
      case 3:
        return <Step3CostEstimationScreen />;
      case 4:
        return <Step4SmartDispatchScreen />;
      case 5:
        return <Step5RepairProgressScreen />;
      case 6:
        return <Step6CompletionFeedbackScreen />;
      default:
        return <LandingPortalScreen />;
    }
  };

  if (activeRole === 'admin') {
    return (
      <div className="flex flex-col h-screen w-screen bg-[#0F172A] overflow-hidden">
        <RoleSwitcherHeader />
        <RealtimeNotification />
        <div className="flex-1 overflow-hidden">
          <AdminDashboardView />
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-screen w-screen bg-[#F8F6F0] overflow-hidden">
      {/* Top Navigation Header */}
      <RoleSwitcherHeader />

      {/* Realtime Toast Notifications */}
      <RealtimeNotification />

      {/* 3-Column Pitch Deck Presentation Layout */}
      <div className="flex-1 flex overflow-hidden">
        {/* LEFT: 6 Core Steps & Role Controller */}
        <LeftStepsPanel />

        {/* CENTER: Hero Smartphone Device Frame */}
        <main className="flex-1 overflow-y-auto p-4 bg-[#F8F6F0] flex flex-col justify-center items-center">
          {activeRole === 'dual' ? (
            <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 w-full max-w-5xl items-center justify-center">
              <div className="flex flex-col items-center">
                <span className="text-xs font-black uppercase text-[#1B4332] tracking-wider mb-2">
                  Customer App (User Window)
                </span>
                <PhoneFrame>{renderActivePhoneScreen()}</PhoneFrame>
              </div>

              <div className="flex flex-col items-center">
                <span className="text-xs font-black uppercase text-[#7B4B2A] tracking-wider mb-2">
                  Technician Portal (Tech Window)
                </span>
                <PhoneFrame>
                  <TechDashboard />
                </PhoneFrame>
              </div>
            </div>
          ) : activeRole === 'technician' ? (
            <PhoneFrame>
              <TechDashboard />
            </PhoneFrame>
          ) : (
            <PhoneFrame>{renderActivePhoneScreen()}</PhoneFrame>
          )}
        </main>

        {/* RIGHT: Smart Contextual Panel */}
        <RightContextPanel />
      </div>
    </div>
  );
}


export default function Page() {
  return (
    <PrototypeProvider>
      <MainPresentationShell />
    </PrototypeProvider>
  );
}
