import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var showsForm = false
    @State private var selectedDoctor: Doctor?
    @State private var message = "Hola, quisiera realizar una consulta."

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            VStack(spacing: 18) {
                if store.doctors.isEmpty {
                    EmptyStateView(icon: "stethoscope", title: "Agrega un médico", message: "Guarda el número con código de país para iniciar una conversación en WhatsApp.")
                } else {
                    Picker("Médico", selection: $selectedDoctor) {
                        Text("Selecciona un médico").tag(nil as Doctor?)
                        ForEach(store.doctors) { doctor in Text(doctor.name).tag(doctor as Doctor?) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard()
                    TextField("Mensaje", text: $message, axis: .vertical)
                        .lineLimit(4...8)
                        .glassCard()
                    Button("Abrir WhatsApp") { openWhatsApp() }
                        .buttonStyle(GradientButtonStyle())
                        .disabled(selectedDoctor == nil || message.isEmpty)
                }
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Contactos médicos")
        .toolbar { Button { showsForm = true } label: { Image(systemName: "person.badge.plus") } }
        .sheet(isPresented: $showsForm) { DoctorForm() }
        .onChange(of: store.doctors) { _, doctors in
            if let selectedDoctor, !doctors.contains(selectedDoctor) { self.selectedDoctor = nil }
        }
    }

    private func openWhatsApp() {
        guard let doctor = selectedDoctor else { return }
        let phone = doctor.phone.filter(\.isNumber)
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://wa.me/\(phone)?text=\(encoded)") else { return }
        openURL(url)
    }
}

private struct DoctorForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var specialty = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $name)
                TextField("Especialidad", text: $specialty)
                TextField("Teléfono con código de país", text: $phone).keyboardType(.phonePad)
            }
            .navigationTitle("Nuevo médico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        store.doctors.append(Doctor(id: UUID(), name: name, phone: phone.filter(\.isNumber), specialty: specialty))
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.filter(\.isNumber).count < 8)
                }
            }
        }
    }
}
