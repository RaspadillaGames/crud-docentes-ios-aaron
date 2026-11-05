import SwiftUI

struct TeacherFormView: View {
    let teacher: TeacherRecord?
    let onSave: (TeacherRecord) throws -> Void
    let onDelete: (TeacherRecord) throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phone: String
    @State private var dateOfBirth: Date
    @State private var specialty: String
    @State private var hireDate: Date
    @State private var isActive: Bool
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""

    init(teacher: TeacherRecord?,
         onSave: @escaping (TeacherRecord) throws -> Void,
         onDelete: @escaping (TeacherRecord) throws -> Void) {
        self.teacher = teacher
        self.onSave = onSave
        self.onDelete = onDelete
        _firstName = State(initialValue: teacher?.firstName ?? "")
        _lastName = State(initialValue: teacher?.lastName ?? "")
        _email = State(initialValue: teacher?.email ?? "")
        _phone = State(initialValue: teacher?.phone ?? "")
        _dateOfBirth = State(initialValue: teacher?.dateOfBirth ?? Date())
        _specialty = State(initialValue: teacher?.specialty ?? "")
        _hireDate = State(initialValue: teacher?.hireDate ?? Date())
        _isActive = State(initialValue: teacher?.isActive ?? true)
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var formValid: Bool {
        let mail = clean(email)
        return !clean(firstName).isEmpty &&
               !clean(lastName).isEmpty &&
               mail.contains("@") && mail.contains(".") &&
               !clean(phone).isEmpty &&
               !clean(specialty).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PERSONAL INFORMATION")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    DatePicker("Date of Birth", selection: $dateOfBirth,
                               in: ...Date(), displayedComponents: .date)
                }

                Section(header: Text("PROFESSIONAL INFORMATION")) {
                    TextField("Specialty", text: $specialty)
                    DatePicker("Hire Date", selection: $hireDate,
                               displayedComponents: .date)
                    Toggle("Active", isOn: $isActive)
                }

                if teacher != nil {
                    Section {
                        Button("Delete Teacher", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(teacher == nil ? "Add Teacher" : "Edit Teacher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!formValid)
                }
            }
            .confirmationDialog("Delete this teacher?",
                                isPresented: $showDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Delete Teacher", role: .destructive) { remove() }
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Operation failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func save() {
        let updated = TeacherRecord(
            id: teacher?.id ?? UUID(),
            firstName: clean(firstName),
            lastName: clean(lastName),
            email: clean(email),
            phone: clean(phone),
            dateOfBirth: dateOfBirth,
            specialty: clean(specialty),
            hireDate: hireDate,
            isActive: isActive
        )
        do {
            try onSave(updated)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func remove() {
        guard let teacher = teacher else { return }
        do {
            try onDelete(teacher)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
