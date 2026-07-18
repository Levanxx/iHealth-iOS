import Foundation

struct UserAccount: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
}

struct Medication: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dose: String
    var startDate: Date
    var endDate: Date
    var intervalHours: Int
    var instructions: String
    var isActive: Bool
}

struct Appointment: Identifiable, Codable, Equatable {
    let id: UUID
    var specialty: String
    var professional: String
    var center: String
    var date: Date
    var notes: String
    var isCompleted: Bool
}

struct Symptom: Identifiable, Codable, Equatable {
    let id: UUID
    var type: String
    var location: String
    var intensity: Int
    var date: Date
    var details: String
}

struct MedicalProfile: Codable, Equatable {
    var sex = ""
    var chronicConditions = ""
    var allergies = ""
    var previousSurgeries = ""
    var currentMedication = ""
}

struct Doctor: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var phone: String
    var specialty: String
}

struct HealthSnapshot: Codable {
    var medications: [Medication] = []
    var appointments: [Appointment] = []
    var symptoms: [Symptom] = []
    var medicalProfile = MedicalProfile()
    var doctors: [Doctor] = []
}
