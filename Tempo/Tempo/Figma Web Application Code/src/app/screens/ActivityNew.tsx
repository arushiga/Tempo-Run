import { Layout } from '../components/Layout';
import { useState } from 'react';
import { BarChart3, TrendingUp, Calendar, Clock } from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, ResponsiveContainer,
  LineChart, Line, Area, AreaChart,
} from 'recharts';
import {
  useActivities,
  getWeekActivities,
  getRecentActivities,
  getTodayActivities,
  totalMiles,
  avgPaceFormatted,
  activitiesByDayOfWeek,
  getCurrentWeekStart,
} from '../hooks/useAppData';
import {
  formatDuration,
  formatPace,
  formatDate,
  categoryLabel,
  todayISO,
  daysAgo,
} from '../lib/types';
import type { Activity } from '../lib/types';

type TimeView = 'day' | '3day' | 'weekly' | 'monthly';

const TYPE_COLORS: Record<string, string> = {
  easy:  'from-sky-400 to-blue-500',
  tempo: 'from-amber-400 to-orange-500',
  long:  'from-emerald-400 to-green-500',
  race:  'from-fuchsia-400 to-pink-500',
};

export default function Activity() {
  const [timeView, setTimeView] = useState<TimeView>('weekly');
  const { activities } = useActivities();

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        <div className="relative z-10">
          <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">Activity 📊</h1>
          <p className="text-white/90 text-[15px] font-medium">Your training history & analytics</p>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* Time View Tabs */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-2 border border-white/80 shadow-lg flex gap-1.5">
          {(['day', '3day', 'weekly', 'monthly'] as TimeView[]).map(v => (
            <TabButton
              key={v}
              label={v === 'day' ? 'Day' : v === '3day' ? '3 Days' : v === 'weekly' ? 'Weekly' : 'Monthly'}
              active={timeView === v}
              onClick={() => setTimeView(v)}
            />
          ))}
        </div>

        {timeView === 'day'     && <DayView     activities={activities} />}
        {timeView === '3day'    && <ThreeDayView activities={activities} />}
        {timeView === 'weekly'  && <WeeklyView   activities={activities} />}
        {timeView === 'monthly' && <MonthlyView  activities={activities} />}
      </div>
    </Layout>
  );
}

function TabButton({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className={`flex-1 py-2.5 rounded-2xl font-semibold text-[12px] transition-all ${
        active
          ? 'bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white shadow-md'
          : 'text-slate-600 hover:bg-white/50'
      }`}
    >
      {label}
    </button>
  );
}

// ─── Day View ─────────────────────────────────────────────────────────────

function DayView({ activities }: { activities: Activity[] }) {
  const todayActs = getTodayActivities(activities).sort(
    (a, b) => b.completionDate.localeCompare(a.completionDate)
  );
  const todayMiles = totalMiles(todayActs);
  const today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });

  return (
    <>
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-1 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-violet-600" />
          Today
        </h2>
        <p className="text-[12px] text-slate-500 mb-4">{today}</p>

        <div className="grid grid-cols-3 gap-3">
          <QuickStat label="Runs"     value={todayActs.length.toString()} color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance" value={`${todayMiles.toFixed(1)} mi`} color="from-sky-400 to-blue-500" />
          <QuickStat label="Avg Pace" value={avgPaceFormatted(todayActs)} color="from-amber-400 to-orange-500" />
        </div>
      </div>

      {todayActs.length === 0 ? (
        <EmptyState message="No runs logged today." hint="Go to Record to log today's run!" />
      ) : (
        todayActs.map(act => <ActivityDetailCard key={act.id} activity={act} />)
      )}
    </>
  );
}

// ─── 3-Day View ───────────────────────────────────────────────────────────

