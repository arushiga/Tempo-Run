import { Layout } from '../components/Layout';
import { useState } from 'react';
import { BarChart3, TrendingUp, Calendar, Clock } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, LineChart, Line, Area, AreaChart } from 'recharts';

type TimeView = '3day' | 'weekly' | 'monthly';

export default function Activity() {
  const [timeView, setTimeView] = useState<TimeView>('weekly');

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        
        <div className="relative z-10">
          <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">
            Activity 📊
          </h1>
          <p className="text-white/90 text-[15px] font-medium">
            Detailed stats and analytics
          </p>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* Time View Tabs */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-2 border border-white/80 shadow-lg flex gap-2">
          <TabButton 
            label="3 Days" 
            active={timeView === '3day'} 
            onClick={() => setTimeView('3day')} 
          />
          <TabButton 
            label="Weekly" 
            active={timeView === 'weekly'} 
            onClick={() => setTimeView('weekly')} 
          />
          <TabButton 
            label="Monthly" 
            active={timeView === 'monthly'} 
            onClick={() => setTimeView('monthly')} 
          />
        </div>

        {/* Render different views based on selected tab */}
        {timeView === '3day' && <ThreeDayView />}
        {timeView === 'weekly' && <WeeklyView />}
        {timeView === 'monthly' && <MonthlyView />}
      </div>
    </Layout>
  );
}

function TabButton({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className={`flex-1 py-2.5 rounded-2xl font-semibold text-[13px] transition-all ${
        active
          ? 'bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white shadow-md'
          : 'text-slate-600 hover:bg-white/50'
      }`}
    >
      {label}
    </button>
  );
}

function ThreeDayView() {
  const data = [
    { day: 'Wed', distance: 6, pace: 9.0, time: 54, calories: 360 },
    { day: 'Thu', distance: 0, pace: 0, time: 0, calories: 0 },
    { day: 'Fri', distance: 8, pace: 8.5, time: 68, calories: 480 },
  ];

  const detailedRuns = [
    {
      date: 'Apr 2 (Fri)',
      type: 'Tempo',
      distance: '8.0km',
      time: '42:20',
      pace: '5:17/km',
      calories: 468,
      heartRate: '162 bpm',
      elevation: '+45m',
      splits: ['5:22', '5:18', '5:15', '5:12', '5:20', '5:15', '5:18', '5:20']
    },
    {
      date: 'Apr 1 (Thu)',
      type: 'Rest',
      distance: '0km',
      time: '-',
      pace: '-',
      calories: 0,
      heartRate: '-',
      elevation: '-',
      splits: []
    },
    {
      date: 'Mar 31 (Wed)',
      type: 'Easy',
      distance: '6.0km',
      time: '32:15',
      pace: '5:22/km',
      calories: 358,
      heartRate: '142 bpm',
      elevation: '+22m',
      splits: ['5:28', '5:24', '5:20', '5:18', '5:22', '5:23']
    },
  ];

  return (
    <>
      {/* Summary Stats */}
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-violet-600" />
          Last 3 Days
        </h2>
        
        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Runs" value="2" color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance" value="14km" color="from-sky-400 to-blue-500" />
          <QuickStat label="Avg Pace" value="8:45/km" color="from-amber-400 to-orange-500" />
        </div>

        {/* 3 Day Chart */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Daily Distance (km)</p>
          <ResponsiveContainer width="100%" height={120}>
            <BarChart data={data}>
              <XAxis 
                dataKey="day" 
                axisLine={false}
                tickLine={false}
                tick={{ fontSize: 11, fill: '#64748b' }}
              />
              <Bar 
                dataKey="distance" 
                fill="url(#colorDistance)" 
                radius={[8, 8, 0, 0]}
              />
              <defs>
                <linearGradient id="colorDistance" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#a855f7" />
                  <stop offset="100%" stopColor="#8b5cf6" />
                </linearGradient>
              </defs>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Detailed Run Logs */}
      {detailedRuns.map((run, idx) => (
        <DetailedRunCard key={idx} {...run} />
      ))}
    </>
  );
}

