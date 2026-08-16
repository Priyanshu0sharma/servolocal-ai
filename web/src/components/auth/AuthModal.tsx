'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { ShieldCheck, User, Wrench, Building2, CreditCard, Sparkles, X, CheckCircle2 } from 'lucide-react';

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const AuthModal: React.FC<AuthModalProps> = ({ isOpen, onClose }) => {
  const { setActiveRole, setUserProfile } = usePrototype();
  const [authTab, setAuthTab] = useState<'customer' | 'technician' | 'admin'>('customer');

  // Customer form
  const [custName, setCustName] = useState('Priyanshu Sharma');
  const [custPhone, setCustPhone] = useState('+91 98765 12345');
  const [custEmail, setCustEmail] = useState('priyanshu@user.com');

  // Tech Form + Bank Account Details
  const [techName, setTechName] = useState('Rahul Kumar');
  const [techPhone, setTechPhone] = useState('+91 98765 43210');
  const [techSpeciality, setTechSpeciality] = useState('HVAC & Appliance Specialist');
  const [bankName, setBankName] = useState('HDFC Bank');
  const [accountNo, setAccountNo] = useState('918234567890');
  const [ifscCode, setIfscCode] = useState('HDFC0001234');
  const [upiId, setUpiId] = useState('rahul@okaxis');

  if (!isOpen) return null;

  const handleCustomerLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setUserProfile({
      name: custName,
      phone: custPhone,
      email: custEmail,
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80'
    });
    setActiveRole('user');
    onClose();
  };

  const handleTechLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setActiveRole('technician');
    onClose();
  };

  const handleAdminLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setActiveRole('admin');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#0F172A] border border-slate-700/80 rounded-3xl max-w-lg w-full text-slate-100 shadow-2xl overflow-hidden animate-fadeIn">
        {/* Header */}
        <div className="bg-[#0A2E1D] p-6 border-b border-emerald-900/40 relative">
          <button onClick={onClose} className="absolute top-4 right-4 p-2 text-slate-400 hover:text-white rounded-full bg-slate-800/60">
            <X className="w-4 h-4" />
          </button>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-emerald-500 to-amber-500 flex items-center justify-center font-extrabold text-white text-xl shadow-lg border border-white/20">
              ⬡
            </div>
            <div>
              <h2 className="font-extrabold text-lg text-white flex items-center gap-2">
                ServoLocal AI Authentication
              </h2>
              <p className="text-xs text-emerald-300/80">Select account type to enter Production SaaS Workspace</p>
            </div>
          </div>

          {/* Role Tabs */}
          <div className="grid grid-cols-3 gap-2 mt-4 bg-slate-900/80 p-1.5 rounded-2xl border border-slate-800">
            <button
              onClick={() => setAuthTab('customer')}
              className={`py-2 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
                authTab === 'customer' ? 'bg-emerald-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
              }`}
            >
              <User className="w-3.5 h-3.5" />
              <span>Customer</span>
            </button>

            <button
              onClick={() => setAuthTab('technician')}
              className={`py-2 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
                authTab === 'technician' ? 'bg-amber-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
              }`}
            >
              <Wrench className="w-3.5 h-3.5" />
              <span>Technician</span>
            </button>

            <button
              onClick={() => setAuthTab('admin')}
              className={`py-2 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
                authTab === 'admin' ? 'bg-blue-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Admin</span>
            </button>
          </div>
        </div>

        {/* Tab Forms */}
        <div className="p-6 space-y-4">
          {/* CUSTOMER LOGIN FORM */}
          {authTab === 'customer' && (
            <form onSubmit={handleCustomerLogin} className="space-y-3">
              <div className="space-y-1">
                <label className="text-xs font-bold text-slate-300">Customer Full Name</label>
                <input
                  type="text"
                  value={custName}
                  onChange={(e) => setCustName(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-3 text-xs text-white"
                  required
                />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-bold text-slate-300">Mobile Number (OTP Verified)</label>
                <input
                  type="text"
                  value={custPhone}
                  onChange={(e) => setCustPhone(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-3 text-xs text-white"
                  required
                />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-bold text-slate-300">Email Address</label>
                <input
                  type="email"
                  value={custEmail}
                  onChange={(e) => setCustEmail(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-xl p-3 text-xs text-white"
                  required
                />
              </div>

              <button
                type="submit"
                className="w-full py-3 bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-500 hover:to-emerald-400 text-white font-extrabold text-xs rounded-xl shadow-lg mt-2"
              >
                Login to Customer Workspace
              </button>
            </form>
          )}

          {/* TECHNICIAN LOGIN + BANK DETAILS FORM */}
          {authTab === 'technician' && (
            <form onSubmit={handleTechLogin} className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1">
                  <label className="text-xs font-bold text-slate-300">Technician Name</label>
                  <input
                    type="text"
                    value={techName}
                    onChange={(e) => setTechName(e.target.value)}
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl p-2.5 text-xs text-white"
                    required
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-bold text-slate-300">Mobile Number</label>
                  <input
                    type="text"
                    value={techPhone}
                    onChange={(e) => setTechPhone(e.target.value)}
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl p-2.5 text-xs text-white"
                    required
                  />
                </div>
              </div>

              {/* BANK ACCOUNT DETAILS FOR PAYOUTS */}
              <div className="bg-slate-900/90 border border-amber-500/30 p-3.5 rounded-2xl space-y-2">
                <div className="flex items-center gap-2 text-xs font-extrabold text-amber-400">
                  <CreditCard className="w-4 h-4 text-amber-400" />
                  <span>Razorpay Bank Account & Payout Details</span>
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div>
                    <label className="text-[10px] text-slate-400">Bank Name</label>
                    <input
                      type="text"
                      value={bankName}
                      onChange={(e) => setBankName(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-white"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] text-slate-400">Account Number</label>
                    <input
                      type="text"
                      value={accountNo}
                      onChange={(e) => setAccountNo(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-white"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] text-slate-400">IFSC Code</label>
                    <input
                      type="text"
                      value={ifscCode}
                      onChange={(e) => setIfscCode(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-white"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] text-slate-400">UPI ID</label>
                    <input
                      type="text"
                      value={upiId}
                      onChange={(e) => setUpiId(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-white"
                    />
                  </div>
                </div>
              </div>

              <button
                type="submit"
                className="w-full py-3 bg-gradient-to-r from-amber-600 to-amber-500 hover:from-amber-500 hover:to-amber-400 text-white font-extrabold text-xs rounded-xl shadow-lg mt-2"
              >
                Login to Technician Portal & Payouts
              </button>
            </form>
          )}

          {/* EXECUTIVE ADMIN LOGIN FORM */}
          {authTab === 'admin' && (
            <form onSubmit={handleAdminLogin} className="space-y-3">
              <div className="bg-slate-900 border border-blue-500/30 p-4 rounded-2xl space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold text-blue-400">
                  <ShieldCheck className="w-4 h-4 text-blue-400" />
                  <span>Executive Operations Command Center Access</span>
                </div>
                <p className="text-xs text-slate-300">Access full desktop analytics, emergency broadcast, active job streams, and pricing surge controls.</p>
              </div>

              <button
                type="submit"
                className="w-full py-3 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 text-white font-extrabold text-xs rounded-xl shadow-lg"
              >
                Launch Executive Admin Command Center
              </button>
            </form>
          )}

          {/* Quick Demo Login Preset Buttons */}
          <div className="pt-3 border-t border-slate-800 space-y-2">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block text-center">Quick 1-Click Demo Login</span>
            <div className="grid grid-cols-3 gap-2 text-[11px]">
              <button
                onClick={() => {
                  setActiveRole('user');
                  onClose();
                }}
                className="py-2 bg-emerald-950/60 hover:bg-emerald-900 text-emerald-300 border border-emerald-700/50 rounded-xl font-bold"
              >
                👤 Customer Demo
              </button>
              <button
                onClick={() => {
                  setActiveRole('technician');
                  onClose();
                }}
                className="py-2 bg-amber-950/60 hover:bg-amber-900 text-amber-300 border border-amber-700/50 rounded-xl font-bold"
              >
                👨‍🔧 Tech Demo
              </button>
              <button
                onClick={() => {
                  setActiveRole('admin');
                  onClose();
                }}
                className="py-2 bg-blue-950/60 hover:bg-blue-900 text-blue-300 border border-blue-700/50 rounded-xl font-bold"
              >
                🛡️ Admin Demo
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
