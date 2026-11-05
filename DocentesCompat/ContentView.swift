import SwiftUI

struct ContentView: View {
    @StateObject private var store = TeacherStore()
    @State private var searchText = ""
    @State private var activeSheet: TeacherSheet?
    @State private var showDeleteError = false
    @State private var deleteErrorText = ""

    private enum TeacherSheet: Identifiable {
        case create
        case edit(TeacherRecord)

        var id: String {
            switch self {
            case .create: return "create"
            case .edit(let teacher): return teacher.id.uuidString
            }
        }
    }

    private var visibleTeachers: [TeacherRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return store.teachers }
        return store.teachers.filter { teacher in
            teacher.firstName.localizedCaseInsensitiveContains(query) ||
            teacher.lastName.localizedCaseInsensitiveContains(query) ||
            teacher.email.localizedCaseInsensitiveContains(query) ||
            teacher.specialty.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(visibleTeachers) { teacher in
                    Button {
                        activeSheet = .edit(teacher)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(teacher.firstName) \(teacher.lastName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(teacher.specialty)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(teacher.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteTeachers)
            }
            .listStyle(.plain)
            .navigationTitle("Teachers")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search teachers...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .create
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Teacher")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .create:
                    TeacherFormView(teacher: nil,
                                    onSave: store.upsert,
                                    onDelete: store.delete)
                case .edit(let teacher):
                    TeacherFormView(teacher: teacher,
                                    onSave: store.upsert,
                                    onDelete: store.delete)
                }
            }
            .alert("Could not delete teacher", isPresented: $showDeleteError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(deleteErrorText)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deleteTeachers(at offsets: IndexSet) {
        // Los índices corresponden a la lista ya filtrada, no al arreglo completo.
        let teachersToDelete = offsets.map { visibleTeachers[$0] }
        for teacher in teachersToDelete {
            do {
                try store.delete(teacher)
            } catch {
                deleteErrorText = error.localizedDescription
                showDeleteError = true
                return
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
