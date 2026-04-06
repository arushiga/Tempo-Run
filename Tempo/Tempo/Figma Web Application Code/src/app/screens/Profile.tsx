import { Layout } from '../components/Layout';
import { User, Settings, Award, TrendingUp, LogOut, Bell, Lock, Mail, Camera, Trophy, Target, Star } from 'lucide-react';
import { Link } from 'react-router';

export default function Profile() {
  const userStats = [
    { label: 'Total Runs', value: '87', icon: '🏃' },
    { label: 'Total Distance', value: '428km', icon: '📏' },
    { label: 'Total Time', value: '64h', icon: '⏱️' },
    { label: 'Achievements', value: '12', icon: '🏆' },
  ];

  const preferences = [
    { icon: <Bell className="w-5 h-5" />, label: 'Notifications', value: 'Enabled', toggle: true },
    { icon: <Lock className="w-5 h-5" />, label: 'Privacy', value: 'Public Profile', toggle: false },
    { icon: <Mail className="w-5 h-5" />, label: 'Email', value: 'sarah@example.com', toggle: false },
  ];

  const achievements = [
    { id: 1, title: '5K Streak', description: '5 consecutive weeks', icon: '🔥', color: 'from-orange-400 to-red-500', unlocked: true },
    { id: 2, title: 'Early Bird', description: '20 morning runs', icon: '🌅', color: 'from-amber-400 to-orange-500', unlocked: true },
    { id: 3, title: 'Distance Master', description: 'Run 100km total', icon: '🏆', color: 'from-blue-500 to-blue-700', unlocked: true },
    { id: 4, title: 'Speed Demon', description: 'Sub 4:00 pace', icon: '⚡', color: 'from-emerald-400 to-green-600', unlocked: false },
    { id: 5, title: 'Marathon Ready', description: 'Complete 42km', icon: '🎯', color: 'from-slate-600 to-slate-800', unlocked: false },
    { id: 6, title: 'Consistent Runner', description: '30 day streak', icon: '💪', color: 'from-emerald-400 to-green-500', unlocked: false },
  ];

  const goals = [
    { title: 'Half Marathon', target: '21.1km', deadline: 'May 15, 2026', progress: 75, color: 'from-blue-500 to-blue-700' },
    { title: 'Sub 45min 10K', target: '4:30/km pace', deadline: 'Apr 30, 2026', progress: 60, color: 'from-emerald-500 to-green-600' },
    { title: '500km Total', target: '500km', deadline: 'Jun 1, 2026', progress: 45, color: 'from-slate-600 to-slate-800' },
  ];

  const milestones = [
    { date: 'Mar 28', title: 'Personal Best 10K', value: '48:32', type: 'time' },
    { date: 'Mar 15', title: 'Longest Run', value: '18km', type: 'distance' },
    { date: 'Mar 1', title: 'Fastest 5K', value: '22:15', type: 'time' },
  ];

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-4">
            <h1 className="font-bold text-[32px] text-white tracking-tight">
              Profile 👤
            </h1>
            <Link to="/settings">
              <button className="backdrop-blur-md bg-white/20 rounded-2xl p-2.5 border border-white/30 hover:bg-white/30 transition-all">
                <Settings className="w-5 h-5 text-white" />
              </button>
            </Link>
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* User Info Card */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-6 border border-white/80 shadow-lg">
          <div className="flex items-center gap-4 mb-4">
            {/* Avatar */}
            <div className="relative">
              <div className="w-20 h-20 rounded-full bg-gradient-to-br from-blue-600 to-slate-800 flex items-center justify-center shadow-xl">
                <span className="text-3xl font-bold text-white">SJ</span>
              </div>
              <button className="absolute bottom-0 right-0 backdrop-blur-md bg-white/90 rounded-full p-1.5 shadow-lg border border-white hover:scale-110 transition-transform">
                <Camera className="w-3 h-3 text-slate-700" />
              </button>
            </div>

            {/* User Details */}
            <div className="flex-1">
              <h2 className="font-bold text-[20px] text-slate-800 mb-1">Sarah Johnson</h2>
              <p className="text-[13px] text-slate-600 mb-2">Joined March 2025</p>
              <div className="flex gap-2">
                <span className="px-3 py-1 rounded-full bg-gradient-to-r from-slate-700 to-blue-900 text-white text-[10px] font-bold">
                  PRO RUNNER
                </span>
                <span className="px-3 py-1 rounded-full backdrop-blur-md bg-emerald-100 text-emerald-700 text-[10px] font-bold">
                  LEVEL 8
                </span>
              </div>
            </div>
          </div>

          {/* Bio */}
          <div className="backdrop-blur-md bg-white/40 rounded-2xl p-3 border border-white/60 mb-4">
            <p className="text-[13px] text-slate-700 leading-relaxed">
              🏃‍♀️ Marathon runner | 🎯 Training for Boston 2027 | 💪 Passionate about wellness and fitness
            </p>
          </div>

          {/* Quick Stats Grid */}
          <div className="grid grid-cols-4 gap-2">
            {userStats.map((stat, idx) => (
              <div key={idx} className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/70 text-center">
                <span className="text-2xl block mb-1">{stat.icon}</span>
                <p className="text-lg font-bold text-slate-800">{stat.value}</p>
                <p className="text-[9px] text-slate-600 uppercase tracking-wide">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Active Goals */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-5 border border-white/80 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Target className="w-5 h-5 text-blue-700" />
            Active Goals
          </h2>
          
          <div className="space-y-3">
            {goals.map((goal, idx) => (
              <GoalCard key={idx} {...goal} />
            ))}
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
            {achievements.map((achievement) => (
              <AchievementBadge key={achievement.id} {...achievement} />
            ))}
          </div>
        </div>

        {/* Recent Milestones */}
        <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <Star className="w-5 h-5 text-amber-600" />
            Recent Milestones
          </h2>
          
          <div className="space-y-2">
            {milestones.map((milestone, idx) => (
              <MilestoneCard key={idx} {...milestone} />
            ))}
          </div>
        </div>

        {/* Personal Records */}
        <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
          <h3 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-emerald-600" />
            Personal Records
          </h3>
          
          <div className="space-y-2">
            <PRRow label="Fastest 5K" value="22:15" date="Mar 28, 2026" />
            <PRRow label="Fastest 10K" value="48:32" date="Mar 15, 2026" />
            <PRRow label="Longest Run" value="18.0 km" date="Mar 10, 2026" />
            <PRRow label="Best Pace" value="4:27/km" date="Mar 28, 2026" />
          </div>
        </div>

        {/* Account Settings */}
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

        {/* Overall Stats */}
        <div className="backdrop-blur-xl bg-gradient-to-br from-slate-700/20 to-blue-900/20 rounded-[24px] p-5 border border-white/60 shadow-lg">
          <h2 className="font-bold text-[16px] text-slate-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-emerald-600" />
            All-Time Stats
          </h2>
          
          <div className="grid grid-cols-2 gap-3">
            <OverallStatBox label="Total Runs" value="87" />
            <OverallStatBox label="Total Distance" value="428km" />
            <OverallStatBox label="Total Time" value="64h 12m" />
            <OverallStatBox label="Avg Pace" value="9:02/km" />
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

function GoalCard({ title, target, deadline, progress, color }: { title: string; target: string; deadline: string; progress: number; color: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/70 shadow-sm">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-bold text-[14px] text-slate-800">{title}</h3>
          <p className="text-[11px] text-slate-600 mt-1">Target: {target}</p>
          <p className="text-[10px] text-slate-500 mt-0.5">Due: {deadline}</p>
        </div>
        <div className="text-right">
          <p className={`text-2xl font-bold bg-gradient-to-br ${color} bg-clip-text text-transparent`}>
            {progress}%
          </p>
        </div>
      </div>
      
      <div className="h-2 bg-slate-200/50 rounded-full overflow-hidden">
        <div 
          className={`h-full bg-gradient-to-r ${color} rounded-full transition-all duration-500`}
          style={{ width: `${progress}%` }}
        />
      </div>
    </div>
  );
}

function AchievementBadge({ title, description, icon, color, unlocked }: { title: string; description: string; icon: string; color: string; unlocked: boolean }) {
  return (
    <div className={`backdrop-blur-md rounded-2xl p-3 border shadow-md transition-all hover:scale-105 ${
      unlocked 
        ? 'bg-white/60 border-white/80' 
        : 'bg-slate-200/30 border-slate-300/40 opacity-50'
    }`}>
      <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${color} flex items-center justify-center mb-2 shadow-md mx-auto ${
        unlocked ? '' : 'grayscale'
      }`}>
        <span className="text-2xl">{icon}</span>
      </div>
      <p className="text-[11px] font-bold text-slate-800 text-center leading-tight mb-1">
        {title}
      </p>
      <p className="text-[9px] text-slate-600 text-center leading-tight">
        {description}
      </p>
      {unlocked && (
        <div className="mt-2 flex justify-center">
          <Award className="w-3 h-3 text-emerald-600" />
        </div>
      )}
    </div>
  );
}

function MilestoneCard({ date, title, value, type }: { date: string; title: string; value: string; type: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center gap-3">
      <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-600 to-slate-800 flex items-center justify-center shadow-md flex-shrink-0">
        {type === 'time' ? (
          <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10" />
            <path d="M12 6v6l4 2" />
          </svg>
        ) : (
          <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
          </svg>
        )}
      </div>
      <div className="flex-1">
        <p className="text-[13px] font-bold text-slate-800">{title}</p>
        <p className="text-[11px] text-slate-600">{date}</p>
      </div>
      <div className="text-right">
        <p className="text-lg font-bold bg-gradient-to-br from-blue-700 to-slate-800 bg-clip-text text-transparent">
          {value}
        </p>
      </div>
    </div>
  );
}

function PRRow({ label, value, date }: { label: string; value: string; date: string }) {
  return (
    <div className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center justify-between">
      <div>
        <p className="text-[13px] font-bold text-slate-800">{label}</p>
        <p className="text-[10px] text-slate-600">{date}</p>
      </div>
      <p className="text-lg font-bold bg-gradient-to-r from-blue-700 to-slate-800 bg-clip-text text-transparent">
        {value}
      </p>
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
