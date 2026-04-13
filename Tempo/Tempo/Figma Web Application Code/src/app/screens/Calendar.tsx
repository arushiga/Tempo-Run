import { useState, useCallback } from 'react';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import { Layout } from '../components/Layout';
import { DraggableRunType } from '../components/DraggableRunType';
import { CalendarCell } from '../components/CalendarCell';
import { Slider } from '../components/ui/slider';
import {
  useWeekPlan,
  useActivities,
  getWeekActivities,
  totalMiles,
  activitiesByDayOfWeek,
} from '../hooks/useAppData';
import {
  getCurrentWeekStart,
  shiftWeek,
  formatDate,
  formatPace,
} from '../lib/types';
import { BarChart, Bar, XAxis, ResponsiveContainer, LineChart, Line } from 'recharts';

export type RunType = 'easy' | 'tempo' | 'race' | 'longRun';

export interface Run {
  type: RunType;
  id: string;
}

export interface ScheduledRun extends Run {
  day: number;
  time: 'AM' | 'PM';
  distanceMiles?: number;
}

const runTypes: { type: RunType; label: string; color: string; vibrant: string }[] = [
  { type: 'easy',    label: 'Easy',     color: '#7DD3FC', vibrant: '#0EA5E9' },
  { type: 'tempo',   label: 'Tempo',    color: '#FDBA74', vibrant: '#F97316' },
  { type: 'race',    label: 'Race',     color: '#C084FC', vibrant: '#A855F7' },
  { type: 'longRun', label: 'Long Run', color: '#6EE7B7', vibrant: '#10B981' },
];

const dayLabels = ['M', 'T', 'W', 'R', 'F', 'S', 'S'];
const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

