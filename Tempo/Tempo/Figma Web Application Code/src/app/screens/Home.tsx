import { Layout } from '../components/Layout';
import { Link } from 'react-router';
import { TrendingUp, Target, Award, Zap } from 'lucide-react';

export default function Home() {
  const currentWeek = {
    totalRuns: 5,
    totalDistance: 28.5,
    totalTime: '4h 15m',
    avgPace: '8:58',
  };

  const upcomingRuns = [
    { day: 'Today', type: 'Easy Run', distance: '5K', time: '6:00 AM', color: 'from-blue-500 to-blue-700' },
    { day: 'Tomorrow', type: 'Tempo Run', distance: '8K', time: '6:30 AM', color: 'from-slate-600 to-slate-800' },
    { day: 'Friday', type: 'Long Run', distance: '15K', time: '7:00 AM', color: 'from-emerald-500 to-green-600' },
  ];

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-2">
            <div>
              <p className="text-white/80 text-sm font-medium mb-1">Welcome back!</p>
              <h1 className="font-bold text-[32px] text-white tracking-tight">
                Dashboard 🏃
              </h1>
            </div>
            <div className="backdrop-blur-md bg-white/20 rounded-2xl px-4 py-2 border border-white/30">
              <p className="text-white/80 text-xs font-medium">Week 12</p>
              <p className="text-white text-sm font-bold">Apr 2026</p>
            </div>
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5">
        {/* This Week Stats */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-blue-700" />
            This Week's Progress
          </h2>
          
          <div className="grid grid-cols-2 gap-3">
            <StatBox label="Total Runs" value={currentWeek.totalRuns.toString()} icon="🏃" color="from-slate-700 to-slate-900" />
            <StatBox label="Distance" value={`${currentWeek.totalDistance}km`} icon="📏" color="from-blue-600 to-blue-800" />
            <StatBox label="Time" value={currentWeek.totalTime} icon="⏱️" color="from-slate-600 to-blue-900" />
            <StatBox label="Avg Pace" value={`${currentWeek.avgPace}/km`} icon="⚡" color="from-emerald-500 to-green-600" />
          </div>
        </div>

        {/* Quick Goals */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Target className="w-5 h-5 text-emerald-600" />
            Current Goals
          </h2>
          
          <div className="space-y-3">
            <GoalProgress label="Weekly Distance" current={28.5} goal={35} unit="km" color="from-blue-500 to-blue-700" />
            <GoalProgress label="Long Run Build" current={15} goal={21} unit="km" color="from-emerald-500 to-green-600" />
            <GoalProgress label="Speed Work" current={3} goal={4} unit="sessions" color="from-slate-600 to-slate-800" />
          </div>
        </div>

        {/* Upcoming Runs */}
        <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-bold text-[16px] text-slate-800 flex items-center gap-2">
              <Zap className="w-5 h-5 text-emerald-600" />
              Upcoming Runs
            </h2>
            <Link 
              to="/calendar" 
              className="text-xs font-semibold text-blue-700 hover:text-slate-800 transition-colors"
            >
              View All →
            </Link>
          </div>
          
          <div className="space-y-2">
            {upcomingRuns.map((run, idx) => (
              <UpcomingRunCard key={idx} {...run} />
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3">
          <Link to="/calendar">
            <QuickActionButton 
              label="Plan Week" 
              icon="📅" 
              color="from-slate-700 to-blue-900"
            />
          </Link>
          <Link to="/record">
            <QuickActionButton 
              label="Record Run" 
              icon="⏺️" 
              color="from-emerald-500 to-green-600"
            />
          </Link>
        </div>
      </div>
    </Layout>
  );
}

function StatBox({ label, value, icon, color }: { label: string; value: string; icon: string; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/70 shadow-md hover:scale-105 transition-transform">
      <div className="flex items-center gap-2 mb-2">
        <span className="text-xl">{icon}</span>
        <p className="text-[11px] text-slate-600 font-semibold uppercase tracking-wider">
          {label}
        </p>
      </div>
      <p className={`text-2xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>
        {value}
      </p>
    </div>
  );
}

function GoalProgress({ label, current, goal, unit, color }: { label: string; current: number; goal: number; unit: string; color: string }) {
  const percentage = (current / goal) * 100;
  
  return (
    <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <span className="text-[13px] text-slate-700 font-medium">{label}</span>
        <span className="text-[12px] text-slate-600 font-semibold">
          {current}/{goal} {unit}
        </span>
      </div>
      <div className="h-2 bg-slate-200/50 rounded-full overflow-hidden">
        <div 
          className={`h-full bg-gradient-to-r ${color} rounded-full transition-all duration-500`}
          style={{ width: `${Math.min(percentage, 100)}%` }}
        />
      </div>
    </div>
  );
}

function UpcomingRunCard({ day, type, distance, time, color }: { day: string; type: string; distance: string; time: string; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm hover:shadow-md hover:scale-[1.02] transition-all">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${color} flex items-center justify-center shadow-md`}>
            <span className="text-white font-bold text-sm">{distance}</span>
          </div>
          <div>
            <p className="text-[13px] font-bold text-slate-800">{type}</p>
            <p className="text-[11px] text-slate-600">{day} • {time}</p>
          </div>
        </div>
        <svg className="w-5 h-5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </div>
  );
}

function QuickActionButton({ label, icon, color }: { label: string; icon: string; color: string }) {
  return (
    <button className={`w-full backdrop-blur-xl bg-gradient-to-br ${color} rounded-2xl p-4 border border-white/30 shadow-lg hover:shadow-xl hover:scale-105 transition-all`}>
      <span className="text-3xl mb-2 block">{icon}</span>
      <p className="text-white font-bold text-[14px]">{label}</p>
    </button>
  );
}