import Foundation

enum SeedData {
    static let activities: [Activity] = [
        Activity(
            name: "Morning Easy Run",
            completionDate: "2026-04-12",
            uploadDate: "2026-04-12",
            distanceMiles: 4.2,
            durationSeconds: 2394,   // ~9:31/mi
            category: .easy
        ),
        Activity(
            name: "Tempo Intervals",
            completionDate: "2026-04-10",
            uploadDate: "2026-04-10",
            distanceMiles: 6.0,
            durationSeconds: 2880,   // 8:00/mi
            category: .tempo
        ),
        Activity(
            name: "Sunday Long Run",
            completionDate: "2026-04-06",
            uploadDate: "2026-04-06",
            distanceMiles: 12.0,
            durationSeconds: 6480,   // 9:00/mi
            category: .long
        ),
        Activity(
            name: "Recovery Jog",
            completionDate: "2026-04-05",
            uploadDate: "2026-04-05",
            distanceMiles: 3.1,
            durationSeconds: 1920,   // ~10:12/mi
            category: .easy
        ),
        Activity(
            name: "Tempo Threshold",
            completionDate: "2026-04-03",
            uploadDate: "2026-04-03",
            distanceMiles: 5.5,
            durationSeconds: 2640,   // ~8:00/mi
            category: .tempo
        ),
        Activity(
            name: "Evening Easy",
            completionDate: "2026-04-01",
            uploadDate: "2026-04-01",
            distanceMiles: 4.0,
            durationSeconds: 2280,   // 9:30/mi
            category: .easy
        ),
        Activity(
            name: "Long Run — 14 Miles",
            completionDate: "2026-03-30",
            uploadDate: "2026-03-30",
            distanceMiles: 14.0,
            durationSeconds: 7620,   // ~9:05/mi
            category: .long
        ),
        Activity(
            name: "5K Race",
            completionDate: "2026-03-28",
            uploadDate: "2026-03-28",
            distanceMiles: 3.1,
            durationSeconds: 1350,   // ~7:15/mi
            category: .race
        ),
        Activity(
            name: "Shake-Out Run",
            completionDate: "2026-03-27",
            uploadDate: "2026-03-27",
            distanceMiles: 2.5,
            durationSeconds: 1500,   // 10:00/mi
            category: .easy
        ),
        Activity(
            name: "Mid-Week Tempo",
            completionDate: "2026-03-25",
            uploadDate: "2026-03-25",
            distanceMiles: 6.5,
            durationSeconds: 3120,   // ~8:00/mi
            category: .tempo
        ),
    ]
}
