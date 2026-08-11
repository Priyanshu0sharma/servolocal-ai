'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  CoreStepId,
  UserRole,
  ServoLocalJob,
  TechnicianProfile,
  JobStatus,
  MediaProof,
  RealtimeSyncMessage,
  AIDiagnosisResult,
} from '../types/prototype';
import { PITCH_DECK_STEPS, MOCK_TECHNICIANS } from '../data/mockData';

interface PrototypeContextType {
  currentStep: CoreStepId;
  setCurrentStep: (step: CoreStepId) => void;
  activeRole: UserRole;
  setActiveRole: (role: UserRole) => void;
  userProfile: { name: string; email: string; phone: string; avatar: string };
  setUserProfile: React.Dispatch<React.SetStateAction<{ name: string; email: string; phone: string; avatar: string }>>;
  technicians: TechnicianProfile[];
  setTechnicians: React.Dispatch<React.SetStateAction<TechnicianProfile[]>>;
  activeJob: ServoLocalJob | null;
  setActiveJob: React.Dispatch<React.SetStateAction<ServoLocalJob | null>>;
  activeTech: TechnicianProfile;
  setActiveTech: (tech: TechnicianProfile) => void;
  notification: { title: string; message: string; type?: 'info' | 'success' | 'warning' } | null;
  setNotification: (notif: { title: string; message: string; type?: 'info' | 'success' | 'warning' } | null) => void;

  // Actions
  submitIssueUpload: (data: {
    category: string;
    machineName: string;
    description: string;
    urgency: 'Low' | 'Medium' | 'High' | 'Emergency';
    media: MediaProof[];
    location: { address: string; landmark: string; city: string; lat: number; lng: number };
  }) => void;
  acceptJobByTech: (techId?: string) => void;
  updateJobStatus: (newStatus: JobStatus) => void;
  sendChatMessage: (text: string, senderOverride?: 'user' | 'technician') => void;
  completeJobByTech: (proof: { beforeUrl: string; afterUrl: string; technicianNotes: string }) => void;
  submitRating: (stars: number, feedback: string) => void;
  toggleTechOnline: (techId: string) => void;
  resetPrototype: () => void;
  goToNextStep: () => void;
  goToPrevStep: () => void;
}

const PrototypeContext = createContext<PrototypeContextType | undefined>(undefined);

