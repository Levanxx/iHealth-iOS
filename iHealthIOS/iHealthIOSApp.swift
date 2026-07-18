import SwiftUI

@main
struct IHealthIOSApp: App {
    @StateObject private var store = AppStore()
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceMode)?.colorScheme)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            if store.currentUser == nil {
                AuthenticationView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.86), value: store.currentUser?.id)
    }
}
