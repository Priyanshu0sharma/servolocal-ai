'use client';

import React from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, X } from 'lucide-react';

export const RealtimeNotification: React.FC = () => {
  const { notification, setNotification } = usePrototype();

  return (
    <AnimatePresence>
      {notification && (
        <motion.div
          initial={{ opacity: 0, y: -50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: -20, scale: 0.9 }}
          className="fixed top-20 right-6 z-50 max-w-sm w-full bg-[#1B4332] text-white p-4 rounded-2xl shadow-2xl border border-[#7B4B2A] flex items-start gap-3 backdrop-blur-md"
        >
          <div className="p-2 rounded-xl bg-[#7B4B2A] text-amber-200 shrink-0">
            <Bell className="w-5 h-5 animate-bounce" />
          </div>
          <div className="flex-1 min-w-0">
            <h4 className="text-xs font-extrabold text-amber-100 uppercase tracking-wider">
              {notification.title}
            </h4>
            <p className="text-xs text-emerald-100 mt-0.5 leading-snug font-medium">
              {notification.message}
            </p>
          </div>
          <button
            onClick={() => setNotification(null)}
            className="p-1 rounded-lg text-emerald-300 hover:text-white hover:bg-emerald-800/60"
          >
            <X className="w-4 h-4" />
          </button>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
