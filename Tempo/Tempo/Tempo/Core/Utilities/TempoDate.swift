import Foundation

enum TempoDate {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        calendar.firstWeekday = 2
        return calendar
    }()

    static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static func isoDate(from isoString: String) -> Date? {
        isoFormatter.date(from: isoString)
    }

    static func isoString(from date: Date) -> String {
        isoFormatter.string(from: date)
    }

    static func weekStart(for date: Date) -> String {
        let normalizedDate = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: normalizedDate)
        let shift = weekday == 1 ? -6 : 2 - weekday
        guard let monday = calendar.date(byAdding: .day, value: shift, to: normalizedDate) else {
            return isoString(from: normalizedDate)
        }

        return isoString(from: monday)
    }

    static func currentWeekStart() -> String {
        weekStart(for: Date())
    }

    static func shiftWeek(_ weekStartDate: String, by delta: Int) -> String {
        guard
            let weekDate = isoDate(from: weekStartDate),
            let shiftedDate = calendar.date(byAdding: .day, value: delta * 7, to: weekDate)
        else {
            return weekStartDate
        }

        return isoString(from: shiftedDate)
    }

    static func weekLabel(for weekStartDate: String) -> String {
        guard
            let startDate = isoDate(from: weekStartDate),
            let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)
        else {
            return weekStartDate
        }

        return "\(monthDayFormatter.string(from: startDate)) - \(monthDayFormatter.string(from: endDate))"
    }

    static func todayISO() -> String {
        isoString(from: Date())
    }
}
