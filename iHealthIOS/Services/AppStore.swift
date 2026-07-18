import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var currentUser: UserAccount?
    @Published var medications: [Medication] = [] { didSet { persist() } }
    @Published var appointments: [Appointment] = [] { didSet { persist() } }
    @Published var symptoms: [Symptom] = [] { didSet { persist() } }
    @Published var medicalProfile = MedicalProfile() { didSet { persist() } }
    @Published var doctors: [Doctor] = [] { didSet { persist() } }

    private let defaults = UserDefaults.standard
    private let accountsKey = "ihealth.accounts"
    private let lastAccountKey = "ihealth.lastAccount"
    private var isLoading = false

    var hasSavedAccount: Bool { lastAccount != nil }
    var canUseFaceID: Bool { hasSavedAccount && BiometricAuthService.isAvailable }

    var upcomingAppointments: [Appointment] {
        appointments.filter { !$0.isCompleted && $0.date >= Date() }.sorted { $0.date < $1.date }
    }

    var activeMedications: [Medication] {
        medications.filter(\.isActive).sorted { $0.startDate < $1.startDate }
    }

    func register(name: String, email: String, password: String) throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard name.count >= 2, normalized.contains("@"), password.count >= 8 else {
            throw AppStoreError.invalidRegistration
        }
        var accounts = loadAccounts()
        guard !accounts.contains(where: { $0.email == normalized }) else {
            throw AppStoreError.accountExists
        }
        let account = UserAccount(id: UUID(), name: name.trimmingCharacters(in: .whitespaces), email: normalized)
        try KeychainService.save(password: password, for: normalized)
        accounts.append(account)
        save(accounts, key: accountsKey)
        openSession(account)
    }

    func login(email: String, password: String) throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let account = loadAccounts().first(where: { $0.email == normalized }),
              KeychainService.validate(password: password, for: normalized) else {
            throw AppStoreError.invalidCredentials
        }
        openSession(account)
    }

    func loginWithFaceID() async throws {
        guard let account = lastAccount else { throw BiometricAuthError.notAvailable }
        try await BiometricAuthService.authenticate()
        openSession(account)
    }

    func logout() {
        currentUser = nil
        isLoading = true
        medications = []
        appointments = []
        symptoms = []
        medicalProfile = MedicalProfile()
        doctors = []
        isLoading = false
    }

    func addMedication(_ medication: Medication) {
        medications.append(medication)
        Task {
            _ = await NotificationService.requestAuthorization()
            await NotificationService.schedule(medication)
        }
    }

    func removeMedication(at offsets: IndexSet) {
        offsets.map { medications[$0].id }.forEach(NotificationService.cancelMedication)
        medications.remove(atOffsets: offsets)
    }

    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        Task {
            _ = await NotificationService.requestAuthorization()
            await NotificationService.schedule(appointment)
        }
    }

    func completeAppointment(_ appointment: Appointment) {
        guard let index = appointments.firstIndex(where: { $0.id == appointment.id }) else { return }
        appointments[index].isCompleted = true
        NotificationService.cancelAppointment(appointment.id)
    }

    func removeAppointment(at offsets: IndexSet) {
        offsets.map { appointments[$0].id }.forEach(NotificationService.cancelAppointment)
        appointments.remove(atOffsets: offsets)
    }

    private func openSession(_ account: UserAccount) {
        currentUser = account
        defaults.set(account.id.uuidString, forKey: lastAccountKey)
        loadSnapshot()
    }

    private var lastAccount: UserAccount? {
        guard let rawID = defaults.string(forKey: lastAccountKey),
              let id = UUID(uuidString: rawID) else { return nil }
        return loadAccounts().first(where: { $0.id == id })
    }

    private func loadSnapshot() {
        guard let email = currentUser?.email else { return }
        isLoading = true
        let snapshot: HealthSnapshot = load(key: snapshotKey(email)) ?? HealthSnapshot()
        medications = snapshot.medications
        appointments = snapshot.appointments
        symptoms = snapshot.symptoms
        medicalProfile = snapshot.medicalProfile
        doctors = snapshot.doctors
        isLoading = false
    }

    private func persist() {
        guard !isLoading, let email = currentUser?.email else { return }
        save(
            HealthSnapshot(
                medications: medications,
                appointments: appointments,
                symptoms: symptoms,
                medicalProfile: medicalProfile,
                doctors: doctors
            ),
            key: snapshotKey(email)
        )
    }

    private func loadAccounts() -> [UserAccount] { load(key: accountsKey) ?? [] }
    private func snapshotKey(_ email: String) -> String { "ihealth.snapshot.\(email)" }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func load<T: Decodable>(key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

enum AppStoreError: LocalizedError {
    case invalidRegistration
    case accountExists
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidRegistration: "Completa los datos y usa una contraseña de al menos 8 caracteres."
        case .accountExists: "Ya existe una cuenta con este correo."
        case .invalidCredentials: "El correo o la contraseña son incorrectos."
        }
    }
}
