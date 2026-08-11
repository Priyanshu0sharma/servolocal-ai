'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { Search, X, Star, MapPin, UserCheck } from 'lucide-react';

interface TechSearchModalProps {
  onClose: () => void;
}

export const TechSearchModal: React.FC<TechSearchModalProps> = ({ onClose }) => {
  const { technicians, acceptJobByTech, setCurrentStep } = usePrototype();
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTechs = technicians.filter((t) =>
    t.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    t.speciality.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAssign = (techId: string) => {
    acceptJobByTech(techId);
    onClose();
    setCurrentStep(4);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-white w-full max-w-lg rounded-2xl shadow-2xl border border-[#1B4332]/20 flex flex-col max-h-[85vh] overflow-hidden animate-fade-in">
        {/* Modal Header */}
        <div className="p-4 bg-[#1B4332] text-white flex items-center justify-between">
          <h2 className="text-xs font-bold uppercase tracking-wider">Search Technicians</h2>
          <button onClick={onClose} className="p-1 text-white/80 hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Search Input */}
        <div className="p-3 bg-[#F5EEE6] border-b border-[#1B4332]/10">
          <input
            type="text"
            placeholder="Search by name or speciality..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full px-3 py-2 rounded-xl text-xs bg-white border border-[#1B4332]/20"
          />
        </div>

        {/* List */}
        <div className="p-3 space-y-2 overflow-y-auto max-h-80 bg-[#FFF8F1]">
          {filteredTechs.map((tech) => (
            <div
              key={tech.id}
              className="p-3 rounded-xl bg-white border border-[#1B4332]/10 flex items-center justify-between gap-3 text-xs"
            >
              <div className="flex items-center gap-3">
                <img src={tech.avatar} alt={tech.name} className="w-10 h-10 rounded-xl object-cover" />
                <div>
                  <h4 className="font-bold text-[#1C2520]">{tech.name}</h4>
                  <p className="text-[10px] text-[#7B4B2A]">{tech.speciality}</p>
                </div>
              </div>

              <button
                onClick={() => handleAssign(tech.id)}
                className="px-3 py-1.5 rounded-lg bg-[#1B4332] text-white text-[11px] font-bold btn-tactile"
              >
                Assign
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
