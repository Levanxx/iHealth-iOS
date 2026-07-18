import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var appeared = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hola, \(store.currentUser?.name ?? "")")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        Text("Así se ve tu día de salud")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)

                    HStack(spacing: 14) {
                        MetricCard(title: "Medicamentos activos", value: "\(store.activeMedications.count)", icon: "pills.fill")
                        MetricCard(title: "Próximas citas", value: "\(store.upcomingAppointments.count)", icon: "calendar.badge.clock")
                    }

                    Text("Próximos recordatorios")
                        .font(.title3.bold())

                    if store.activeMedications.isEmpty && store.upcomingAppointments.isEmpty {
                        EmptyStateView(icon: "calendar.badge.clock", title: "No hay recordatorios próximos", message: "Agrega un medicamento o una cita para comenzar.")
                    } else {
                        ForEach(store.activeMedications.prefix(3)) { medication in
                            ReminderRow(icon: "pills.fill", title: medication.name, detail: medication.dose, date: medication.startDate)
                        }
                        ForEach(store.upcomingAppointments.prefix(3)) { appointment in
                            ReminderRow(icon: "calendar", title: appointment.professional, detail: appointment.center, date: appointment.date)
                        }
                    }
                }
                .padding(20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)
            }
        }
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.85)) { appeared = true }
        }
    }
}

private struct ReminderRow: View {
    let icon: String
    let title: String
    let detail: String
    let date: Date

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(IHealthTheme.gradient, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
                Text(date.healthDateTime).font(.caption).foregroundStyle(IHealthTheme.violet)
            }
            Spacer()
        }
        .glassCard()
    }
}
