import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            List {
                Section {
                    NavigationLink { ContactsView() } label: {
                        Label("Contactos médicos", systemImage: "message.fill")
                    }
                } header: { Text("Comunicación") }

                Section("Apariencia") {
                    ForEach(AppearanceMode.allCases) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) { appearanceMode = mode.rawValue }
                        } label: {
                            HStack {
                                Label(mode.title, systemImage: mode.icon)
                                Spacer()
                                if appearanceMode == mode.rawValue {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(IHealthTheme.violet)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("Cuenta") {
                    LabeledContent("Nombre", value: store.currentUser?.name ?? "")
                    LabeledContent("Correo", value: store.currentUser?.email ?? "")
                    Button("Cerrar sesión", role: .destructive) { store.logout() }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Más")
    }
}
