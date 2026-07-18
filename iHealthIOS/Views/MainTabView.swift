import SwiftUI

struct MainTabView: View {
    @State private var showsChat = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                NavigationStack { HomeView() }
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                NavigationStack { MedicationView() }
                    .tabItem { Label("Medicinas", systemImage: "pills.fill") }
                NavigationStack { AppointmentView() }
                    .tabItem { Label("Citas", systemImage: "calendar") }
                NavigationStack { HealthView() }
                    .tabItem { Label("Salud", systemImage: "heart.text.clipboard.fill") }
                NavigationStack { SettingsView() }
                    .tabItem { Label("Más", systemImage: "square.grid.2x2.fill") }
            }
            .tint(IHealthTheme.violet)
            FloatingChatButton(isPresented: $showsChat)
                .padding(.trailing, 18)
                .padding(.bottom, 74)
        }
        .sheet(isPresented: $showsChat) { ChatView() }
    }
}
