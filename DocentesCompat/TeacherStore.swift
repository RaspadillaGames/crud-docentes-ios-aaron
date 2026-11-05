import Foundation
import Combine
import CoreData

/// Persistencia local compatible con Xcode 13 / iOS 15.
final class TeacherStore: ObservableObject {
    @Published private(set) var teachers: [TeacherRecord] = []
    private let context: NSManagedObjectContext

    init() {
        context = PersistenceController.shared.container.viewContext
        refresh()
    }

    private func fetchEntities() throws -> [TeacherEntity] {
        let request = NSFetchRequest<TeacherEntity>(entityName: "TeacherEntity")
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastName", ascending: true),
            NSSortDescriptor(key: "firstName", ascending: true)
        ]
        return try context.fetch(request)
    }

    func refresh() {
        do {
            teachers = try fetchEntities().map { item in
                TeacherRecord(id: item.id,
                              firstName: item.firstName,
                              lastName: item.lastName,
                              email: item.email,
                              phone: item.phone,
                              dateOfBirth: item.dateOfBirth,
                              specialty: item.specialty,
                              hireDate: item.hireDate,
                              isActive: item.isActive)
            }
        } catch {
            print("Read error: \(error.localizedDescription)")
        }
    }

    func upsert(_ record: TeacherRecord) throws {
        let existing = try fetchEntities().first { $0.id == record.id }
        let item = existing ?? TeacherEntity(context: context)
        item.id = record.id
        item.firstName = record.firstName
        item.lastName = record.lastName
        item.email = record.email
        item.phone = record.phone
        item.dateOfBirth = record.dateOfBirth
        item.specialty = record.specialty
        item.hireDate = record.hireDate
        item.isActive = record.isActive
        do {
            try context.save()
            refresh()
        } catch {
            context.rollback()
            throw error
        }
    }

    func delete(_ record: TeacherRecord) throws {
        guard let item = try fetchEntities().first(where: { $0.id == record.id }) else {
            return
        }
        context.delete(item)
        do {
            try context.save()
            refresh()
        } catch {
            context.rollback()
            throw error
        }
    }
}