function ThreeDayView({ activities }: { activities: Activity[] }) {
  const recent = getRecentActivities(activities, 3).sort(
    (a, b) => b.completionDate.localeCompare(a.completionDate)
  );
  const miles = totalMiles(recent);

  // Chart data: last 3 days
  const today = todayISO();
  const data = [2, 1, 0].map(offset => {
    const iso = daysAgo(today, offset);
    const dayActs = activities.filter(a => a.completionDate === iso);
    const d = new Date(iso + 'T00:00:00');
    return {
      day: d.toLocaleDateString('en-US', { weekday: 'short' }),
      distance: Math.round(totalMiles(dayActs) * 10) / 10,
    };
  });

  return (
    <>
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-violet-600" />
          Last 3 Days
        </h2>

        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Runs"     value={recent.length.toString()} color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance" value={`${miles.toFixed(1)} mi`} color="from-sky-400 to-blue-500" />
          <QuickStat label="Avg Pace" value={avgPaceFormatted(recent)}  color="from-amber-400 to-orange-500" />
        </div>

        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Daily Distance (mi)</p>
          <ResponsiveContainer width="100%" height={120}>
            <BarChart data={data}>
              <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
              <Bar dataKey="distance" fill="url(#gradPurple)" radius={[8, 8, 0, 0]} />
              <defs>
                <linearGradient id="gradPurple" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#a855f7" />
                  <stop offset="100%" stopColor="#8b5cf6" />
                </linearGradient>
              </defs>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {recent.length === 0 ? (
        <EmptyState message="No runs in the last 3 days." hint="Log a run to see it here!" />
      ) : (
        recent.map(act => <RunHistoryCard key={act.id} activity={act} showDetail />)
      )}
    </>
  );
}

// ─── Weekly View ───────────────────────────────────────────────────────────

function WeeklyView({ activities }: { activities: Activity[] }) {
  const weekStart = getCurrentWeekStart();
  const weekActs = getWeekActivities(activities, weekStart).sort(
    (a, b) => b.completionDate.localeCompare(a.completionDate)
  );
  const miles = totalMiles(weekActs);
  const totalSecs = weekActs.reduce((s, a) => s + a.durationSeconds, 0);
  const chartData = activitiesByDayOfWeek(activities, weekStart);

  return (
    <>
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-violet-600" />
          This Week
        </h2>

        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Runs"     value={weekActs.length.toString()} color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance" value={`${miles.toFixed(1)} mi`}   color="from-sky-400 to-blue-500" />
          <QuickStat label="Time"     value={formatDuration(totalSecs)}   color="from-amber-400 to-orange-500" />
        </div>

        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Daily Distance (mi)</p>
          <ResponsiveContainer width="100%" height={120}>
            <BarChart data={chartData}>
              <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
              <Bar dataKey="distance" fill="url(#gradPurple2)" radius={[8, 8, 0, 0]} />
              <defs>
                <linearGradient id="gradPurple2" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#a855f7" />
                  <stop offset="100%" stopColor="#8b5cf6" />
                </linearGradient>
              </defs>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Run list */}
      <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Clock className="w-5 h-5 text-fuchsia-600" />
          This Week's Runs
        </h2>

        {weekActs.length === 0 ? (
          <EmptyState message="No runs this week yet." hint="Log a run to see it here!" />
        ) : (
          <div className="space-y-2">
            {weekActs.map(act => <RunHistoryCard key={act.id} activity={act} />)}
          </div>
        )}
      </div>

      {/* Personal Records (hardcoded — acceptable per spec) */}
      <div className="backdrop-blur-xl bg-gradient-to-br from-amber-500/20 to-orange-500/20 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <span className="text-xl">🏆</span>
          Personal Records
        </h2>
        <div className="grid grid-cols-2 gap-3">
          <PRCard label="Fastest 5K"  value="22:15" />
          <PRCard label="Fastest 10K" value="48:32" />
          <PRCard label="Longest Run" value="10.0 mi" />
          <PRCard label="Best Pace"   value="7:09/mi" />
        </div>
      </div>
    </>
  );
}

// ─── Monthly View ──────────────────────────────────────────────────────────

