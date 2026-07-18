import SwiftUI

struct HealthView: View {
    @State private var selection = 0

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            VStack(spacing: 14) {
                Picker("Sección", selection: $selection) {
                    Text("Síntomas").tag(0)
                    Text("Perfil médico").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                if selection == 0 { SymptomView() } else { MedicalProfileView() }
            }
        }
        .navigationTitle("Mi salud")
    }
}

private struct SymptomView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showsForm = false

    var body: some View {
        Group {
            if store.symptoms.isEmpty {
                EmptyStateView(icon: "waveform.path.ecg", title: "Sin síntomas registrados", message: "Lleva un historial claro para compartirlo con tu médico.")
                    .padding(20)
            } else {
                List {
                    ForEach(store.symptoms.sorted { $0.date > $1.date }) { symptom in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(symptom.type).font(.headline)
                                Spacer()
                                Text("\(symptom.intensity)/10").font(.headline).foregroundStyle(IHealthTheme.violet)
                            }
                            Text(symptom.location).foregroundStyle(.secondary)
                            Text(symptom.date.formatted(date: .abbreviated, time: .omitted)).font(.caption)
                            if !symptom.details.isEmpty { Text(symptom.details).font(.subheadline) }
                        }
                        .glassCard()
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { store.symptoms.remove(atOffsets: $0) }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button { showsForm = true } label: {
                Image(systemName: "plus").font(.title2.bold()).foregroundStyle(.white)
                    .frame(width: 54, height: 54).background(IHealthTheme.gradient, in: Circle())
            }
            .padding(22)
        }
        .sheet(isPresented: $showsForm) { SymptomForm() }
    }
}

private struct SymptomForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var type = "Dolor"
    @State private var location = "Cabeza"
    @State private var intensity = 5
    @State private var date = Date()
    @State private var details = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Síntoma", selection: $type) { ForEach(["Dolor", "Fiebre", "Náuseas", "Mareo", "Tos", "Fatiga", "Otro"], id: \.self) { Text($0) } }
                TextField("Ubicación", text: $location)
                Stepper("Intensidad: \(intensity)/10", value: $intensity, in: 1...10)
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
                TextField("Descripción", text: $details, axis: .vertical)
            }
            .navigationTitle("Registrar síntoma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        store.symptoms.append(Symptom(id: UUID(), type: type, location: location, intensity: intensity, date: date, details: details))
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct MedicalProfileView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Form {
            Section("Información personal") {
                TextField("Sexo", text: $store.medicalProfile.sex)
                TextField("Enfermedades crónicas", text: $store.medicalProfile.chronicConditions, axis: .vertical)
                TextField("Alergias", text: $store.medicalProfile.allergies, axis: .vertical)
                TextField("Cirugías previas", text: $store.medicalProfile.previousSurgeries, axis: .vertical)
                TextField("Medicación actual", text: $store.medicalProfile.currentMedication, axis: .vertical)
            }
        }
        .scrollContentBackground(.hidden)
    }
}
