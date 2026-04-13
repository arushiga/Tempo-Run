export type RunType = 'easy' | 'tempo' | 'race' | 'longRun';
export type RunCategory = 'easy' | 'tempo' | 'long' | 'race';

export interface Activity {
  id: string;
  name: string;
  completionDate: string; // ISO date string "YYYY-MM-DD"
  uploadDate: string;     // ISO date string "YYYY-MM-DD"
  distanceMiles: number;
  durationSeconds: number;
  avgPaceSecondsPerMile: number;
  category: RunCategory;
}

export interface ScheduledRunWithDistance {
  id: string;
  type: RunType;
  day: number;       // 0 (Mon) – 6 (Sun)
  time: 'AM' | 'PM';
  distanceMiles: number;
}

export interface WeekPlan {
  weekStartDate: string; // ISO date string "YYYY-MM-DD" (Monday)
  runs: ScheduledRunWithDistance[];
}

// ─── Helpers ────────────────────────────────────────────────────────────────

/** Returns "MM:SS" pace string from seconds per mile */
export function formatPace(secondsPerMile: number): string {
  if (!secondsPerMile || secondsPerMile <= 0) return '--:--';
  const mins = Math.floor(secondsPerMile / 60);
  const secs = Math.round(secondsPerMile % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

/** Returns "H:MM:SS" or "MM:SS" duration string from total seconds */
export function formatDuration(seconds: number): string {
  if (!seconds || seconds <= 0) return '0:00';
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  return `${m}:${s.toString().padStart(2, '0')}`;
}

/** Returns the ISO date string ("YYYY-MM-DD") for the Monday of the week containing `date` */
export function getWeekStart(date: Date): string {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  const day = d.getDay(); // 0=Sun, 1=Mon, ..., 6=Sat
  const diff = day === 0 ? -6 : 1 - day; // shift to Monday
  d.setDate(d.getDate() + diff);
  return d.toISOString().split('T')[0];
}

/** Returns the ISO date string for this week's Monday */
export function getCurrentWeekStart(): string {
  return getWeekStart(new Date());
}

/** Returns the Monday Date of the week N weeks from the given weekStart */
export function shiftWeek(weekStartISO: string, delta: number): string {
  const d = new Date(weekStartISO + 'T00:00:00');
  d.setDate(d.getDate() + delta * 7);
  return d.toISOString().split('T')[0];
}

/** Category label for display */
export function categoryLabel(cat: RunCategory | RunType): string {
  const map: Record<string, string> = {
    easy: 'Easy',
    tempo: 'Tempo',
    long: 'Long Run',
    longRun: 'Long Run',
    race: 'Race',
  };
  return map[cat] ?? cat;
}

/** Format a date string "YYYY-MM-DD" → "Apr 13" */
export function formatDate(iso: string): string {
  const d = new Date(iso + 'T00:00:00');
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

/** Today's ISO date string */
export function todayISO(): string {
  return new Date().toISOString().split('T')[0];
}

/** Returns ISO date N days before the given date */
export function daysAgo(iso: string, n: number): string {
  const d = new Date(iso + 'T00:00:00');
  d.setDate(d.getDate() - n);
  return d.toISOString().split('T')[0];
}
