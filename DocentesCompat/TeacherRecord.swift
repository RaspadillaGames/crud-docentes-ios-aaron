import Foundation

/// Datos compartidos por ambas implementaciones de persistencia.
struct TeacherRecord: Identifiable, Equatable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var dateOfBirth: Date
    var specialty: String
    var hireDate: Date
    var isActive: Bool

    init(id: UUID = UUID(),
         firstName: String = "",
         lastName: String = "",
         email: String = "",
         phone: String = "",
         dateOfBirth: Date = Date(),
         specialty: String = "",
         hireDate: Date = Date(),
         isActive: Bool = true) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.specialty = specialty
        self.hireDate = hireDate
        self.isActive = isActive
    }
}
