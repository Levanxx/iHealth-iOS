import LocalAuthentication

enum BiometricAuthService {
    static var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    static func authenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricAuthError.notAvailable
        }

        let authenticated = try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Usa Face ID para ingresar a iHealth"
        )

        guard authenticated else { throw BiometricAuthError.failed }
    }
}

enum BiometricAuthError: LocalizedError {
    case notAvailable
    case failed

    var errorDescription: String? {
        switch self {
        case .notAvailable: "Face ID no está disponible o no está configurado."
        case .failed: "No se pudo verificar tu identidad."
        }
    }
}
