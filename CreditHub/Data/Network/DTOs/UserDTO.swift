import Foundation

struct UserDTO: Codable {
    let id: String
    let fullName: String
    let email: String
    let phoneNumber: String
    let memberSince: Date
}

extension UserDTO {
    func toDomain() -> User {
        User(id: id, fullName: fullName, email: email, phoneNumber: phoneNumber, memberSince: memberSince)
    }
}