export const PrototypeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentStep, setCurrentStepState] = useState<CoreStepId>(1);
  const [activeRole, setActiveRoleState] = useState<UserRole>('user');
  const [userProfile, setUserProfile] = useState({
    name: 'Alex Mercer',
    email: 'alex.mercer@apexindustrial.com',
    phone: '+91 98200 44123',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
  });

  const [technicians, setTechnicians] = useState<TechnicianProfile[]>(MOCK_TECHNICIANS);
  const [activeTech, setActiveTech] = useState<TechnicianProfile>(MOCK_TECHNICIANS[0]);
  const [activeJob, setActiveJob] = useState<ServoLocalJob | null>(null);
  const [notification, setNotification] = useState<{ title: string; message: string; type?: 'info' | 'success' | 'warning' } | null>(null);

  // Auto-clear notification after 4 seconds
  useEffect(() => {
    if (notification) {
      const timer = setTimeout(() => setNotification(null), 4000);
      return () => clearTimeout(timer);
    }
  }, [notification]);

  // Sync state with localStorage
  useEffect(() => {
    try {
      const savedJob = localStorage.getItem('aetherion_pitch_job');
      if (savedJob) setActiveJob(JSON.parse(savedJob));
      const savedStep = localStorage.getItem('aetherion_pitch_step');
      if (savedStep) setCurrentStepState(Number(savedStep) as CoreStepId);
      const savedRole = localStorage.getItem('aetherion_pitch_role');
      if (savedRole) setActiveRoleState(savedRole as UserRole);
    } catch (e) {
      console.error('Error reading localStorage', e);
    }
  }, []);

  const saveToStorage = (job: ServoLocalJob | null, step: CoreStepId, role: UserRole) => {
    try {
      if (job) localStorage.setItem('aetherion_pitch_job', JSON.stringify(job));
      else localStorage.removeItem('aetherion_pitch_job');
      localStorage.setItem('aetherion_pitch_step', step.toString());
      localStorage.setItem('aetherion_pitch_role', role);
    } catch (e) {
      console.error('Error writing localStorage', e);
    }
  };

  // Broadcast channel for multi-tab real-time sync
  useEffect(() => {
    let bc: BroadcastChannel | null = null;
    if (typeof window !== 'undefined' && 'BroadcastChannel' in window) {
      bc = new BroadcastChannel('aetherion_realtime_sync');
      bc.onmessage = (event: MessageEvent<RealtimeSyncMessage>) => {
        const { type, payload } = event.data;

        if (type === 'JOB_CREATED') {
          setActiveJob(payload);
          setNotification({
            title: '🔔 NEW REPAIR REQUEST RECEIVED!',
            message: `${payload.machineName} (${payload.urgency}) near ${payload.location.landmark}`,
            type: 'warning',
          });
        } else if (type === 'JOB_ACCEPTED') {
          setActiveJob(payload);
          setCurrentStepState(5);
          setNotification({
            title: '⚡ TECHNICIAN ASSIGNED!',
            message: `${payload.assignedTechnician.name} accepted your request!`,
            type: 'success',
          });
        } else if (type === 'STATUS_CHANGED') {
          setActiveJob(payload);
          setNotification({
            title: `📍 Status Updated: ${payload.status}`,
            message: `Current progress: ${payload.status}`,
            type: 'info',
          });
        } else if (type === 'CHAT_SENT') {
          setActiveJob(payload);
          setNotification({
            title: `💬 Message from ${payload.chatMessages[payload.chatMessages.length - 1].senderName}`,
            message: payload.chatMessages[payload.chatMessages.length - 1].text,
            type: 'info',
          });
        } else if (type === 'JOB_COMPLETED') {
          setActiveJob(payload);
          setCurrentStepState(6);
          setNotification({
            title: '🎉 Repair Work Completed!',
            message: 'Digital proof uploaded by technician. Please review and rate.',
            type: 'success',
          });
        } else if (type === 'RATING_SUBMITTED') {
          setActiveJob(payload);
        } else if (type === 'TECH_ONLINE_TOGGLE') {
          setTechnicians(payload);
        }
      };
    }

    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'aetherion_pitch_job' && e.newValue) {
        setActiveJob(JSON.parse(e.newValue));
      }
    };
    window.addEventListener('storage', handleStorageChange);

    return () => {
      if (bc) bc.close();
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  const broadcastEvent = (msg: RealtimeSyncMessage) => {
    if (typeof window !== 'undefined' && 'BroadcastChannel' in window) {
      const bc = new BroadcastChannel('aetherion_realtime_sync');
      bc.postMessage(msg);
      bc.close();
    }
  };

  const setCurrentStep = (step: CoreStepId) => {
    setCurrentStepState(step);
    saveToStorage(activeJob, step, activeRole);
  };

  const setActiveRole = (role: UserRole) => {
    setActiveRoleState(role);
    saveToStorage(activeJob, currentStep, role);
  };

  const goToNextStep = () => {
    if (currentStep < 6) setCurrentStep((currentStep + 1) as CoreStepId);
  };

  const goToPrevStep = () => {
    if (currentStep > 1) setCurrentStep((currentStep - 1) as CoreStepId);
  };

  // STEP 1: Issue Upload -> generates AI Diagnosis & Cost Estimate
  const submitIssueUpload = (data: {
    category: string;
    machineName: string;
    description: string;
    urgency: 'Low' | 'Medium' | 'High' | 'Emergency';
    media: MediaProof[];
    location: { address: string; landmark: string; city: string; lat: number; lng: number };
  }) => {
    // Generate AI Diagnosis report based on inputs
    const aiDiagnosis: AIDiagnosisResult = {
      detectedIssue: `Possible Compressor High-Pressure Cutoff & Thermal Coil Overheat (${data.category})`,
      category: data.category,
      severity: data.urgency === 'Emergency' ? 'Critical Emergency' : 'High',
      confidence: 96.4,
      recommendedParts: [
        { name: 'OEM High-Pressure Cutoff Switch Assembly', estimatedCost: 1850, inStock: true },
        { name: 'R-410A Eco Refrigerant Charge (1.2 kg)', estimatedCost: 1200, inStock: true },
        { name: 'Thermal Overload Relay Filter', estimatedCost: 450, inStock: true },
      ],
      estimatedLaborHours: 1.5,
      estimatedLaborCost: 999,
      estimatedTotal: 4499,
    };

    const newJob: ServoLocalJob = {
      id: `JOB-${Math.floor(100000 + Math.random() * 900000)}`,
      requestCode: `#SERVO-${Math.floor(1000 + Math.random() * 9000)}`,
      createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      user: {
        name: userProfile.name,
        email: userProfile.email,
        phone: userProfile.phone,
        avatar: userProfile.avatar,
      },
      status: 'DISPATCHING',
      machineName: data.machineName,
      category: data.category,
      problemDescription: data.description,
      urgency: data.urgency,
      media: data.media,
      location: data.location,
      aiDiagnosis,
      chatMessages: [
        {
          id: 'msg-1',
          sender: 'user',
          senderName: userProfile.name,
          text: `Emergency repair request submitted for ${data.machineName}. AI Diagnosis report attached.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
      ],
    };

    setActiveJob(newJob);
    saveToStorage(newJob, 2, activeRole);
    setCurrentStep(2); // Advance to AI Diagnosis

    broadcastEvent({ type: 'JOB_CREATED', jobId: newJob.id, payload: newJob, timestamp: Date.now() });

    setNotification({
      title: '🤖 AI Diagnosis Generated!',
      message: 'Multimodal computer vision analyzed equipment failure.',
      type: 'info',
    });
  };

  // STEP 4: Technician Accepts Job
  const acceptJobByTech = (techId?: string) => {
    if (!activeJob) return;
    const assigned = technicians.find((t) => t.id === (techId || activeTech.id)) || activeTech;

    const updatedJob: ServoLocalJob = {
      ...activeJob,
      status: 'ASSIGNED',
      assignedTechnician: assigned,
      chatMessages: [
        ...activeJob.chatMessages,
        {
          id: `msg-${Date.now()}`,
          sender: 'technician',
          senderName: assigned.name,
          text: `Hello ${userProfile.name}! I have accepted your request. Moving to your location now. ETA 15 mins.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
      ],
    };

    setActiveJob(updatedJob);
    saveToStorage(updatedJob, 5, activeRole);
    setCurrentStep(5); // Step 5: Repair in Progress

    broadcastEvent({ type: 'JOB_ACCEPTED', jobId: updatedJob.id, payload: updatedJob, timestamp: Date.now() });
  };

  // Update Status
  const updateJobStatus = (newStatus: JobStatus) => {
    if (!activeJob) return;
    const updatedJob: ServoLocalJob = {
      ...activeJob,
      status: newStatus,
    };
    setActiveJob(updatedJob);
    saveToStorage(updatedJob, currentStep, activeRole);

    broadcastEvent({ type: 'STATUS_CHANGED', jobId: updatedJob.id, payload: updatedJob, timestamp: Date.now() });
  };

  // Chat
  const sendChatMessage = (text: string, senderOverride?: 'user' | 'technician') => {
    if (!activeJob) return;
    const sender = senderOverride || (activeRole === 'technician' ? 'technician' : 'user');
    const senderName = sender === 'technician' ? activeJob.assignedTechnician?.name || 'Technician' : userProfile.name;

    const updatedJob: ServoLocalJob = {
      ...activeJob,
      chatMessages: [
        ...activeJob.chatMessages,
        {
          id: `msg-${Date.now()}`,
          sender,
          senderName,
          text,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
      ],
    };

    setActiveJob(updatedJob);
    saveToStorage(updatedJob, currentStep, activeRole);
    broadcastEvent({ type: 'CHAT_SENT', jobId: updatedJob.id, payload: updatedJob, timestamp: Date.now() });
  };

  // Technician Completes Job
  const completeJobByTech = (proof: { beforeUrl: string; afterUrl: string; technicianNotes: string }) => {
    if (!activeJob) return;
    const updatedJob: ServoLocalJob = {
      ...activeJob,
      status: 'COMPLETED',
      proofOfRepair: {
        beforeUrl: proof.beforeUrl,
        afterUrl: proof.afterUrl,
        technicianNotes: proof.technicianNotes,
        completedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      },
    };

    setActiveJob(updatedJob);
    saveToStorage(updatedJob, 6, activeRole);
    setCurrentStep(6);

    broadcastEvent({ type: 'JOB_COMPLETED', jobId: updatedJob.id, payload: updatedJob, timestamp: Date.now() });
  };

  // Submit rating
  const submitRating = (stars: number, feedback: string) => {
    if (!activeJob) return;
    const updatedJob: ServoLocalJob = {
      ...activeJob,
      status: 'RATED',
      rating: {
        stars,
        feedback,
        ratedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      },
    };

    setActiveJob(updatedJob);
    saveToStorage(updatedJob, currentStep, activeRole);

    broadcastEvent({ type: 'RATING_SUBMITTED', jobId: updatedJob.id, payload: updatedJob, timestamp: Date.now() });

    setNotification({
      title: '🌟 Review Submitted!',
      message: `Thank you for rating ${activeJob.assignedTechnician?.name || 'Technician'} ${stars} stars.`,
      type: 'success',
    });
  };

  const toggleTechOnline = (techId: string) => {
    const updated = technicians.map((t) => (t.id === techId ? { ...t, isOnline: !t.isOnline } : t));
    setTechnicians(updated);
    if (activeTech.id === techId) setActiveTech({ ...activeTech, isOnline: !activeTech.isOnline });
    broadcastEvent({ type: 'TECH_ONLINE_TOGGLE', payload: updated, timestamp: Date.now() });
  };

  const resetPrototype = () => {
    localStorage.removeItem('aetherion_pitch_job');
    localStorage.removeItem('aetherion_pitch_step');
    localStorage.removeItem('aetherion_pitch_role');
    setActiveJob(null);
    setCurrentStep(1);
    setTechnicians(MOCK_TECHNICIANS);
    setNotification({
      title: '🔄 Prototype Reset',
      message: 'All local jobs and session data cleared.',
      type: 'info',
    });
  };

  return (
    <PrototypeContext.Provider
      value={{
        currentStep,
        setCurrentStep,
        activeRole,
        setActiveRole,
        userProfile,
        setUserProfile,
        technicians,
        setTechnicians,
        activeJob,
        setActiveJob,
        activeTech,
        setActiveTech,
        notification,
        setNotification,
        submitIssueUpload,
        acceptJobByTech,
        updateJobStatus,
        sendChatMessage,
        completeJobByTech,
        submitRating,
        toggleTechOnline,
        resetPrototype,
        goToNextStep,
        goToPrevStep,
      }}
    >
      {children}
    </PrototypeContext.Provider>
  );
};

export const usePrototype = () => {
  const context = useContext(PrototypeContext);
  if (!context) throw new Error('usePrototype must be used within PrototypeProvider');
  return context;
};
