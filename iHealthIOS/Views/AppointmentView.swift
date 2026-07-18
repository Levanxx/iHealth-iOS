import SwiftUI

struct AppointmentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showsForm = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            if store.appointments.isEmpty {
                EmptyStateView(icon: "calendar.badge.plus", title: "Sin citas", message: "Agenda una cita y recibe una alerta una hora antes.")
                    .padding(20)
            } else {
                List {
                    ForEach(store.appointments) { appointment in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(appointment.specialty, systemImage: "stethoscope")
                                    .font(.headline)
                                Spacer()
                                if appointment.isCompleted {
                                    Text("Completada").font(.caption.weight(.semibold)).foregroundStyle(.green)
                                }
                            }
                            Text(appointment.professional)
                            Text(appointment.center).foregroundStyle(.secondary)
                            Text(appointment.date.healthDateTime).font(.subheadline).foregroundStyle(IHealthTheme.violet)
                            if !appointment.isCompleted {
                                Button("Marcar como completada") { store.completeAppointment(appointment) }
                                    .font(.caption.weight(.semibold))
                            }
                        }
                        .glassCard()
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: store.removeAppointment)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Citas")
        .toolbar { Button { showsForm = true } label: { Image(systemName: "plus.circle.fill") } }
        .sheet(isPresented: $showsForm) { AppointmentForm() }
    }
}

private struct AppointmentForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var specialty = "Medicina general"
    @State private var professional = ""
    @State private var center = ""
    @State private var date = Date().addingTimeInterval(7200)
    @State private var notes = ""
    private let specialties = ["Medicina general", "Cardiología", "Dermatología", "Odontología", "Pediatría", "Psicología", "Nutrición", "Otra"]

    var body: some View {
        NavigationStack {
            Form {
                Picker("Especialidad", selection: $specialty) {
                    ForEach(specialties, id: \.self) { Text($0) }
                }
                TextField("Profesional", text: $professional)
                TextField("Centro médico", text: $center)
                DatePicker("Fecha y hora", selection: $date, in: Date()...)
                TextField("Notas", text: $notes, axis: .vertical)
            }
            .navigationTitle("Nueva cita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        store.addAppointment(Appointment(id: UUID(), specialty: specialty, professional: professional, center: center, date: date, notes: notes, isCompleted: false))
                        dismiss()
                    }
                    .disabled(professional.isEmpty || center.isEmpty)
                }
            }
        }
    }
}
