import { Layout } from '../components/Layout';
import { Settings, Award, TrendingUp, LogOut, Bell, Lock, Mail, Camera, Trophy, Target, Star } from 'lucide-react';
import {
  useActivities,
  useWeekPlan,
  getWeekActivities,
  totalMiles,
  avgPaceFormatted,
  mostRecentActivity,
  weekPlanCompletion,
  getCurrentWeekStart,
} from '../hooks/useAppData';
import { formatDate, formatDuration, formatPace } from '../lib/types';

export default function Profile() {
  const { activities } = useActivities();
  const weekStart = getCurrentWeekStart();
  const { weekPlan } = useWeekPlan(weekStart);

  // Computed training data
  const weekActs = getWeekActivities(activities, weekStart);
  const weeklyMiles = totalMiles(weekActs);
  const lastRun = mostRecentActivity(activities);
  const planCompletion = weekPlanCompletion(activities, weekPlan, weekStart);

  // All-time stats
  const allTimeMiles = totalMiles(activities);
  const allTimeSecs  = activities.reduce((s, a) => s + a.durationSeconds, 0);
  const allTimePace  = avgPaceFormatted(activities);

  // Planner stats for this week
  const weekIntensity = 15 + (weekPlan.runs.filter(r => r.type === 'tempo').length * 5) + (weekPlan.runs.filter(r => r.type === 'race').length * 10);
  const weekLoad      = Math.max(0, 43 - (7 - weekPlan.runs.length) * 5);

  const preferences = [
    { icon: <Bell className="w-5 h-5" />, label: 'Notifications', value: 'Enabled', toggle: true },
    { icon: <Lock className="w-5 h-5" />, label: 'Privacy', value: 'Public Profile', toggle: false },
    { icon: <Mail className="w-5 h-5" />, label: 'Email', value: 'runner@example.com', toggle: false },
  ];

  const achievements = [
    { id: 1, title: '5K Streak',       description: '5 consecutive weeks',  icon: '🔥', color: 'from-orange-400 to-red-500',     unlocked: true },
    { id: 2, title: 'Early Bird',       description: '20 morning runs',      icon: '🌅', color: 'from-amber-400 to-orange-500',   unlocked: true },
    { id: 3, title: 'Distance Master',  description: 'Run 100km total',      icon: '🏆', color: 'from-blue-500 to-blue-700',      unlocked: true },
    { id: 4, title: 'Speed Demon',      description: 'Sub 4:00 pace',        icon: '⚡', color: 'from-emerald-400 to-green-600',  unlocked: false },
    { id: 5, title: 'Marathon Ready',   description: 'Complete 26.2 mi',     icon: '🎯', color: 'from-slate-600 to-slate-800',    unlocked: false },
    { id: 6, title: 'Consistent Runner',description: '30 day streak',        icon: '💪', color: 'from-emerald-400 to-green-500',  unlocked: false },
  ];

  const goals = [
    { title: 'Half Marathon',    target: '13.1 mi',       deadline: 'May 15, 2026', progress: 75, color: 'from-blue-500 to-blue-700' },
    { title: 'Sub 45min 10K',   target: '4:30/mi pace',  deadline: 'Apr 30, 2026', progress: 60, color: 'from-emerald-500 to-green-600' },
    { title: '500 Total Miles',  target: '500 mi',        deadline: 'Jun 1, 2026',  progress: Math.min(Math.round((allTimeMiles / 500) * 100), 100), color: 'from-slate-600 to-slate-800' },
  ];

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-4">
            <h1 className="font-bold text-[32px] text-white tracking-tight">Profile 👤</h1>
            <button className="backdrop-blur-md bg-white/20 rounded-2xl p-2.5 border border-white/30 hover:bg-white/30 transition-all">
              <Settings className="w-5 h-5 text-white" />
            </button>
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* User Info Card */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-6 border border-white/80 shadow-lg">
          <div className="flex items-center gap-4 mb-4">
            <div className="relative">
              <div className="w-20 h-20 rounded-full bg-gradient-to-br from-blue-600 to-slate-800 flex items-center justify-center shadow-xl">
                <span className="text-3xl font-bold text-white">EC</span>
              </div>
              <button className="absolute bottom-0 right-0 backdrop-blur-md bg-white/90 rounded-full p-1.5 shadow-lg border border-white hover:scale-110 transition-transform">
                <Camera className="w-3 h-3 text-slate-700" />
              </button>
            </div>
            <div className="flex-1">
              <h2 className="font-bold text-[20px] text-slate-800 mb-1">Eric Chen</h2>
              <p className="text-[13px] text-slate-600 mb-2">Joined April 2026</p>
              <div className="flex gap-2">
                <span className="px-3 py-1 rounded-full bg-gradient-to-r from-slate-700 to-blue-900 text-white text-[10px] font-bold">
                  RUNNER
                </span>
                <span className="px-3 py-1 rounded-full backdrop-blur-md bg-emerald-100 text-emerald-700 text-[10px] font-bold">
                  LEVEL {Math.max(1, Math.floor(activities.length / 5) + 1)}
                </span>
              </div>
            </div>
          </div>

          {/* Quick Stats Grid */}
          <div className="grid grid-cols-4 gap-2">
            <StatBox icon="🏃" label="Total Runs"  value={activities.length.toString()} />
            <StatBox icon="📏" label="Total Miles" value={`${allTimeMiles.toFixed(0)} mi`} />
            <StatBox icon="⏱️" label="Total Time"  value={formatDuration(allTimeSecs)} />
            <StatBox icon="🏆" label="Achievements" value="3" />
          </div>
        </div>

        {/* ── Training Snapshot (REAL DATA) ── */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-blue-700" />
            Training Snapshot
          </h2>

          <div className="space-y-3">
            <SnapshotRow
              icon="📏"
              label="Weekly Distance"
              value={`${weeklyMiles.toFixed(1)} mi`}
              sub={`${weekActs.length} run${weekActs.length !== 1 ? 's' : ''} this week`}
            />
            <SnapshotRow
              icon="📅"
              label="Most Recent Run"
              value={lastRun ? formatDate(lastRun.completionDate) : '—'}
              sub={lastRun ? lastRun.name : 'No runs logged yet'}
            />
            <SnapshotRow
              icon="⚡"
              label="Last Run Distance"
              value={lastRun ? `${lastRun.distanceMiles.toFixed(1)} mi` : '—'}
              sub={lastRun ? `Pace: ${formatPace(lastRun.avgPaceSecondsPerMile)}/mi` : ''}
            />
          </div>
        </div>

        {/* ── Training Plan Progress (REAL DATA) ── */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Target className="w-5 h-5 text-emerald-600" />
            Training Plan Progress
          </h2>

          {weekPlan.runs.length === 0 ? (
            <div className="text-center py-4">
              <p className="text-slate-500 text-[13px]">No plan set for this week.</p>
              <p className="text-slate-400 text-[11px] mt-1">Go to the Planner to build your week!</p>
            </div>
          ) : (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <p className="text-[13px] text-slate-700 font-medium">
                  {weekPlan.runs.length} run{weekPlan.runs.length !== 1 ? 's' : ''} planned this week
                </p>
                <p className="text-[12px] font-bold bg-gradient-to-r from-emerald-500 to-green-600 bg-clip-text text-transparent">
                  {planCompletion}% done
                </p>
              </div>
              <div className="h-3 bg-slate-200/50 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-emerald-500 to-green-600 rounded-full transition-all duration-500"
                  style={{ width: `${planCompletion}%` }}
                />
              </div>
              <div className="grid grid-cols-2 gap-3 pt-1">
                <SnapshotRow icon="🔥" label="Weekly Load"      value={`+${weekLoad}`}       sub="relative intensity" />
                <SnapshotRow icon="⚡" label="Intensity Score"  value={`+${weekIntensity}`}   sub="tempo + race runs"  />
              </div>
            </div>
          )}
        </div>

        {/* Active Goals */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Target className="w-5 h-5 text-blue-700" />
            Active Goals
          </h2>
          <div className="space-y-3">
            {goals.map((goal, idx) => <GoalCard key={idx} {...goal} />)}
          </div>
          <button className="mt-4 w-full backdrop-blur-md bg-gradient-to-r from-slate-700 to-blue-900 text-white rounded-2xl py-3 font-semibold text-sm hover:shadow-lg hover:scale-[1.02] transition-all">
            + Add New Goal
          </button>
        </div>

        {/* Achievements */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Trophy className="w-5 h-5 text-emerald-600" />
            Achievements
            <span className="ml-auto text-xs font-semibold text-blue-700 backdrop-blur-md bg-blue-100 px-3 py-1 rounded-full">
              3/6 Unlocked
            </span>
          </h2>
          <div className="grid grid-cols-3 gap-3">
            {achievements.map(a => <AchievementBadge key={a.id} {...a} />)}
          </div>
        </div>

        {/* All-Time Stats */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-slate-700/20 to-blue-900/20 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-emerald-600" />
            All-Time Stats
          </h2>
          <div className="grid grid-cols-2 gap-3">
            <OverallStatBox label="Total Runs"      value={activities.length.toString()} />
            <OverallStatBox label="Total Distance"  value={`${allTimeMiles.toFixed(1)} mi`} />
            <OverallStatBox label="Total Time"      value={formatDuration(allTimeSecs)} />
            <OverallStatBox label="Avg Pace"        value={`${allTimePace}/mi`} />
          </div>
        </div>

        {/* Preferences */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h3 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Settings className="w-5 h-5 text-slate-700" />
            Preferences
          </h3>
          <div className="space-y-2">
            {preferences.map((pref, idx) => (
              <div key={idx} className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="text-slate-700">{pref.icon}</div>
                  <div>
                    <p className="text-[13px] font-bold text-slate-800">{pref.label}</p>
                    <p className="text-[11px] text-slate-600">{pref.value}</p>
                  </div>
                </div>
                {pref.toggle ? (
                  <div className="w-11 h-6 bg-gradient-to-r from-emerald-500 to-green-600 rounded-full p-0.5 cursor-pointer">
                    <div className="w-5 h-5 bg-white rounded-full ml-auto shadow-md" />
                  </div>
                ) : (
                  <svg className="w-5 h-5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Logout Button */}
        <button className="w-full backdrop-blur-xl bg-gradient-to-r from-red-500 to-pink-500 text-white rounded-2xl py-4 font-bold text-[15px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center gap-2">
          <LogOut className="w-5 h-5" />
          Log Out
        </button>
      </div>
    </Layout>
  );
}

// ─── Sub-components ────────────────────────────────────────────────────────

function StatBox({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70 text-center">
      <span className="text-2xl block mb-1">{icon}</span>
      <p className="text-[14px] font-bold text-slate-800">{value}</p>
      <p className="text-[9px] text-slate-600 uppercase tracking-wide">{label}</p>
    </div>
  );
}

function SnapshotRow({ icon, label, value, sub }: { icon: string; label: string; value: string; sub: string }) {
  return (
    <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 flex items-center justify-between">
      <div className="flex items-center gap-2">
        <span className="text-xl">{icon}</span>
        <div>
          <p className="text-[12px] font-semibold text-slate-700">{label}</p>
          {sub && <p className="text-[10px] text-slate-500">{sub}</p>}
        </div>
      </div>
      <p className="text-[15px] font-bold bg-gradient-to-br from-slate-700 to-blue-900 bg-clip-text text-transparent">
        {value}
      </p>
    </div>
  );
}

function GoalCard({ title, target, deadline, progress, color }: { title: string; target: string; deadline: string; progress: number; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/70 shadow-sm">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-bold text-[14px] text-slate-800">{title}</h3>
          <p className="text-[11px] text-slate-600 mt-1">Target: {target}</p>
          <p className="text-[10px] text-slate-500 mt-0.5">Due: {deadline}</p>
        </div>
        <p className={`text-2xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>{progress}%</p>
      </div>
      <div className="h-2 bg-slate-200/50 rounded-full overflow-hidden">
        <div className={`h-full bg-gradient-to-r ${color} rounded-full transition-all duration-500`} style={{ width: `${progress}%` }} />
      </div>
    </div>
  );
}

function AchievementBadge({ title, description, icon, color, unlocked }: { title: string; description: string; icon: string; color: string; unlocked: boolean }) {
  return (
    <div className={`backdrop-blur-md rounded-2xl p-3 border shadow-md transition-all hover:scale-105 ${unlocked ? 'bg-white/60 border-white/80' : 'bg-slate-200/30 border-slate-300/40 opacity-50'}`}>
      <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${color} flex items-center justify-center mb-2 shadow-md mx-auto ${unlocked ? '' : 'grayscale'}`}>
        <span className="text-2xl">{icon}</span>
      </div>
      <p className="text-[11px] font-bold text-slate-800 text-center leading-tight mb-1">{title}</p>
      <p className="text-[9px] text-slate-600 text-center leading-tight">{description}</p>
      {unlocked && <div className="mt-2 flex justify-center"><Award className="w-3 h-3 text-emerald-600" /></div>}
    </div>
  );
}

function OverallStatBox({ label, value }: { label: string; value: string }) {
  return (
    <div className="backdrop-blur-md bg-white/60 rounded-2xl p-3 border border-white/70 shadow-sm">
      <p className="text-[11px] text-slate-600 font-semibold mb-1">{label}</p>
      <p className="text-xl font-bold text-slate-800">{value}</p>
    </div>
  );
}
