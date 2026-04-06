import { Layout } from '../components/Layout';
import { Play, Pause, Square, MapPin, Heart, Zap } from 'lucide-react';
import { useState } from 'react';

type RecordingState = 'idle' | 'recording' | 'paused';

export default function Record() {
  const [recordingState, setRecordingState] = useState<RecordingState>('idle');
  const [elapsedTime, setElapsedTime] = useState('00:00:00');
  const [distance, setDistance] = useState('0.0');
  const [pace, setPace] = useState('0:00');
  const [heartRate, setHeartRate] = useState('--');

  const recentRuns = [
    { date: 'Apr 2', distance: '5.2km', time: '28:45', type: 'Easy' },
    { date: 'Apr 1', distance: '8.0km', time: '42:20', type: 'Tempo' },
    { date: 'Mar 31', distance: '15.0km', time: '1:28:30', type: 'Long' },
  ];

  return (
    <Layout>
      {/* Header */}
      <div className="relative px-8 py-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
        <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
        
        <div className="relative z-10">
          <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">
            Record Run 🏃
          </h1>
          <p className="text-white/90 text-[15px] font-medium">
            Track your running activity
          </p>
        </div>
      </div>

      <div className="px-6 py-6 space-y-5 max-h-[calc(100vh-280px)] overflow-y-auto">
        {/* Main Recording Card */}
        <div className="backdrop-blur-xl bg-white/60 rounded-[24px] p-8 border border-white/80 shadow-lg">
          {/* Live Stats Display */}
          <div className="space-y-6 mb-8">
            {/* Time Display */}
            <div className="text-center">
              <p className="text-sm text-slate-600 font-semibold mb-2">TIME</p>
              <p className="text-6xl font-bold bg-gradient-to-br from-slate-800 to-blue-900 bg-clip-text text-transparent">
                {elapsedTime}
              </p>
            </div>

            {/* Distance and Pace */}
            <div className="grid grid-cols-2 gap-4">
              <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/70 text-center">
                <p className="text-xs text-slate-600 font-semibold uppercase tracking-wider mb-2">
                  Distance
                </p>
                <p className="text-3xl font-bold text-slate-800">{distance}</p>
                <p className="text-sm text-slate-600 mt-1">kilometers</p>
              </div>
              
              <div className="backdrop-blur-md bg-white/50 rounded-2xl p-4 border border-white/70 text-center">
                <p className="text-xs text-slate-600 font-semibold uppercase tracking-wider mb-2">
                  Avg Pace
                </p>
                <p className="text-3xl font-bold text-slate-800">{pace}</p>
                <p className="text-sm text-slate-600 mt-1">min/km</p>
              </div>
            </div>

            {/* Additional Metrics */}
            <div className="grid grid-cols-3 gap-3">
              <MetricCard icon={<Heart className="w-5 h-5" />} label="Heart Rate" value={heartRate} unit="bpm" />
              <MetricCard icon={<Zap className="w-5 h-5" />} label="Calories" value="0" unit="kcal" />
              <MetricCard icon={<MapPin className="w-5 h-5" />} label="Elevation" value="0" unit="m" />
            </div>
          </div>

          {/* Control Buttons */}
          <div className="flex gap-3 justify-center">
            {recordingState === 'idle' && (
              <button 
                onClick={() => setRecordingState('recording')}
                className="flex-1 backdrop-blur-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded-2xl py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center gap-2"
              >
                <Play className="w-5 h-5" fill="currentColor" />
                Start Run
              </button>
            )}

            {recordingState === 'recording' && (
              <>
                <button 
                  onClick={() => setRecordingState('paused')}
                  className="flex-1 backdrop-blur-xl bg-gradient-to-r from-amber-500 to-orange-600 text-white rounded-2xl py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center gap-2"
                >
                  <Pause className="w-5 h-5" fill="currentColor" />
                  Pause
                </button>
                <button 
                  onClick={() => setRecordingState('idle')}
                  className="backdrop-blur-xl bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-2xl px-6 py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center"
                >
                  <Square className="w-5 h-5" fill="currentColor" />
                </button>
              </>
            )}

            {recordingState === 'paused' && (
              <>
                <button 
                  onClick={() => setRecordingState('recording')}
                  className="flex-1 backdrop-blur-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded-2xl py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center gap-2"
                >
                  <Play className="w-5 h-5" fill="currentColor" />
                  Resume
                </button>
                <button 
                  onClick={() => setRecordingState('idle')}
                  className="backdrop-blur-xl bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-2xl px-6 py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all flex items-center justify-center"
                >
                  <Square className="w-5 h-5" fill="currentColor" />
                </button>
              </>
            )}
          </div>

          {recordingState !== 'idle' && (
            <p className="text-center text-sm text-slate-600 mt-4 font-medium">
              {recordingState === 'recording' ? '🔴 Recording in progress...' : '⏸️ Paused'}
            </p>
          )}
        </div>

        {/* Quick Start Options */}
        {recordingState === 'idle' && (
          <div className="backdrop-blur-xl bg-gradient-to-br from-white/50 to-white/30 rounded-[24px] p-5 border border-white/60 shadow-lg">
            <h3 className="font-bold text-[16px] text-slate-800 mb-4">Quick Start</h3>
            
            <div className="grid grid-cols-2 gap-3">
              <QuickStartButton label="Easy Run" emoji="🏃" color="from-blue-500 to-sky-600" />
              <QuickStartButton label="Tempo" emoji="⚡" color="from-amber-500 to-orange-600" />
              <QuickStartButton label="Race Pace" emoji="🏁" color="from-purple-500 to-fuchsia-600" />
              <QuickStartButton label="Long Run" emoji="🎯" color="from-emerald-500 to-green-600" />
            </div>
          </div>
        )}

        {/* Recent Runs */}
        {recordingState === 'idle' && (
          <div className="backdrop-blur-xl bg-white/50 rounded-[24px] p-5 border border-white/70 shadow-lg">
            <h3 className="font-bold text-[16px] text-slate-800 mb-4">Recent Runs</h3>
            
            <div className="space-y-2">
              {recentRuns.map((run, idx) => (
                <div key={idx} className="backdrop-blur-md bg-white/50 rounded-2xl p-3 border border-white/60 shadow-sm flex items-center justify-between">
                  <div>
                    <p className="text-[13px] font-bold text-slate-800">{run.type} Run</p>
                    <p className="text-[11px] text-slate-600">{run.date}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-bold text-slate-800">{run.distance}</p>
                    <p className="text-[11px] text-slate-600">{run.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}

function MetricCard({ icon, label, value, unit }: { icon: React.ReactNode; label: string; value: string; unit: string }) {
  return (
    <div className="backdrop-blur-md bg-white/40 rounded-xl p-3 border border-white/60 text-center">
      <div className="text-slate-600 flex justify-center mb-1">{icon}</div>
      <p className="text-lg font-bold text-slate-800">{value}</p>
      <p className="text-[9px] text-slate-600 uppercase tracking-wide">{label}</p>
    </div>
  );
}

function QuickStartButton({ label, emoji, color }: { label: string; emoji: string; color: string }) {
  return (
    <button className={`backdrop-blur-xl bg-gradient-to-br ${color} rounded-2xl p-4 border border-white/30 shadow-lg hover:shadow-xl hover:scale-105 transition-all`}>
      <span className="text-3xl mb-2 block">{emoji}</span>
      <p className="text-white font-bold text-[13px]">{label}</p>
    </button>
  );
}
