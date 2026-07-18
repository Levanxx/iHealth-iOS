import SwiftUI

struct MedicationView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showsForm = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            Group {
                if store.medications.isEmpty {
                    EmptyStateView(icon: "pills.fill", title: "Sin medicamentos", message: "Registra tu tratamiento y recibe recordatorios en el momento indicado.")
                        .padding(20)
                } else {
                    List {
                        ForEach(store.medications) { medication in
                            MedicationRow(medication: medication)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: store.removeMedication)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Medicamentos")
        .toolbar {
            Button { showsForm = true } label: { Image(systemName: "plus.circle.fill") }
        }
        .sheet(isPresented: $showsForm) { MedicationForm() }
    }
}

private struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "pills.fill")
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(IHealthTheme.gradient, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name).font(.headline)
                Text("\(medication.dose) · cada \(medication.intervalHours) h")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(medication.startDate.healthDateTime)
                    .font(.caption).foregroundStyle(IHealthTheme.violet)
            }
            Spacer()
            Image(systemName: medication.isActive ? "checkmark.circle.fill" : "pause.circle.fill")
                .foregroundStyle(medication.isActive ? .green : .secondary)
        }
        .glassCard()
        .padding(.vertical, 4)
    }
}

private struct MedicationForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dose = ""
    @State private var startDate = Date().addingTimeInterval(300)
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var intervalHours = 8
    @State private var instructions = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Tratamiento") {
                    TextField("Medicamento", text: $name)
                    TextField("Dosis", text: $dose)
                    Stepper("Cada \(intervalHours) horas", value: $intervalHours, in: 1...24)
                    TextField("Instrucciones", text: $instructions, axis: .vertical)
                }
                Section("Periodo") {
                    DatePicker("Primera toma", selection: $startDate)
                    DatePicker("Fecha final", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("Nuevo medicamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        store.addMedication(
                            Medication(id: UUID(), name: name, dose: dose, startDate: startDate, endDate: endDate, intervalHours: intervalHours, instructions: instructions, isActive: true)
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || dose.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
