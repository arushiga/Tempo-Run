import { Layout } from '../components/Layout';
import { useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../components/ui/dialog';
import { useActivities } from '../hooks/useAppData';
import { formatDuration, formatPace, formatDate, categoryLabel } from '../lib/types';
import type { RunCategory } from '../lib/types';

type CategoryOption = { value: RunCategory; label: string; emoji: string; color: string };

const CATEGORIES: CategoryOption[] = [
  { value: 'easy',  label: 'Easy Run',  emoji: '🏃', color: 'from-blue-500 to-sky-600' },
  { value: 'tempo', label: 'Tempo',     emoji: '⚡', color: 'from-amber-500 to-orange-600' },
  { value: 'long',  label: 'Long Run',  emoji: '🎯', color: 'from-emerald-500 to-green-600' },
  { value: 'race',  label: 'Race',      emoji: '🏁', color: 'from-purple-500 to-fuchsia-600' },
];

const TYPE_COLORS: Record<string, string> = {
  easy:  'from-sky-400 to-blue-500',
  tempo: 'from-amber-400 to-orange-500',
  long:  'from-emerald-400 to-green-500',
  race:  'from-fuchsia-400 to-pink-500',
};

export default function Record() {
  const { activities, addActivity } = useActivities();
  const [open, setOpen] = useState(false);

  // Form state
  const [name, setName] = useState('');
  const [completionDate, setCompletionDate] = useState(new Date().toISOString().split('T')[0]);
  const [distanceStr, setDistanceStr] = useState('');
  const [durationStr, setDurationStr] = useState('');
  const [category, setCategory] = useState<RunCategory>('easy');
  const [formError, setFormError] = useState('');

  // Auto-compute pace from distance + duration
  const computedPace = (() => {
    const dist = parseFloat(distanceStr);
    const [h = '0', m = '0', s = '0'] = durationStr.split(':');
    const secs = parseInt(h) * 3600 + parseInt(m) * 60 + parseInt(s);
    if (dist > 0 && secs > 0) return formatPace(secs / dist);
    return '--:--';
  })();

  const handleSubmit = () => {
    const dist = parseFloat(distanceStr);
    const parts = durationStr.split(':').map(Number);
    let secs = 0;
    if (parts.length === 3) secs = parts[0] * 3600 + parts[1] * 60 + parts[2];
    else if (parts.length === 2) secs = parts[0] * 60 + parts[1];

    if (!name.trim()) { setFormError('Activity name is required.'); return; }
    if (!dist || dist <= 0) { setFormError('Enter a valid distance.'); return; }
    if (!secs || secs <= 0) { setFormError('Enter duration as H:MM:SS or MM:SS.'); return; }
    if (!completionDate) { setFormError('Select a date.'); return; }

    setFormError('');
    addActivity({
      name: name.trim(),
      completionDate,
      distanceMiles: dist,
      durationSeconds: secs,
      avgPaceSecondsPerMile: Math.round(secs / dist),
      category,
    });

    // Reset form
    setName('');
    setDistanceStr('');
    setDurationStr('');
    setCompletionDate(new Date().toISOString().split('T')[0]);
    setCategory('easy');
    setOpen(false);
  };

  const recentActivities = [...activities]
    .sort((a, b) => b.completionDate.localeCompare(a.completionDate))
    .slice(0, 5);

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        <div className="relative z-10">
          <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">Record Run 🏃</h1>
          <p className="text-white/90 text-[15px] font-medium">Log your training activities</p>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* Log a Run button */}
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <button className="w-full backdrop-blur-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded-[24px] py-5 font-bold text-[18px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center gap-3">
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2.5">
                <line x1="12" y1="5" x2="12" y2="19" />
                <line x1="5" y1="12" x2="19" y2="12" />
              </svg>
              Log a Run
            </button>
          </DialogTrigger>

          <DialogContent className="backdrop-blur-2xl bg-white/90 border border-white/80 rounded-[28px] shadow-2xl max-w-sm mx-auto p-0 overflow-hidden">
            <DialogHeader className="px-6 pt-6 pb-4 border-b border-slate-100">
              <DialogTitle className="font-bold text-[20px] text-slate-800">Log a Run</DialogTitle>
            </DialogHeader>

            <div className="px-6 py-5 space-y-4 max-h-[70vh] overflow-y-auto">
              {/* Activity Name */}
              <div>
                <label className="block text-[12px] font-semibold text-slate-600 uppercase tracking-wider mb-1.5">
                  Activity Name
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  placeholder="Morning Easy Run"
                  className="w-full backdrop-blur-md bg-white/80 border border-slate-200 rounded-2xl px-4 py-3 text-[14px] text-slate-800 font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-400/50 focus:border-blue-300 transition-all"
                />
              </div>

              {/* Date */}
              <div>
                <label className="block text-[12px] font-semibold text-slate-600 uppercase tracking-wider mb-1.5">
                  Date Completed
                </label>
                <input
                  type="date"
                  value={completionDate}
                  onChange={e => setCompletionDate(e.target.value)}
                  className="w-full backdrop-blur-md bg-white/80 border border-slate-200 rounded-2xl px-4 py-3 text-[14px] text-slate-800 font-medium focus:outline-none focus:ring-2 focus:ring-blue-400/50 focus:border-blue-300 transition-all"
                />
              </div>

              {/* Distance */}
              <div>
                <label className="block text-[12px] font-semibold text-slate-600 uppercase tracking-wider mb-1.5">
                  Distance (miles)
                </label>
                <input
                  type="number"
                  value={distanceStr}
                  onChange={e => setDistanceStr(e.target.value)}
                  placeholder="5.0"
                  step="0.1"
                  min="0"
                  className="w-full backdrop-blur-md bg-white/80 border border-slate-200 rounded-2xl px-4 py-3 text-[14px] text-slate-800 font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-400/50 focus:border-blue-300 transition-all"
                />
              </div>

              {/* Duration */}
              <div>
                <label className="block text-[12px] font-semibold text-slate-600 uppercase tracking-wider mb-1.5">
                  Duration (H:MM:SS or MM:SS)
                </label>
                <input
                  type="text"
                  value={durationStr}
                  onChange={e => setDurationStr(e.target.value)}
                  placeholder="45:30"
                  className="w-full backdrop-blur-md bg-white/80 border border-slate-200 rounded-2xl px-4 py-3 text-[14px] text-slate-800 font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-400/50 focus:border-blue-300 transition-all"
                />
              </div>

              {/* Avg Pace (computed) */}
              <div className="backdrop-blur-md bg-slate-50/80 rounded-2xl px-4 py-3 border border-slate-100 flex items-center justify-between">
                <div>
                  <p className="text-[11px] text-slate-500 font-semibold uppercase tracking-wider">Avg Pace</p>
                  <p className="text-[18px] font-bold text-slate-800">{computedPace} <span className="text-[12px] font-medium text-slate-500">min/mi</span></p>
                </div>
                <span className="text-2xl">⚡</span>
              </div>

              {/* Run Category */}
              <div>
                <label className="block text-[12px] font-semibold text-slate-600 uppercase tracking-wider mb-2">
                  Run Category
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {CATEGORIES.map(cat => (
                    <button
                      key={cat.value}
                      onClick={() => setCategory(cat.value)}
                      className={`flex items-center gap-2 rounded-2xl px-3 py-3 border font-semibold text-[13px] transition-all hover:scale-[1.02] ${
                        category === cat.value
                          ? `bg-gradient-to-r ${cat.color} text-white border-transparent shadow-md`
                          : 'bg-white/80 border-slate-200 text-slate-700 hover:border-slate-300'
                      }`}
                    >
                      <span className="text-lg">{cat.emoji}</span>
                      {cat.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Error */}
              {formError && (
                <p className="text-[12px] text-red-600 font-medium bg-red-50 rounded-xl px-3 py-2">
                  {formError}
                </p>
              )}

              {/* Submit */}
              <button
                onClick={handleSubmit}
                className="w-full bg-gradient-to-r from-slate-700 to-blue-900 text-white rounded-2xl py-4 font-bold text-[15px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all"
              >
                Save Activity
              </button>
            </div>
          </DialogContent>
        </Dialog>

        {/* Link Device — Coming Soon */}
        <button
          disabled
          className="w-full backdrop-blur-xl bg-white/40 text-slate-400 rounded-[24px] py-4 font-semibold text-[15px] border border-white/60 border-dashed cursor-not-allowed flex items-center justify-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
          </svg>
          Link Device — Coming Soon
        </button>

        {/* Quick Start Category Tiles */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h3 className="font-bold text-[16px] text-slate-800 mb-4">Quick Log</h3>
          <div className="grid grid-cols-2 gap-3">
            {CATEGORIES.map(cat => (
              <button
                key={cat.value}
                onClick={() => { setCategory(cat.value); setOpen(true); }}
                className={`backdrop-blur-xl bg-gradient-to-br ${cat.color} rounded-2xl p-4 border border-white/30 shadow-lg hover:shadow-xl hover:scale-105 transition-all text-left`}
              >
                <span className="text-3xl mb-2 block">{cat.emoji}</span>
                <p className="text-white font-bold text-[13px]">{cat.label}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Recent Runs (real data) */}
        <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
          <h3 className="font-bold text-[16px] text-slate-800 mb-4">Recent Activities</h3>

          {recentActivities.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-slate-500 text-[14px]">No activities yet.</p>
              <p className="text-slate-400 text-[12px] mt-1">Tap "Log a Run" to add your first one!</p>
            </div>
          ) : (
            <div className="space-y-2">
              {recentActivities.map(act => {
                const cat = act.category;
                const colorKey = cat === 'long' ? 'long' : cat;
                return (
                  <div key={act.id} className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`px-2.5 py-1 rounded-xl bg-gradient-to-r ${TYPE_COLORS[colorKey] ?? 'from-slate-400 to-slate-500'} text-white text-[10px] font-bold`}>
                        {categoryLabel(cat)}
                      </div>
                      <div>
                        <p className="text-[13px] font-bold text-slate-800">{act.name}</p>
                        <p className="text-[11px] text-slate-600">{formatDate(act.completionDate)}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-[13px] font-bold text-slate-800">{act.distanceMiles.toFixed(1)} mi</p>
                      <p className="text-[11px] text-slate-600">{formatDuration(act.durationSeconds)}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}
