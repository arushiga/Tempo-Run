import { useState } from 'react';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import svgPaths from '../../imports/svg-sq11q5zcmr';
import { DraggableRunType } from './DraggableRunType';
import { CalendarCell } from './CalendarCell';
import { Layout } from './Layout';

export type RunType = 'easy' | 'tempo' | 'race' | 'longRun';

export interface Run {
  type: RunType;
  id: string;
}

export interface ScheduledRun extends Run {
  day: number;
  time: 'AM' | 'PM';
}

const runTypes: { type: RunType; label: string; color: string; vibrant: string }[] = [
  { type: 'easy', label: 'Easy', color: '#7DD3FC', vibrant: '#0EA5E9' },
  { type: 'tempo', label: 'Tempo', color: '#FDBA74', vibrant: '#F97316' },
  { type: 'race', label: 'Race', color: '#C084FC', vibrant: '#A855F7' },
  { type: 'longRun', label: 'Long Run', color: '#6EE7B7', vibrant: '#10B981' },
];

const days = ['M', 'T', 'W', 'R', 'F', 'S', 'S'];

export default function RunPlanner() {
  const [scheduledRuns, setScheduledRuns] = useState<ScheduledRun[]>([
    { type: 'easy', id: '1', day: 0, time: 'AM' },
    { type: 'tempo', id: '2', day: 1, time: 'PM' },
  ]);

  const handleDrop = (runType: RunType, day: number, time: 'AM' | 'PM') => {
    console.log('handleDrop called:', { runType, day, time, currentRuns: scheduledRuns.length });
    
    // Check if there's already a run in this slot
    const existingRunIndex = scheduledRuns.findIndex(
      run => run.day === day && run.time === time
    );
    
    const newRun: ScheduledRun = {
      type: runType,
      id: Date.now().toString(),
      day,
      time,
    };
    
    if (existingRunIndex !== -1) {
      // Replace the existing run
      const updatedRuns = [...scheduledRuns];
      updatedRuns[existingRunIndex] = newRun;
      setScheduledRuns(updatedRuns);
      console.log('Replaced run at index', existingRunIndex);
    } else {
      // Add new run to empty slot
      setScheduledRuns([...scheduledRuns, newRun]);
      console.log('Added new run, total:', scheduledRuns.length + 1);
    }
  };

  const handleRemove = (id: string) => {
    setScheduledRuns(scheduledRuns.filter(run => run.id !== id));
  };

  const handleMove = (id: string, day: number, time: 'AM' | 'PM') => {
    console.log('handleMove called:', { id, day, time });
    
    // Check if target slot is occupied by a different run
    const targetRun = scheduledRuns.find(
      run => run.day === day && run.time === time && run.id !== id
    );
    
    if (targetRun) {
      // Remove the run at the target location and move our run there
      setScheduledRuns(
        scheduledRuns
          .filter(run => run.id !== targetRun.id)
          .map(run => run.id === id ? { ...run, day, time } : run)
      );
      console.log('Moved run and removed target run');
    } else {
      // Just move the run
      setScheduledRuns(
        scheduledRuns.map(run =>
          run.id === id ? { ...run, day, time } : run
        )
      );
      console.log('Moved run to empty slot');
    }
  };

  // Calculate statistics
  const stats = {
    easy: scheduledRuns.filter(r => r.type === 'easy').length,
    tempo: scheduledRuns.filter(r => r.type === 'tempo').length,
    race: scheduledRuns.filter(r => r.type === 'race').length,
    longRun: scheduledRuns.filter(r => r.type === 'longRun').length,
  };

  const totalRuns = scheduledRuns.length;
  const relativeLoad = 43 - (7 - totalRuns) * 5;
  const trainingIntensity = 15 + (stats.tempo * 5) + (stats.race * 10);

  return (
    <DndProvider backend={HTML5Backend}>
      {/* Animated gradient mesh background */}
      <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-violet-100 via-sky-50 to-amber-50">
        {/* Animated gradient orbs */}
        <div className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-br from-violet-300/30 to-purple-400/20 rounded-full blur-3xl animate-pulse" style={{ animationDuration: '4s' }} />
        <div className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-to-br from-sky-300/30 to-blue-400/20 rounded-full blur-3xl animate-pulse" style={{ animationDuration: '5s', animationDelay: '1s' }} />
        <div className="absolute top-1/3 right-1/4 w-72 h-72 bg-gradient-to-br from-amber-300/20 to-orange-400/15 rounded-full blur-3xl animate-pulse" style={{ animationDuration: '6s', animationDelay: '2s' }} />
        
        <div className="relative flex items-center justify-center min-h-screen p-6">
          <div className="max-w-[520px] w-full">
            {/* Main Card with Glassmorphism */}
            <div className="backdrop-blur-2xl bg-white/40 rounded-[32px] shadow-2xl border border-white/60 overflow-hidden">
              {/* Header with gradient */}
              <div className="relative px-8 py-8 overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-violet-500/90 via-purple-500/90 to-fuchsia-500/90" />
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

              <div className="px-6 py-6 space-y-6">
                {/* Calendar Grid */}
                <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-6 border border-white/80 shadow-lg">
                  {/* Day Headers */}
                  <div className="flex gap-[40px] justify-center mb-5">
                    {days.map((day, i) => (
                      <div key={i} className="w-[44px] text-center">
                        <span className="font-bold text-[15px] text-slate-700/90">
                          {day}
                        </span>
                      </div>
                    ))}
                  </div>

                  {/* Time Rows */}
                  <div className="space-y-5">
                    {['AM', 'PM'].map((time) => (
                      <div key={time} className="flex items-center gap-4">
                        <div className="w-[36px] text-[13px] text-slate-600/80 font-semibold">
                          {time}
                        </div>
                        <div className="flex gap-[40px]">
                          {days.map((_, dayIdx) => (
                            <CalendarCell
                              key={`${dayIdx}-${time}`}
                              day={dayIdx}
                              time={time as 'AM' | 'PM'}
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

                  {/* Helper Text */}
                  <p className="text-[12px] text-slate-500/80 text-center mt-5 font-medium">
                    💡 Drag to move • Double-click to remove
                  </p>
                </div>

                {/* Run Type Picker - Glassmorphism Pills */}
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

                {/* Statistics - Compact Glass Cards */}
                <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
                  <h3 className="font-bold text-[15px] text-slate-800 mb-4 flex items-center gap-2">
                    <span className="text-lg">📊</span> 
                    <span className="bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
                      This Week
                    </span>
                  </h3>
                  
                  {/* Stat Pills */}
                  <div className="grid grid-cols-4 gap-2 mb-4">
                    <StatPill label="Easy" value={stats.easy} color="from-sky-400 to-blue-500" />
                    <StatPill label="Tempo" value={stats.tempo} color="from-amber-400 to-orange-500" />
                    <StatPill label="Race" value={stats.race} color="from-purple-400 to-fuchsia-500" />
                    <StatPill label="Long" value={stats.longRun} color="from-emerald-400 to-green-500" />
                  </div>

                  {/* Metrics */}
                  <div className="space-y-2">
                    <MetricBar
                      label="Load"
                      value={relativeLoad}
                      isHigh={relativeLoad > 30}
                    />
                    <MetricBar
                      label="Intensity"
                      value={trainingIntensity}
                      isHigh={trainingIntensity > 20}
                    />
                  </div>
                </div>
              </div>

              {/* Bottom Navigation */}
              <div className="flex justify-around py-4 px-6 border-t border-white/40 backdrop-blur-xl bg-white/30">
                <NavButton icon={<HomeIcon />} />
                <NavButton icon={<CalendarIcon />} active />
                <NavButton icon={<CircleIcon />} />
                <NavButton icon={<ActivityIcon />} />
                <NavButton icon={<MapIcon />} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </DndProvider>
  );
}

function StatPill({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 shadow-md hover:scale-105 transition-transform">
      <p className="text-[10px] text-slate-600/80 font-semibold uppercase tracking-wider mb-1">
        {label}
      </p>
      <p className={`text-2xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>
        {value}
      </p>
    </div>
  );
}

function MetricBar({ label, value, isHigh }: { label: string; value: number; isHigh: boolean }) {
  return (
    <div className={`backdrop-blur-md bg-white/50 rounded-2xl px-4 py-3 border border-white/60 shadow-sm hover:shadow-md transition-all`}>
      <div className="flex items-center justify-between">
        <span className="text-[13px] text-slate-700 font-medium">{label}</span>
        <span className={`font-bold text-lg bg-gradient-to-r ${
          isHigh 
            ? 'from-orange-500 to-red-500' 
            : 'from-emerald-500 to-green-500'
        } bg-clip-text text-transparent`}>
          {value > 0 ? '+' : ''}{value}
        </span>
      </div>
      {/* Progress bar */}
      <div className="mt-2 h-1 bg-slate-200/50 rounded-full overflow-hidden">
        <div 
          className={`h-full bg-gradient-to-r ${
            isHigh 
              ? 'from-orange-400 to-red-500' 
              : 'from-emerald-400 to-green-500'
          } rounded-full transition-all duration-500`}
          style={{ width: `${Math.min(Math.abs(value) * 2, 100)}%` }}
        />
      </div>
    </div>
  );
}

function NavButton({ icon, active = false }: { icon: React.ReactNode; active?: boolean }) {
  return (
    <button
      className={`p-3 rounded-2xl transition-all duration-300 ${
        active
          ? 'bg-gradient-to-br from-violet-500 to-fuchsia-500 text-white shadow-xl shadow-violet-500/30 scale-110'
          : 'text-slate-400 hover:bg-white/60 hover:text-slate-700 hover:scale-105 backdrop-blur-sm'
      }`}
    >
      {icon}
    </button>
  );
}

// Navigation Icons
function HomeIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
      <polyline points="9 22 9 12 15 12 15 22" />
    </svg>
  );
}

function CalendarIcon({ active = false }: { active?: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#ff5100' : 'currentColor'} strokeWidth="2">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
    </svg>
  );
}

function CircleIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
    </svg>
  );
}

function ActivityIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
    </svg>
  );
}

function MapIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6" />
      <line x1="8" y1="2" x2="8" y2="18" />
      <line x1="16" y1="6" x2="16" y2="22" />
    </svg>
  );
}