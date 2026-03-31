import UserNotifications

final class ReminderNotifier {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        }
    }

    func sendStandUpReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Get up stand up"
        content.body = "Stand up for your health."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
