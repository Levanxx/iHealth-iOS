import SwiftUI

struct AuthenticationView: View {
    @State private var showsRegistration = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 48)
                    VStack(spacing: 14) {
                        Image(systemName: "heart.text.clipboard.fill")
                            .font(.system(size: 58, weight: .medium))
                            .foregroundStyle(IHealthTheme.gradient)
                            .symbolEffect(.pulse, options: .repeating)
                        Text("iHealth")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text("Organiza tu salud en un solo lugar")
                            .foregroundStyle(.secondary)
                    }
                    if showsRegistration {
                        RegistrationForm(showsRegistration: $showsRegistration)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        LoginForm(showsRegistration: $showsRegistration)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.86), value: showsRegistration)
    }
}

private struct LoginForm: View {
    @EnvironmentObject private var store: AppStore
    @Binding var showsRegistration: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Correo electrónico", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
            SecureField("Contraseña", text: $password)
                .textContentType(.password)
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
            if !error.isEmpty {
                Text(error).font(.footnote).foregroundStyle(.red)
            }
            Button("Iniciar sesión") {
                do { try store.login(email: email, password: password) }
                catch { self.error = error.localizedDescription }
            }
            .buttonStyle(GradientButtonStyle())
            Button("Crear una cuenta") { showsRegistration = true }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(IHealthTheme.violet)
        }
        .glassCard()
    }
}

private struct RegistrationForm: View {
    @EnvironmentObject private var store: AppStore
    @Binding var showsRegistration: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Nombre", text: $name).textContentType(.name)
                .padding(14).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
            TextField("Correo electrónico", text: $email)
                .textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                .padding(14).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
            SecureField("Contraseña de 8 caracteres", text: $password).textContentType(.newPassword)
                .padding(14).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
            if !error.isEmpty { Text(error).font(.footnote).foregroundStyle(.red) }
            Button("Registrarme") {
                do { try store.register(name: name, email: email, password: password) }
                catch { self.error = error.localizedDescription }
            }
            .buttonStyle(GradientButtonStyle())
            Button("Ya tengo una cuenta") { showsRegistration = false }
                .font(.subheadline.weight(.semibold)).foregroundStyle(IHealthTheme.violet)
        }
        .glassCard()
    }
}