function WeeklyView() {
  const weeklyData = [
    { day: 'Mon', distance: 5, pace: 9.2 },
    { day: 'Tue', distance: 8, pace: 8.5 },
    { day: 'Wed', distance: 0, pace: 0 },
    { day: 'Thu', distance: 6, pace: 9.0 },
    { day: 'Fri', distance: 10, pace: 8.8 },
    { day: 'Sat', distance: 15, pace: 9.5 },
    { day: 'Sun', distance: 5, pace: 9.3 },
  ];

  const recentRuns = [
    { date: 'Apr 2', type: 'Easy', distance: '5.2km', time: '28:45', pace: '5:32/km', calories: 312 },
    { date: 'Apr 1', type: 'Tempo', distance: '8.0km', time: '42:20', pace: '5:17/km', calories: 468 },
    { date: 'Mar 31', type: 'Long', distance: '15.0km', time: '1:28:30', pace: '5:54/km', calories: 890 },
    { date: 'Mar 30', type: 'Easy', distance: '6.0km', time: '32:15', pace: '5:22/km', calories: 358 },
  ];

  return (
    <>
      {/* Week Summary */}
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-violet-600" />
          This Week
        </h2>
        
        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Runs" value="5" color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance" value="49km" color="from-sky-400 to-blue-500" />
          <QuickStat label="Time" value="4h 12m" color="from-amber-400 to-orange-500" />
        </div>

        {/* Weekly Distance Chart */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Daily Distance (km)</p>
          <ResponsiveContainer width="100%" height={120}>
            <BarChart data={weeklyData}>
              <XAxis 
                dataKey="day" 
                axisLine={false}
                tickLine={false}
                tick={{ fontSize: 11, fill: '#64748b' }}
              />
              <Bar 
                dataKey="distance" 
                fill="url(#colorDistance)" 
                radius={[8, 8, 0, 0]}
              />
              <defs>
                <linearGradient id="colorDistance" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#a855f7" />
                  <stop offset="100%" stopColor="#8b5cf6" />
                </linearGradient>
              </defs>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Runs */}
      <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Clock className="w-5 h-5 text-fuchsia-600" />
          Recent Runs
        </h2>
        
        <div className="space-y-2">
          {recentRuns.map((run, idx) => (
            <RunHistoryCard key={idx} {...run} />
          ))}
        </div>
      </div>

      {/* Personal Records */}
      <div className="backdrop-blur-xl bg-gradient-to-br from-amber-500/20 to-orange-500/20 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <span className="text-xl">🏆</span>
          Personal Records
        </h2>
        
        <div className="grid grid-cols-2 gap-3">
          <PRCard label="Fastest 5K" value="22:15" />
          <PRCard label="Fastest 10K" value="48:32" />
          <PRCard label="Longest Run" value="18.0 km" />
          <PRCard label="Best Pace" value="4:27/km" />
        </div>
      </div>
    </>
  );
}

