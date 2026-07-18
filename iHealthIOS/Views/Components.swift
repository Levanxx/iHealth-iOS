import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(IHealthTheme.gradient, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .shadow(color: IHealthTheme.violet.opacity(configuration.isPressed ? 0.12 : 0.28), radius: 14, y: 7)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(IHealthTheme.gradient)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(IHealthTheme.gradient)
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

struct FloatingChatButton: View {
    @Binding var isPresented: Bool
    @State private var pulse = false

    var body: some View {
        Button { isPresented = true } label: {
            Image(systemName: "bubble.left.and.text.bubble.right.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(IHealthTheme.gradient, in: Circle())
                .shadow(color: IHealthTheme.violet.opacity(0.45), radius: pulse ? 18 : 10)
                .scaleEffect(pulse ? 1.04 : 1)
        }
        .accessibilityLabel("Abrir asistente")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

extension Date {
    var healthDateTime: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}