function MonthlyView({ activities }: { activities: Activity[] }) {
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().split('T')[0];
  const monthActs = activities.filter(a => a.completionDate >= monthStart).sort(
    (a, b) => b.completionDate.localeCompare(a.completionDate)
  );

  const miles = totalMiles(monthActs);
  const totalSecs = monthActs.reduce((s, a) => s + a.durationSeconds, 0);
  const monthName = now.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

  // Weekly buckets for chart
  const weekBuckets = [0, 1, 2, 3].map(i => {
    const weekStart = new Date(now.getFullYear(), now.getMonth(), 1 + i * 7);
    const weekEnd   = new Date(now.getFullYear(), now.getMonth(), 1 + (i + 1) * 7);
    const bucket = monthActs.filter(a => {
      const d = new Date(a.completionDate + 'T00:00:00');
      return d >= weekStart && d < weekEnd;
    });
    return { week: `W${i + 1}`, distance: Math.round(totalMiles(bucket) * 10) / 10, runs: bucket.length };
  });

  const paceData = weekBuckets.map(w => ({
    week: w.week,
    pace: w.runs > 0
      ? (() => {
          const bucket = monthActs.slice(0, w.runs);
          const secs = bucket.reduce((s, a) => s + a.durationSeconds, 0);
          const dist = totalMiles(bucket);
          return dist > 0 ? Math.round((secs / dist) / 6) / 10 : 0;
        })()
      : 0,
  }));

  return (
    <>
      <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <TrendingUp className="w-5 h-5 text-violet-600" />
          {monthName}
        </h2>

        <div className="grid grid-cols-3 gap-3 mb-4">
          <QuickStat label="Total Runs" value={monthActs.length.toString()} color="from-violet-400 to-purple-500" />
          <QuickStat label="Distance"   value={`${miles.toFixed(1)} mi`}   color="from-sky-400 to-blue-500" />
          <QuickStat label="Avg Pace"   value={avgPaceFormatted(monthActs)} color="from-amber-400 to-orange-500" />
        </div>

        {/* Weekly distance trend */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 mb-3">
          <p className="text-xs font-semibold text-slate-700 mb-3">Weekly Distance (mi)</p>
          <ResponsiveContainer width="100%" height={100}>
            <AreaChart data={weekBuckets}>
              <defs>
                <linearGradient id="colorArea" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#0ea5e9" stopOpacity={0.3} />
                  <stop offset="100%" stopColor="#0ea5e9" stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <XAxis dataKey="week" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
              <Area type="monotone" dataKey="distance" stroke="#0ea5e9" strokeWidth={2.5} fill="url(#colorArea)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Pace trend */}
        <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60">
          <p className="text-xs font-semibold text-slate-700 mb-3">Avg Pace Trend (min/mi)</p>
          <ResponsiveContainer width="100%" height={100}>
            <LineChart data={paceData}>
              <XAxis dataKey="week" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748b' }} />
              <Line type="monotone" dataKey="pace" stroke="#f97316" strokeWidth={3} dot={{ fill: '#f97316', r: 4 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Weekly breakdown */}
      <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <BarChart3 className="w-5 h-5 text-fuchsia-600" />
          Weekly Breakdown
        </h2>
        <div className="space-y-2">
          {weekBuckets.map(w => (
            <div key={w.week} className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/60 shadow-sm flex items-center justify-between">
              <div>
                <h4 className="font-bold text-[14px] text-slate-800">{w.week}</h4>
                <p className="text-[11px] text-slate-600">{w.runs} run{w.runs !== 1 ? 's' : ''}</p>
              </div>
              <p className="text-lg font-bold bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
                {w.distance.toFixed(1)} mi
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Run list — icon + date (compact monthly view) */}
      <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
        <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
          <Clock className="w-5 h-5 text-fuchsia-600" />
          All Runs This Month
        </h2>
        {monthActs.length === 0 ? (
          <EmptyState message="No runs this month." hint="Log a run to see it here!" />
        ) : (
          <div className="space-y-2">
            {monthActs.map(act => (
              <div key={act.id} className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center gap-3">
                <div className={`px-2.5 py-1 rounded-xl bg-gradient-to-r ${TYPE_COLORS[act.category] ?? TYPE_COLORS.easy} text-white text-[10px] font-bold shrink-0`}>
                  {categoryLabel(act.category)}
                </div>
                <p className="text-[13px] font-semibold text-slate-700 flex-1 truncate">{act.name}</p>
                <p className="text-[12px] text-slate-500 font-medium shrink-0">{formatDate(act.completionDate)}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}

// ─── Sub-components ────────────────────────────────────────────────────────

function QuickStat({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70 shadow-sm">
      <p className="text-[10px] text-slate-600 font-semibold uppercase tracking-wider mb-1">{label}</p>
      <p className={`text-lg font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>{value}</p>
    </div>
  );
}

function RunHistoryCard({ activity: act, showDetail = false }: { activity: Activity; showDetail?: boolean }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <div className={`px-2 py-1 rounded-lg bg-gradient-to-r ${TYPE_COLORS[act.category] ?? TYPE_COLORS.easy} text-white text-[10px] font-bold`}>
            {categoryLabel(act.category)}
          </div>
          <span className="text-[11px] text-slate-600 font-medium">{formatDate(act.completionDate)}</span>
        </div>
      </div>
      <p className="text-[12px] text-slate-700 font-semibold mb-2">{act.name}</p>
      <div className="grid grid-cols-3 gap-2">
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Distance</p>
          <p className="text-sm font-bold text-slate-800">{act.distanceMiles.toFixed(1)} mi</p>
        </div>
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Time</p>
          <p className="text-sm font-bold text-slate-800">{formatDuration(act.durationSeconds)}</p>
        </div>
        <div>
          <p className="text-[9px] text-slate-600 uppercase tracking-wider mb-0.5">Pace</p>
          <p className="text-sm font-bold text-slate-800">{formatPace(act.avgPaceSecondsPerMile)}/mi</p>
        </div>
      </div>
    </div>
  );
}

function ActivityDetailCard({ activity: act }: { activity: Activity }) {
  return (
    <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-bold text-[16px] text-slate-800 mb-1">{act.name}</h3>
          <div className={`inline-block px-3 py-1 rounded-lg bg-gradient-to-r ${TYPE_COLORS[act.category] ?? TYPE_COLORS.easy} text-white text-[11px] font-bold`}>
            {categoryLabel(act.category)}
          </div>
        </div>
        <div className="text-right">
          <p className="text-2xl font-bold bg-gradient-to-r from-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
            {act.distanceMiles.toFixed(1)} mi
          </p>
          <p className="text-[11px] text-slate-600">{formatDuration(act.durationSeconds)}</p>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <MetricBox label="Avg Pace"  value={`${formatPace(act.avgPaceSecondsPerMile)}/mi`} />
        <MetricBox label="Date"      value={formatDate(act.completionDate)} />
      </div>
    </div>
  );
}

function MetricBox({ label, value }: { label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-xl p-3 border border-white/60 text-center">
      <p className="text-[9px] text-slate-600 uppercase tracking-wide mb-0.5">{label}</p>
      <p className="text-sm font-bold text-slate-800">{value}</p>
    </div>
  );
}

function PRCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/60 rounded-2xl p-3 border border-white/70 shadow-sm">
      <p className="text-[10px] text-slate-600 font-semibold mb-1">{label}</p>
      <p className="text-lg font-bold bg-gradient-to-r from-amber-600 to-orange-600 bg-clip-text text-transparent">{value}</p>
    </div>
  );
}

function EmptyState({ message, hint }: { message: string; hint: string }) {
  return (
    <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-8 border border-white/70 shadow-lg text-center">
      <p className="text-4xl mb-3">🏃</p>
      <p className="text-slate-600 text-[14px] font-semibold">{message}</p>
      <p className="text-slate-400 text-[12px] mt-1">{hint}</p>
    </div>
  );
}