function MonthlyView() {
  const monthlyData = [
    { week: 'W1', distance: 28, runs: 4 },
    { week: 'W2', distance: 32, runs: 5 },
    { week: 'W3', distance: 25, runs: 4 },
    { week: 'W4', distance: 35, runs: 6 },
  ];

  const paceData = [
    { week: 'W1', pace: 9.2 },
    { week: 'W2', pace: 9.0 },
    { week: 'W3', pace: 8.8 },
    { week: 'W4', pace: 8.7 },
  ];

  const weeklyBreakdown = [
    { week: 'Week 1', dates: 'Mar 3-9', runs: 4, distance: '28km', time: '4h 18m' },
    { week: 'Week 2', dates: 'Mar 10-16', runs: 5, distance: '32km', time: '4h 48m' },
    { week: 'Week 3', dates: 'Mar 17-23', runs: 4, distance: '25km', time: '3h 45m' },
    { week: 'Week 4', dates: 'Mar 24-30', runs: 6, distance: '35km', time: '5h 15m' },
  ];

  return (
    <>
      {/* Monthly Summary */}
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <TrendingUp className="w-5 h-5 text-violet-600" />
          March 2026
        </h2>
        
        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Total Runs" value="19" color="from-violet-400 to-purple-500" />
          <QuickStat label="Total Distance" value="120km" color="from-sky-400 to-blue-500" />
          <QuickStat label="Avg Pace" value="8:56/km" color="from-amber-400 to-orange-500" />
        </div>

        {/* Monthly Distance Trend */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 mb-3">
          <p className="text-xs font-semibold text-slate-700 mb-3">Weekly Distance Progress</p>
          <ResponsiveContainer width="100%" height={100}>
            <AreaChart data={monthlyData}>
              <defs>
                <linearGradient id="colorArea" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#0ea5e9" stopOpacity={0.3} />
                  <stop offset="100%" stopColor="#0ea5e9" stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <XAxis 
                dataKey="week" 
                axisLine={false}
                tickLine={false}
                tick={{ fontSize: 11, fill: '#64748b' }}
              />
              <Area 
                type="monotone" 
                dataKey="distance" 
                stroke="#0ea5e9" 
                strokeWidth={2.5}
                fill="url(#colorArea)" 
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Pace Improvement */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Average Pace Trend</p>
          <ResponsiveContainer width="100%" height={100}>
            <LineChart data={paceData}>
              <XAxis 
                dataKey="week" 
                axisLine={false}
                tickLine={false}
                tick={{ fontSize: 11, fill: '#64748b' }}
              />
              <Line 
                type="monotone" 
                dataKey="pace" 
                stroke="#f97316" 
                strokeWidth={3}
                dot={{ fill: '#f97316', r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Weekly Breakdown */}
      <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <BarChart3 className="w-5 h-5 text-fuchsia-600" />
          Weekly Breakdown
        </h2>
        
        <div className="space-y-2">
          {weeklyBreakdown.map((week, idx) => (
            <WeeklyBreakdownCard key={idx} {...week} />
          ))}
        </div>
      </div>

      {/* Monthly Achievements */}
      <div className="backdrop-blur-xl bg-gradient-to-br from-violet-500/20 to-fuchsia-500/20 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <span className="text-xl">🎯</span>
          Monthly Highlights
        </h2>
        
        <div className="space-y-2">
          <HighlightRow icon="🏆" label="New PR: 10K" value="48:32" />
          <HighlightRow icon="🔥" label="Longest Streak" value="12 days" />
          <HighlightRow icon="📈" label="Pace Improvement" value="-15 sec/km" />
          <HighlightRow icon="⚡" label="Most Active Week" value="Week 4" />
        </div>
      </div>
    </>
  );
}

function QuickStat({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70 shadow-sm">
      <p className="text-[10px] text-slate-600 font-semibold uppercase tracking-wider mb-1">
        {label}
      </p>
      <p className={`text-xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>
        {value}
      </p>
    </div>
  );
}

function RunHistoryCard({ date, type, distance, time, pace, calories }: { 
  date: string; 
  type: string; 
  distance: string; 
  time: string; 
  pace: string; 
  calories: number;
}) {
  const typeColors: Record<string, string> = {
    Easy: 'from-sky-400 to-blue-500',
    Tempo: 'from-amber-400 to-orange-500',
    Long: 'from-emerald-400 to-green-500',
    Race: 'from-fuchsia-400 to-pink-500',
  };

  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <div className={`px-2 py-1 rounded-lg bg-gradient-to-r ${typeColors[type]} text-white text-[10px] font-bold`}>
            {type}
          </div>
          <span className="text-[11px] text-slate-600 font-medium">{date}</span>
        </div>
        <span className="text-[10px] text-slate-500">{calories} cal</span>
      </div>
      
      <div className="grid grid-cols-3 gap-2">
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Distance</p>
          <p className="text-sm font-bold text-slate-800">{distance}</p>
        </div>
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Time</p>
          <p className="text-sm font-bold text-slate-800">{time}</p>
        </div>
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Pace</p>
          <p className="text-sm font-bold text-slate-800">{pace}</p>
        </div>
      </div>
    </div>
  );
}

function PRCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/60 rounded-2xl p-3 border border-white/70 shadow-sm">
      <p className="text-[10px] text-slate-600 font-semibold mb-1">{label}</p>
      <p className="text-lg font-bold bg-gradient-to-r from-amber-600 to-orange-600 bg-clip-text text-transparent">
        {value}
      </p>
    </div>
  );
}

function DetailedRunCard({ date, type, distance, time, pace, calories, heartRate, elevation, splits }: {
  date: string;
  type: string;
  distance: string;
  time: string;
  pace: string;
  calories: number;
  heartRate: string;
  elevation: string;
  splits: string[];
}) {
  const typeColors: Record<string, string> = {
    Easy: 'from-sky-400 to-blue-500',
    Tempo: 'from-amber-400 to-orange-500',
    Long: 'from-emerald-400 to-green-500',
    Rest: 'from-slate-400 to-slate-500',
  };

  if (type === 'Rest') {
    return (
      <div className="backdrop-blur-xl bg-gradient-to-br from-slate-200/50 to-slate-300/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <div className="flex items-center gap-3">
          <div className="w-16 h-16 rounded-full bg-gradient-to-br from-slate-400 to-slate-500 flex items-center justify-center shadow-md">
            <span className="text-3xl">😴</span>
          </div>
          <div>
            <h3 className="font-bold text-[16px] text-slate-800">{date}</h3>
            <p className="text-[13px] text-slate-600">Rest Day - Recovery</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-bold text-[16px] text-slate-800 mb-1">{date}</h3>
          <div className={`inline-block px-3 py-1 rounded-lg bg-gradient-to-r ${typeColors[type]} text-white text-[11px] font-bold`}>
            {type} Run
          </div>
        </div>
        <div className="text-right">
          <p className="text-2xl font-bold bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
            {distance}
          </p>
          <p className="text-[11px] text-slate-600">{time}</p>
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-4 gap-2 mb-4">
        <MetricBox label="Pace" value={pace} />
        <MetricBox label="Calories" value={calories.toString()} />
        <MetricBox label="Heart Rate" value={heartRate} />
        <MetricBox label="Elevation" value={elevation} />
      </div>

      {/* Splits */}
      {splits.length > 0 && (
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-2">Kilometer Splits</p>
          <div className="flex gap-2 overflow-x-auto">
            {splits.map((split, idx) => (
              <div key={idx} className="flex-shrink-0 backdrop-blur-sm bg-white/60 rounded-lg px-3 py-2 border border-white/70">
                <p className="text-[9px] text-slate-600 mb-0.5">K{idx + 1}</p>
                <p className="text-xs font-bold text-slate-800">{split}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function MetricBox({ label, value }: { label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-xl p-2 border border-white/60 text-center">
      <p className="text-[9px] text-slate-600 uppercase tracking-wide mb-0.5">{label}</p>
      <p className="text-xs font-bold text-slate-800">{value}</p>
    </div>
  );
}

function WeeklyBreakdownCard({ week, dates, runs, distance, time }: {
  week: string;
  dates: string;
  runs: number;
  distance: string;
  time: string;
}) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/60 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <div>
          <h4 className="font-bold text-[14px] text-slate-800">{week}</h4>
          <p className="text-[11px] text-slate-600">{dates}</p>
        </div>
        <div className="text-right">
          <p className="text-lg font-bold bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
            {runs} runs
          </p>
        </div>
      </div>
      <div className="flex gap-4">
        <div className="flex-1">
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Distance</p>
          <p className="text-sm font-bold text-slate-800">{distance}</p>
        </div>
        <div className="flex-1">
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Time</p>
          <p className="text-sm font-bold text-slate-800">{time}</p>
        </div>
      </div>
    </div>
  );
}

function HighlightRow({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center justify-between">
      <div className="flex items-center gap-3">
        <span className="text-2xl">{icon}</span>
        <p className="text-[13px] font-bold text-slate-800">{label}</p>
      </div>
      <p className="text-sm font-bold bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
        {value}
      </p>
    </div>
  );
}