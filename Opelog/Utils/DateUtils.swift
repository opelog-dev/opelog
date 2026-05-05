import Foundation

enum DateUtils {
    static let calendar = Calendar.current

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Full calendar days from `start` to `end` (start-of-day based).
    static func daysBetween(start: Date, end: Date) -> Int {
        let s = startOfDay(start)
        let e = startOfDay(end)
        let days = calendar.dateComponents([.day], from: s, to: e).day ?? 0
        return max(0, days)
    }

    /// Days since opened date to reference date (inclusive of “opened today” → 0).
    static func fullCalendarDaysSinceOpened(from openedDate: Date, to reference: Date) -> Int {
        daysBetween(start: openedDate, end: reference)
    }

    /// Medium date in the user’s locale and calendar (not a fixed yyyy/MM/dd pattern).
    static func formattedDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .year()
                .month()
                .day()
                .locale(.autoupdatingCurrent)
        )
    }

    /// Locale-aware short date for archive/detail period lines (follows user region).
    static func archiveScanDate(_ date: Date) -> String {
        formattedDate(date)
    }

    static func openedDaysText(for item: OpenItem, reference: Date = Date()) -> String {
        let days = fullCalendarDaysSinceOpened(from: item.openedDate, to: reference)
        return L10n.openedDaysText(daysSinceOpened: days)
    }

    static func remainingDaysText(for item: OpenItem, reference: Date = Date()) -> String {
        let openedDays = fullCalendarDaysSinceOpened(from: item.openedDate, to: reference)
        let remaining = item.recommendedDays - openedDays
        return L10n.remainingCheckText(remainingDays: remaining)
    }

    /// Inclusive calendar days from opened through finished (both start-of-day).
    static func usedDaysInclusive(openedDate: Date, finishedDate: Date) -> Int {
        let opened = startOfDay(openedDate)
        let finished = startOfDay(finishedDate)
        let diff = calendar.dateComponents([.day], from: opened, to: finished).day ?? 0
        return max(1, diff + 1)
    }

    /// Usage days for log/report contexts.
    /// - Returns: Inclusive day count when finished date exists; otherwise elapsed days to reference date.
    static func usageDays(openedDate: Date, finishedDate: Date?, reference: Date = Date()) -> Int {
        if let finishedDate {
            return usedDaysInclusive(openedDate: openedDate, finishedDate: finishedDate)
        }
        return max(1, daysBetween(start: openedDate, end: reference) + 1)
    }
}
