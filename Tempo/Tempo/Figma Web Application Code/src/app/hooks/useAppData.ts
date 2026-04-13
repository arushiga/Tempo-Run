/**
 * useAppData.ts — localStorage-based data layer for Tempo.
 *
 * FIREBASE MIGRATION NOTE (for teammates):
 * When Firestore is ready, replace the localStorage read/write calls below
 * with onSnapshot listeners and setDoc/addDoc calls. The hook signatures and
 * return types stay identical so all screens need zero changes.
 *
 * Firestore schema:
 *   users/{uid}/activities/{activityId}  — one doc per Activity
 *   users/{uid}/weekPlans/{weekStart}    — one doc per WeekPlan
 */

import { useState, useEffect, useCallback } from 'react';
import {
  Activity,
  WeekPlan,
  ScheduledRunWithDistance,
  getCurrentWeekStart,
  getWeekStart,
  todayISO,
  daysAgo,
  formatPace,
} from '../lib/types';
import { SEED_ACTIVITIES } from '../lib/seedData';

const ACTIVITIES_KEY = 'tempo_activities';
const WEEK_KEY = (weekStart: string) => `tempo_week_${weekStart}`;

// ─── Activities ─────────────────────────────────────────────────────────────

function loadActivities(): Activity[] {
  try {
    const raw = localStorage.getItem(ACTIVITIES_KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as Activity[];
      if (parsed.length > 0) return parsed;
    }
  } catch {
    // ignore
  }
  // Fall back to seed data on first load
  return SEED_ACTIVITIES;
}

function saveActivities(activities: Activity[]): void {
  localStorage.setItem(ACTIVITIES_KEY, JSON.stringify(activities));
}

export function useActivities() {
  const [activities, setActivities] = useState<Activity[]>(() => loadActivities());

  const addActivity = useCallback((data: Omit<Activity, 'id' | 'uploadDate'>) => {
    const newActivity: Activity = {
      ...data,
      id: `activity-${Date.now()}`,
      uploadDate: todayISO(),
    };
    setActivities(prev => {
      const updated = [newActivity, ...prev];
      saveActivities(updated);
      return updated;
    });
  }, []);

  return { activities, addActivity };
}

// ─── Week Plan ───────────────────────────────────────────────────────────────

function loadWeekPlan(weekStart: string): WeekPlan {
  try {
    const raw = localStorage.getItem(WEEK_KEY(weekStart));
    if (raw) return JSON.parse(raw) as WeekPlan;
  } catch {
    // ignore
  }
  return { weekStartDate: weekStart, runs: [] };
}

function saveWeekPlan(plan: WeekPlan): void {
  localStorage.setItem(WEEK_KEY(plan.weekStartDate), JSON.stringify(plan));
}

export function useWeekPlan(weekStart: string) {
  const [weekPlan, setWeekPlan] = useState<WeekPlan>(() => loadWeekPlan(weekStart));

  // Reload when weekStart changes (week navigation)
  useEffect(() => {
    setWeekPlan(loadWeekPlan(weekStart));
  }, [weekStart]);

  const updateRuns = useCallback((runs: ScheduledRunWithDistance[]) => {
    setWeekPlan(prev => {
      const updated: WeekPlan = { ...prev, runs };
      saveWeekPlan(updated);
      return updated;
    });
  }, []);

  return { weekPlan, updateRuns };
}

// ─── Computed Helpers ────────────────────────────────────────────────────────

/** Filter activities to those whose completionDate falls within the given week (Mon–Sun) */
export function getWeekActivities(activities: Activity[], weekStartISO: string): Activity[] {
  const start = new Date(weekStartISO + 'T00:00:00');
  const end = new Date(start);
  end.setDate(end.getDate() + 7);
  return activities.filter(a => {
    const d = new Date(a.completionDate + 'T00:00:00');
    return d >= start && d < end;
  });
}

/** Filter activities to those completed in the last N days (inclusive of today) */
export function getRecentActivities(activities: Activity[], days: number): Activity[] {
  const cutoff = daysAgo(todayISO(), days - 1);
  return activities.filter(a => a.completionDate >= cutoff);
}

/** Filter activities to those completed today */
export function getTodayActivities(activities: Activity[]): Activity[] {
  const today = todayISO();
  return activities.filter(a => a.completionDate === today);
}

/** Sum total miles across a list of activities */
export function totalMiles(activities: Activity[]): number {
  return activities.reduce((sum, a) => sum + a.distanceMiles, 0);
}

/** Average pace across a list of activities, formatted "M:SS/mi" */
export function avgPaceFormatted(activities: Activity[]): string {
  if (activities.length === 0) return '--:--';
  const totalDist = totalMiles(activities);
  if (totalDist === 0) return '--:--';
  const totalSecs = activities.reduce((sum, a) => sum + a.durationSeconds, 0);
  return formatPace(totalSecs / totalDist);
}

/** Average pace in seconds per mile */
export function avgPaceSeconds(activities: Activity[]): number {
  if (activities.length === 0) return 0;
  const totalDist = totalMiles(activities);
  if (totalDist === 0) return 0;
  const totalSecs = activities.reduce((sum, a) => sum + a.durationSeconds, 0);
  return totalSecs / totalDist;
}

/** Most recent activity by completionDate, or null */
export function mostRecentActivity(activities: Activity[]): Activity | null {
  if (activities.length === 0) return null;
  return [...activities].sort((a, b) => b.completionDate.localeCompare(a.completionDate))[0];
}

/** % of planned runs completed this week (by category match) */
export function weekPlanCompletion(
  activities: Activity[],
  weekPlan: WeekPlan,
  weekStartISO: string
): number {
  const weekActs = getWeekActivities(activities, weekStartISO);
  const planned = weekPlan.runs;
  if (planned.length === 0) return 0;

  // Map RunType → RunCategory for comparison
  const typeToCategory: Record<string, string> = {
    easy: 'easy',
    tempo: 'tempo',
    longRun: 'long',
    race: 'race',
  };

  let matched = 0;
  const usedActIds = new Set<string>();

  for (const run of planned) {
    const cat = typeToCategory[run.type];
    const match = weekActs.find(a => a.category === cat && !usedActIds.has(a.id));
    if (match) {
      matched++;
      usedActIds.add(match.id);
    }
  }

  return Math.round((matched / planned.length) * 100);
}

/** Group activities by day-of-week for chart data */
export function activitiesByDayOfWeek(activities: Activity[], weekStartISO: string) {
  const days = ['M', 'T', 'W', 'R', 'F', 'S', 'S'];
  return days.map((label, i) => {
    const dayISO = (() => {
      const d = new Date(weekStartISO + 'T00:00:00');
      d.setDate(d.getDate() + i);
      return d.toISOString().split('T')[0];
    })();
    const dayActs = activities.filter(a => a.completionDate === dayISO);
    const dist = Math.round(totalMiles(dayActs) * 10) / 10;
    const pace = avgPaceSeconds(dayActs);
    return { day: label, distance: dist, pace: pace > 0 ? Math.round(pace / 6) / 10 : 0 };
  });
}

/** Get this week's Monday */
export { getCurrentWeekStart, getWeekStart };
