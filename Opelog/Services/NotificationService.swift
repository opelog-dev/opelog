import Foundation
import UserNotifications

/// Local reminders only (`UserNotifications`). One pending request per item, keyed by `persistentModelID`.
enum NotificationService {
    /// Prompts only while authorization is `notDetermined` (system shows the dialog at most once).
    static func requestPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    /// Requests authorization (e.g. after user enables reminders in Settings). Safe to call repeatedly.
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Schedules a single non-repeating notification on the item’s target calendar day at the user’s default reminder time (local).
    static func scheduleReminder(for item: OpenItem) {
        guard item.notificationEnabled, !item.isArchived else { return }

        let targetStart = DateUtils.startOfDay(item.targetDate)
        let todayStart = DateUtils.startOfDay(Date())
        if targetStart < todayStart {
            return
        }

        let calendar = Calendar.current
        let h = ReminderTimeSettings.hour
        let m = ReminderTimeSettings.minute
        guard let fireDate = calendar.date(bySettingHour: h, minute: m, second: 0, of: targetStart) else {
            return
        }
        if fireDate <= Date() {
            return
        }

        let daysForBody = DateUtils.fullCalendarDaysSinceOpened(from: item.openedDate, to: targetStart)

        let content = UNMutableNotificationContent()
        content.title = L10n.notifReminderTitle
        content.body = L10n.notifReminderBody(itemName: item.name, daysOpened: daysForBody)
        content.sound = .default

        let interval = fireDate.timeIntervalSinceNow
        guard interval > 1 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let id = notificationId(for: item)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                return
            }
            UNUserNotificationCenter.current().add(request) { _ in }
        }
    }

    /// Idempotent reschedule: clears any stale request, then schedules if still applicable.
    static func refreshReminder(for item: OpenItem) {
        cancelReminder(for: item)
        guard item.notificationEnabled, !item.isArchived else { return }
        scheduleReminder(for: item)
    }

    static func cancelReminder(for item: OpenItem) {
        cancelReminders(identifiers: [notificationId(for: item)])
    }

    static func cancelReminders(identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    static func notificationId(for item: OpenItem) -> String {
        "opelog.item.\(String(describing: item.persistentModelID))"
    }
}
