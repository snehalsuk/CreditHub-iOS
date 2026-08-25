import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let fullName: String
    let email: String
    let phoneNumber: String
    let memberSince: Date
}
