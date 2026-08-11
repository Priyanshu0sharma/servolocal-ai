'use client';

import React, { useState } from 'react';
import { usePrototype } from '../../context/PrototypeContext';
import { SAMPLE_FAILURE_ASSETS } from '../../data/mockData';
import { MediaProof } from '../../types/prototype';
import { UploadCloud, Image as ImageIcon, Video, MapPin, Camera, Sparkles, Send, Trash2 } from 'lucide-react';

export const Step1IssueUploadScreen: React.FC = () => {
  const { submitIssueUpload } = usePrototype();

  const [category, setCategory] = useState('Commercial HVAC & AC');
  const [machineName, setMachineName] = useState('Daikin VRV V Outdoor Chiller Unit');
  const [description, setDescription] = useState(
    'Chiller starts, runs for 10 mins, then cuts off abruptly with High-Pressure Error E-04.'
  );
  const [urgency, setUrgency] = useState<'Low' | 'Medium' | 'High' | 'Emergency'>('Emergency');
  const [media, setMedia] = useState<MediaProof[]>([SAMPLE_FAILURE_ASSETS[0]]);

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const files = Array.from(e.target.files);
      const newItems: MediaProof[] = files.map((f, idx) => ({
        id: `upload-${Date.now()}-${idx}`,
        name: f.name,
        url: URL.createObjectURL(f),
        type: f.type.startsWith('video') ? 'video' : 'image',
        size: `${(f.size / (1024 * 1024)).toFixed(1)} MB`,
      }));
      setMedia((prev) => [...prev, ...newItems]);
    }
  };

  const removeMedia = (id: string) => {
    setMedia((prev) => prev.filter((m) => m.id !== id));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    submitIssueUpload({
      category,
      machineName,
      description,
      urgency,
      media,
      location: {
        address: 'Building 4B, Mindspace IT Park',
        landmark: 'West Gate #2, Airoli',
        city: 'Navi Mumbai',
        lat: 19.076,
        lng: 72.8777,
      },
    });
  };

  return (
    <div className="p-4 space-y-4 animate-fade-in pb-6">
      {/* Screen Title */}
      <div className="bg-[#1B4332] text-white p-4 rounded-2xl shadow-md border border-[#7B4B2A]/40 space-y-1">
        <div className="flex items-center gap-1.5 text-[10px] font-mono text-amber-300 font-bold uppercase tracking-wider">
          <Sparkles className="w-3.5 h-3.5" />
          <span>SERVOLOCAL AI — STEP 01</span>
        </div>
        <h2 className="text-base font-black tracking-tight">Report a Repair Issue</h2>
        <p className="text-[11px] text-emerald-100/80">
          Upload equipment photo/video for instant Multimodal AI Diagnosis
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-3">
        {/* Real File Upload Dropzone */}
        <div className="relative border-2 border-dashed border-[#1B4332]/30 bg-[#FFF8F1] hover:bg-white rounded-2xl p-4 text-center cursor-pointer group transition-all">
          <input
            type="file"
            accept="image/*,video/*"
            multiple
            onChange={handleFileUpload}
            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
          />
          <div className="space-y-1.5 pointer-events-none">
            <div className="w-10 h-10 rounded-xl bg-[#1B4332] text-amber-300 mx-auto flex items-center justify-center group-hover:scale-110 transition-transform">
              <Camera className="w-5 h-5" />
            </div>
            <p className="text-xs font-bold text-[#1B4332]">Take / Upload Photo or Video</p>
            <p className="text-[10px] text-[#5D6D64]">Select file from device or drag & drop</p>
          </div>
        </div>

        {/* Uploaded Media Preview */}
        {media.length > 0 && (
          <div className="flex gap-2 overflow-x-auto pb-1">
            {media.map((item) => (
              <div
                key={item.id}
                className="relative w-20 h-20 rounded-xl overflow-hidden border border-[#1B4332]/30 shrink-0 shadow-sm group bg-black"
              >
                <img src={item.url} alt={item.name} className="w-full h-full object-cover" />
                <button
                  type="button"
                  onClick={() => removeMedia(item.id)}
                  className="absolute top-1 right-1 p-1 bg-rose-600/90 text-white rounded-md text-[10px]"
                >
                  <Trash2 className="w-3 h-3" />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Machine Name & Category */}
        <div>
          <label className="block text-[11px] font-bold text-[#1C2520] mb-1">
            Equipment Name / Model
          </label>
          <input
            type="text"
            value={machineName}
            onChange={(e) => setMachineName(e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-[#1B4332]/20 text-xs bg-white text-[#1C2520] focus:ring-2 focus:ring-[#1B4332]"
            required
          />
        </div>

        {/* Service Category */}
        <div>
          <label className="block text-[11px] font-bold text-[#1C2520] mb-1">Appliance / Machine Category</label>
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-[#1B4332]/20 text-xs bg-white text-[#1C2520] font-medium"
          >
            <option>Commercial HVAC & AC</option>
            <option>Air Conditioner (Split / Window)</option>
            <option>Refrigerator & Deep Freezer</option>
            <option>Washing Machine & Dryer</option>
            <option>Industrial Chiller & Cooling</option>
            <option>Motors, Pumps & Generators</option>
            <option>Kitchen Appliances & Microwave</option>
            <option>Water Purifier & RO System</option>
            <option>Elevator & Lift Controls</option>
            <option>Industrial Machinery & CNC</option>
            <option>Power & Solar Inverters</option>
          </select>
        </div>

        {/* Issue Description */}
        <div>
          <label className="block text-[11px] font-bold text-[#1C2520] mb-1">
            Symptom Description
          </label>
          <textarea
            rows={2}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-3 py-2 rounded-xl border border-[#1B4332]/20 text-xs bg-white text-[#1C2520]"
            required
          />
        </div>

        {/* Urgency Selector */}
        <div>
          <label className="block text-[11px] font-bold text-[#1C2520] mb-1">Breakdown Urgency</label>
          <div className="grid grid-cols-4 gap-1">
            {(['Low', 'Medium', 'High', 'Emergency'] as const).map((lvl) => (
              <button
                key={lvl}
                type="button"
                onClick={() => setUrgency(lvl)}
                className={`py-1.5 rounded-lg text-[10px] font-bold btn-tactile border ${
                  urgency === lvl
                    ? lvl === 'Emergency'
                      ? 'bg-rose-700 text-white border-rose-700'
                      : 'bg-[#1B4332] text-white border-[#1B4332]'
                    : 'bg-white text-[#5D6D64] border-[#1B4332]/15'
                }`}
              >
                {lvl}
              </button>
            ))}
          </div>
        </div>

        {/* Submit Issue CTA */}
        <button
          type="submit"
          className="w-full py-3 rounded-xl bg-[#7B4B2A] hover:bg-[#633C20] text-white text-xs font-black flex items-center justify-center gap-2 shadow-lg transition-all btn-tactile border border-amber-500/30"
        >
          <Send className="w-4 h-4 text-amber-200" />
          <span>SUBMIT ISSUE FOR AI DIAGNOSIS</span>
        </button>
      </form>
    </div>
  );
};
