import UserNotifications

final class ReminderNotifier {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { _, _ in
        }
    }

    func sendStandUpReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Get Up Stand Up 🎶"
        content.body = "Time for a stretch break."

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
