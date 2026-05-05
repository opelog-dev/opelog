import Foundation

/// Global default hour/minute for local reminders (check day). Persisted in `UserDefaults`.
enum ReminderTimeSettings {
    private static let hourKey = "opelog.defaultReminderHour"
    private static let minuteKey = "opelog.defaultReminderMinute"

    private static let registration: Void = {
        UserDefaults.standard.register(defaults: [
            hourKey: 10,
            minuteKey: 0,
        ])
    }()

    /// Call once at launch so `UserDefaults` defaults exist before `@AppStorage` reads.
    static func bootstrap() {
        _ = registration
    }

    static var hour: Int {
        _ = registration
        let h = UserDefaults.standard.integer(forKey: hourKey)
        return min(23, max(0, h))
    }

    static var minute: Int {
        _ = registration
        let m = UserDefaults.standard.integer(forKey: minuteKey)
        return min(59, max(0, m))
    }

    static func set(hour: Int, minute: Int) {
        _ = registration
        UserDefaults.standard.set(min(23, max(0, hour)), forKey: hourKey)
        UserDefaults.standard.set(min(59, max(0, minute)), forKey: minuteKey)
    }

    /// Short time string for the current locale (e.g. 10:00 AM or 10:00).
    static func formattedTimeString(locale: Locale = .autoupdatingCurrent) -> String {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        guard let date = Calendar.current.date(from: comps) else {
            return String(format: "%d:%02d", hour, minute)
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