export default function Calendar() {
  const [currentWeekStart, setCurrentWeekStart] = useState<string>(() => getCurrentWeekStart());
  const { weekPlan, updateRuns } = useWeekPlan(currentWeekStart);
  const { activities } = useActivities();
  const [expandedDays, setExpandedDays] = useState<Set<number>>(new Set());

  // Convert WeekPlan runs to ScheduledRun format for CalendarCell
  const scheduledRuns: ScheduledRun[] = weekPlan.runs.map(r => ({
    id: r.id,
    type: r.type,
    day: r.day,
    time: r.time,
    distanceMiles: r.distanceMiles,
  }));

  const handleDrop = useCallback((runType: RunType, day: number, time: 'AM' | 'PM') => {
    const existingIndex = weekPlan.runs.findIndex(r => r.day === day && r.time === time);
    const newRun = { id: Date.now().toString(), type: runType, day, time, distanceMiles: 0 };
    if (existingIndex !== -1) {
      const updated = [...weekPlan.runs];
      updated[existingIndex] = newRun;
      updateRuns(updated);
    } else {
      updateRuns([...weekPlan.runs, newRun]);
    }
  }, [weekPlan.runs, updateRuns]);

  const handleRemove = useCallback((id: string) => {
    updateRuns(weekPlan.runs.filter(r => r.id !== id));
  }, [weekPlan.runs, updateRuns]);

  const handleMove = useCallback((id: string, day: number, time: 'AM' | 'PM') => {
    const targetRun = weekPlan.runs.find(r => r.day === day && r.time === time && r.id !== id);
    if (targetRun) {
      updateRuns(
        weekPlan.runs
          .filter(r => r.id !== targetRun.id)
          .map(r => r.id === id ? { ...r, day, time } : r)
      );
    } else {
      updateRuns(weekPlan.runs.map(r => r.id === id ? { ...r, day, time } : r));
    }
  }, [weekPlan.runs, updateRuns]);

  const handleDistanceChange = useCallback((id: string, distanceMiles: number) => {
    updateRuns(weekPlan.runs.map(r => r.id === id ? { ...r, distanceMiles } : r));
  }, [weekPlan.runs, updateRuns]);

  const toggleDay = (day: number) => {
    setExpandedDays(prev => {
      const next = new Set(prev);
      if (next.has(day)) next.delete(day);
      else next.add(day);
      return next;
    });
  };

  const goToPrevWeek = () => setCurrentWeekStart(w => shiftWeek(w, -1));
  const goToNextWeek = () => setCurrentWeekStart(w => shiftWeek(w, 1));

  // Statistics
  const stats = {
    easy:    weekPlan.runs.filter(r => r.type === 'easy').length,
    tempo:   weekPlan.runs.filter(r => r.type === 'tempo').length,
    race:    weekPlan.runs.filter(r => r.type === 'race').length,
    longRun: weekPlan.runs.filter(r => r.type === 'longRun').length,
  };

  const totalRuns = weekPlan.runs.length;
  const relativeLoad = Math.max(0, 43 - (7 - totalRuns) * 5);
  const trainingIntensity = 15 + (stats.tempo * 5) + (stats.race * 10);

  // Planned vs Actual mileage
  const plannedMiles = weekPlan.runs.reduce((s, r) => s + (r.distanceMiles ?? 0), 0);
  const weekActs = getWeekActivities(activities, currentWeekStart);
  const actualMiles = totalMiles(weekActs);

  // Chart data
  const activityChartData = activitiesByDayOfWeek(activities, currentWeekStart);
  const plannedChartData = dayLabels.map((label, i) => {
    const dayRuns = weekPlan.runs.filter(r => r.day === i);
    const dist = dayRuns.reduce((s, r) => s + (r.distanceMiles ?? 0), 0);
    return { day: label, planned: Math.round(dist * 10) / 10 };
  });

  const combinedChartData = activityChartData.map((d, i) => ({
    day: d.day,
    actual: d.distance,
    planned: plannedChartData[i].planned,
  }));

  // Week label
  const weekStartDate = new Date(currentWeekStart + 'T00:00:00');
  const weekEndDate = new Date(currentWeekStart + 'T00:00:00');
  weekEndDate.setDate(weekEndDate.getDate() + 6);
  const weekLabel = `${weekStartDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} – ${weekEndDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`;

  return (
    <DndProvider backend={HTML5Backend}>
      <Layout>
        {/* Header */}
        <div className="relative px-8 py-8 overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
          <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
          <div className="relative z-10">
            <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">
              Weekly Planner ✨
            </h1>
            <p className="text-white/90 text-[15px] font-medium">
              Drag and drop to schedule your runs
            </p>
          </div>
        </div>

        <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
          {/* Week Navigation */}
          <div className="backdrop-blur-xl bg-white/60 rounded-[24px] px-5 py-3 border border-white/80 shadow-lg flex items-center justify-between">
            <button
              onClick={goToPrevWeek}
              className="p-2 rounded-xl backdrop-blur-md bg-white/50 border border-white/70 hover:bg-white/80 hover:scale-105 transition-all"
            >
              <svg className="w-5 h-5 text-slate-700" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <div className="text-center">
              <p className="text-[11px] text-slate-500 font-semibold uppercase tracking-wider">Week of</p>
              <p className="text-[14px] font-bold text-slate-800">{weekLabel}</p>
            </div>
            <button
              onClick={goToNextWeek}
              className="p-2 rounded-xl backdrop-blur-md bg-white/50 border border-white/70 hover:bg-white/80 hover:scale-105 transition-all"
            >
              <svg className="w-5 h-5 text-slate-700" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>

          {/* Calendar Grid */}
          <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
            {/* Day Headers */}
            <div className="flex gap-[34px] justify-center mb-4">
              {dayLabels.map((day, i) => (
                <div key={i} className="w-[40px] text-center">
                  <span className="font-bold text-[14px] text-slate-700/90">{day}</span>
                </div>
              ))}
            </div>

            {/* AM/PM Rows */}
            <div className="space-y-4">
              {(['AM', 'PM'] as const).map((time) => (
                <div key={time} className="flex items-center gap-3">
                  <div className="w-[30px] text-[12px] text-slate-600/80 font-semibold">{time}</div>
                  <div className="flex gap-[34px]">
                    {dayLabels.map((_, dayIdx) => (
                      <CalendarCell
                        key={`${dayIdx}-${time}`}
                        day={dayIdx}
                        time={time}
                        scheduledRun={scheduledRuns.find(r => r.day === dayIdx && r.time === time)}
                        onDrop={handleDrop}
                        onRemove={handleRemove}
                        onMove={handleMove}
                      />
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {/* Toggle row — show expand button beneath days that have runs */}
            <div className="flex items-center gap-3 mt-3">
              <div className="w-[30px]" />
              <div className="flex gap-[34px]">
                {dayLabels.map((_, dayIdx) => {
                  const dayRuns = scheduledRuns.filter(r => r.day === dayIdx);
                  return (
                    <div key={dayIdx} className="w-[40px] flex justify-center">
                      {dayRuns.length > 0 ? (
                        <button
                          onClick={() => toggleDay(dayIdx)}
                          className={`w-6 h-6 rounded-full flex items-center justify-center text-[10px] transition-all hover:scale-110 ${
                            expandedDays.has(dayIdx)
                              ? 'bg-gradient-to-br from-slate-700 to-blue-900 text-white shadow-md'
                              : 'bg-white/60 border border-white/70 text-slate-500 hover:bg-white/80'
                          }`}
                          title={`${expandedDays.has(dayIdx) ? 'Hide' : 'Set'} distance for ${dayNames[dayIdx]}`}
                        >
                          {expandedDays.has(dayIdx) ? '▲' : '▼'}
                        </button>
                      ) : (
                        <div className="w-6 h-6" />
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            <p className="text-[11px] text-slate-500/80 text-center mt-3 font-medium">
              💡 Drag to add • Drag to move • Double-click to remove • ▼ to set distance
            </p>
          </div>

          {/* Distance Sliders (shown for expanded days) */}
          {dayLabels.map((_, dayIdx) => {
            if (!expandedDays.has(dayIdx)) return null;
            const dayRuns = scheduledRuns.filter(r => r.day === dayIdx);
            if (dayRuns.length === 0) return null;

            return (
              <div key={dayIdx} className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
                <h3 className="font-bold text-[14px] text-slate-800 mb-4 flex items-center gap-2">
                  <span className="text-lg">📏</span>
                  {dayNames[dayIdx]} — Set Planned Distance
                </h3>
                <div className="space-y-4">
                  {dayRuns.map(run => {
                    const runInfo = runTypes.find(rt => rt.type === run.type)!;
                    const dist = run.distanceMiles ?? 0;
                    return (
                      <div key={run.id}>
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-[13px] font-semibold text-slate-700">
                            {run.time} · {runInfo.label}
                          </span>
                          <span
                            className="text-[13px] font-bold"
                            style={{ color: runInfo.vibrant }}
                          >
                            {dist.toFixed(1)} mi
                          </span>
                        </div>
                        <Slider
                          value={[dist]}
                          onValueChange={([v]) => handleDistanceChange(run.id, v)}
                          min={0}
                          max={26.2}
                          step={0.1}
                          className="w-full"
                        />
                        <div className="flex justify-between text-[10px] text-slate-400 mt-1">
                          <span>0 mi</span>
                          <span>26.2 mi</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}

          {/* Run Type Picker */}
          <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
            <h3 className="font-semibold text-[13px] text-slate-700/90 mb-4 text-center tracking-wide uppercase">
              Run Types
            </h3>
            <div className="flex justify-center gap-6">
              {runTypes.map(({ type, label, color, vibrant }) => (
                <DraggableRunType key={type} type={type} label={label} color={color} vibrant={vibrant} />
              ))}
            </div>
          </div>

          {/* Stats This Week */}
          <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
            <h3 className="font-bold text-[15px] text-slate-800 mb-4 flex items-center gap-2">
              <span className="text-lg">📊</span>
              <span className="bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
                This Week
              </span>
            </h3>

            {/* Run type counts */}
            <div className="grid grid-cols-4 gap-2 mb-4">
              <StatPill label="Easy"  value={stats.easy}    color="from-sky-400 to-blue-500" />
              <StatPill label="Tempo" value={stats.tempo}   color="from-amber-400 to-orange-500" />
              <StatPill label="Race"  value={stats.race}    color="from-purple-400 to-fuchsia-500" />
              <StatPill label="Long"  value={stats.longRun} color="from-emerald-400 to-green-500" />
            </div>

            {/* Load & Intensity */}
            <div className="space-y-2 mb-4">
              <MetricBar label="Relative Load"       value={relativeLoad}      isHigh={relativeLoad > 30} />
              <MetricBar label="Training Intensity"  value={trainingIntensity} isHigh={trainingIntensity > 20} />
            </div>

            {/* Planned vs Actual mileage */}
            <div className="grid grid-cols-2 gap-3">
              <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70">
                <p className="text-[10px] text-slate-600 font-semibold uppercase tracking-wider mb-1">Planned Miles</p>
                <p className="text-xl font-bold bg-gradient-to-br from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
                  {plannedMiles.toFixed(1)}
                </p>
              </div>
              <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70">
                <p className="text-[10px] text-slate-600 font-semibold uppercase tracking-wider mb-1">Actual Miles</p>
                <p className="text-xl font-bold bg-gradient-to-br from-emerald-500 to-green-600 bg-clip-text text-transparent">
                  {actualMiles.toFixed(1)}
                </p>
              </div>
            </div>
          </div>

          {/* Visualizations */}
          <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg space-y-4">
            <h3 className="font-bold text-[15px] text-slate-800 flex items-center gap-2">
              <span className="text-lg">📈</span> Mileage — Planned vs Actual
            </h3>
            <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
              <ResponsiveContainer width="100%" height={120}>
                <BarChart data={combinedChartData} barCategoryGap="20%">
                  <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
                  <Bar dataKey="planned" name="Planned" fill="#a855f7" radius={[4, 4, 0, 0]} opacity={0.5} />
                  <Bar dataKey="actual"  name="Actual"  fill="#10b981" radius={[4, 4, 0, 0]} />
                  <defs />
                </BarChart>
              </ResponsiveContainer>
              <div className="flex gap-4 justify-center mt-2">
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-purple-400 opacity-70" />
                  <span className="text-[10px] text-slate-600 font-medium">Planned</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-emerald-500" />
                  <span className="text-[10px] text-slate-600 font-medium">Actual</span>
                </div>
              </div>
            </div>

            <h3 className="font-bold text-[15px] text-slate-800 flex items-center gap-2">
              <span className="text-lg">⚡</span> Pace Trend This Week
            </h3>
            <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
              <ResponsiveContainer width="100%" height={100}>
                <LineChart data={activityChartData}>
                  <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
                  <Line
                    type="monotone"
                    dataKey="pace"
                    stroke="#f97316"
                    strokeWidth={3}
                    dot={{ fill: '#f97316', r: 4 }}
                    connectNulls
                  />
                </LineChart>
              </ResponsiveContainer>
              <p className="text-[10px] text-slate-500 text-center mt-1">min/mi (lower = faster)</p>
            </div>
          </div>
        </div>
      </Layout>
    </DndProvider>
  );
}

function StatPill({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 shadow-md hover:scale-105 transition-transform">
      <p className="text-[10px] text-slate-600/80 font-semibold uppercase tracking-wider mb-1">{label}</p>
      <p className={`text-2xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>{value}</p>
    </div>
  );
}

function MetricBar({ label, value, isHigh }: { label: string; value: number; isHigh: boolean }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl px-4 py-3 border border-white/60 shadow-sm">
      <div className="flex items-center justify-between">
        <span className="text-[13px] text-slate-700 font-medium">{label}</span>
        <span className={`font-bold text-lg bg-gradient-to-r ${
          isHigh ? 'from-orange-500 to-red-500' : 'from-emerald-500 to-green-500'
        } bg-clip-text text-transparent`}>
          {value > 0 ? '+' : ''}{value}
        </span>
      </div>
      <div className="mt-2 h-1 bg-slate-200/50 rounded-full overflow-hidden">
        <div
          className={`h-full bg-gradient-to-r ${
            isHigh ? 'from-orange-400 to-red-500' : 'from-emerald-400 to-green-500'
          } rounded-full transition-all duration-500`}
          style={{ width: `${Math.min(Math.abs(value) * 2, 100)}%` }}
        />
      </div>
    </div>
  );
}
