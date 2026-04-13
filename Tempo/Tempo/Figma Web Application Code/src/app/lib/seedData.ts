import { Activity } from './types';

/**
 * Realistic seed activities for the past 3 weeks.
 * Used as fallback when no user data exists in localStorage.
 * Today = April 13, 2026 (Sunday).
 */
export const SEED_ACTIVITIES: Activity[] = [
  // — Two weeks ago (Mar 24–30) —
  {
    id: 'seed-1',
    name: 'Morning Easy Run',
    completionDate: '2026-03-24',
    uploadDate: '2026-03-24',
    distanceMiles: 4.5,
    durationSeconds: 2520,          // 42:00
    avgPaceSecondsPerMile: 560,     // 9:20/mi
    category: 'easy',
  },
  {
    id: 'seed-2',
    name: 'Tempo Workout',
    completionDate: '2026-03-26',
    uploadDate: '2026-03-26',
    distanceMiles: 3.0,
    durationSeconds: 1320,          // 22:00
    avgPaceSecondsPerMile: 440,     // 7:20/mi
    category: 'tempo',
  },
  {
    id: 'seed-3',
    name: 'Weekend Long Run',
    completionDate: '2026-03-28',
    uploadDate: '2026-03-28',
    distanceMiles: 10.0,
    durationSeconds: 6000,          // 1:40:00
    avgPaceSecondsPerMile: 600,     // 10:00/mi
    category: 'long',
  },

  // — Last week (Mar 31–Apr 6) —
  {
    id: 'seed-4',
    name: 'Easy Recovery Run',
    completionDate: '2026-03-31',
    uploadDate: '2026-03-31',
    distanceMiles: 5.0,
    durationSeconds: 2760,          // 46:00
    avgPaceSecondsPerMile: 552,     // 9:12/mi
    category: 'easy',
  },
  {
    id: 'seed-5',
    name: 'Track Tempo Intervals',
    completionDate: '2026-04-02',
    uploadDate: '2026-04-02',
    distanceMiles: 4.0,
    durationSeconds: 1740,          // 29:00
    avgPaceSecondsPerMile: 435,     // 7:15/mi
    category: 'tempo',
  },
  {
    id: 'seed-6',
    name: '5K Race',
    completionDate: '2026-04-04',
    uploadDate: '2026-04-04',
    distanceMiles: 3.1,
    durationSeconds: 1380,          // 23:00
    avgPaceSecondsPerMile: 445,     // 7:25/mi
    category: 'race',
  },
  {
    id: 'seed-7',
    name: 'Sunday Long Run',
    completionDate: '2026-04-06',
    uploadDate: '2026-04-06',
    distanceMiles: 8.0,
    durationSeconds: 4440,          // 1:14:00
    avgPaceSecondsPerMile: 555,     // 9:15/mi
    category: 'long',
  },

  // — This week (Apr 7–13) —
  {
    id: 'seed-8',
    name: 'Easy Shakeout',
    completionDate: '2026-04-08',
    uploadDate: '2026-04-08',
    distanceMiles: 4.0,
    durationSeconds: 2220,          // 37:00
    avgPaceSecondsPerMile: 555,     // 9:15/mi
    category: 'easy',
  },
  {
    id: 'seed-9',
    name: 'Tempo Run',
    completionDate: '2026-04-10',
    uploadDate: '2026-04-10',
    distanceMiles: 3.5,
    durationSeconds: 1500,          // 25:00
    avgPaceSecondsPerMile: 429,     // 7:09/mi
    category: 'tempo',
  },
  {
    id: 'seed-10',
    name: 'Easy Morning Run',
    completionDate: '2026-04-12',
    uploadDate: '2026-04-12',
    distanceMiles: 5.5,
    durationSeconds: 3120,          // 52:00
    avgPaceSecondsPerMile: 567,     // 9:27/mi
    category: 'easy',
  },
];
