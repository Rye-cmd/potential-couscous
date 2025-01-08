import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let workspaceId: String
    let isOnboarding: Bool
    let profileImageUrl: String?
}

enum UserRole: String, Codable {
    case admin = "admin"
    case member = "member"
    case collaborator = "collaborator"
}

extension User {
    static var preview: User {
        User(
            id: "preview-id",
            email: "preview@example.com",
            name: "Preview User",
            role: .admin,
            workspaceId: "preview-workspace",
            isOnboarding: false,
            profileImageUrl: nil
        )
    }
}
