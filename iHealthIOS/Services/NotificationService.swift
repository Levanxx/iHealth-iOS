import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    static func schedule(_ medication: Medication) async {
        guard medication.isActive, medication.startDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Hora de tu medicamento"
        content.body = "\(medication.name) · \(medication.dose)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION"
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: medication.startDate)
        let request = UNNotificationRequest(
            identifier: "medication-\(medication.id.uuidString)",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func schedule(_ appointment: Appointment) async {
        guard !appointment.isCompleted else { return }
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: appointment.date) ?? appointment.date
        guard reminderDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Próxima cita médica"
        content.body = "Con \(appointment.professional) en \(appointment.center)"
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let request = UNNotificationRequest(
            identifier: "appointment-\(appointment.id.uuidString)",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func cancelMedication(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["medication-\(id.uuidString)"])
    }

    static func cancelAppointment(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["appointment-\(id.uuidString)"])
    }
}
