import Foundation
import CoreData

/// Modelo Core Data creado en código: no depende de archivos .xcdatamodeld.
@objc(TeacherEntity)
final class TeacherEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var phone: String
    @NSManaged var dateOfBirth: Date
    @NSManaged var specialty: String
    @NSManaged var hireDate: Date
    @NSManaged var isActive: Bool
}

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    private init() {
        let entity = NSEntityDescription()
        entity.name = "TeacherEntity"
        entity.managedObjectClassName = NSStringFromClass(TeacherEntity.self)

        func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
            let value = NSAttributeDescription()
            value.name = name
            value.attributeType = type
            value.isOptional = false
            return value
        }

        entity.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("firstName", .stringAttributeType),
            attribute("lastName", .stringAttributeType),
            attribute("email", .stringAttributeType),
            attribute("phone", .stringAttributeType),
            attribute("dateOfBirth", .dateAttributeType),
            attribute("specialty", .stringAttributeType),
            attribute("hireDate", .dateAttributeType),
            attribute("isActive", .booleanAttributeType)
        ]
        let model = NSManagedObjectModel()
        model.entities = [entity]
        container = NSPersistentContainer(name: "DocentesStore", managedObjectModel: model)

        // Almacenamiento SQLite persistente en el contenedor de la aplicación.
        let support = FileManager.default.urls(for: .applicationSupportDirectory,
                                                in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        let databaseURL = support.appendingPathComponent("DocentesStore.sqlite")
        let description = NSPersistentStoreDescription(url: databaseURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Could not load Core Data: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
