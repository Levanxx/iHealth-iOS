import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Sistema"
        case .light: "Claro"
        case .dark: "Oscuro"
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum IHealthTheme {
    static let violet = Color(red: 0.43, green: 0.16, blue: 0.85)
    static let purple = Color(red: 0.58, green: 0.20, blue: 0.92)
    static let lavender = Color(red: 0.75, green: 0.52, blue: 0.98)
    static let gradient = LinearGradient(
        colors: [violet, purple, lavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AnimatedGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .systemGroupedBackground)
            Circle()
                .fill(IHealthTheme.violet.opacity(colorScheme == .dark ? 0.34 : 0.18))
                .frame(width: 430, height: 430)
                .blur(radius: 70)
                .offset(x: animate ? 150 : -140, y: animate ? -250 : -70)
            Circle()
                .fill(IHealthTheme.lavender.opacity(colorScheme == .dark ? 0.22 : 0.20))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: animate ? -150 : 120, y: animate ? 280 : 160)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(colorScheme == .dark ? 0.10 : 0.50), lineWidth: 1)
            }
            .shadow(color: IHealthTheme.violet.opacity(colorScheme == .dark ? 0.18 : 0.10), radius: 20, y: 8)
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassCardModifier()) }
}
