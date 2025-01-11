import Foundation
import FirebaseFirestore

extension Models {
    struct OnboardingData: Codable {
        var accountType: AccountType = .individual
        var personalInfo = PersonalInfo()
        var workspaceInfo = WorkspaceInfo()
        var teamInvites: [TeamInvite] = []
        
        // Nested types need to be moved outside for proper Codable conformance
        enum CodingKeys: String, CodingKey {
            case accountType
            case personalInfo
            case workspaceInfo
            case teamInvites
        }
    }
    
    struct TeamInvite: Codable, Identifiable {
        var id = UUID()
        var email: String
        var role: String
        var status: InviteStatus
        
        enum InviteStatus: String, Codable {
            case pending
            case accepted
            case declined
        }
    }
}

// Move nested types outside
extension Models {
    struct PersonalInfo: Codable {
        var name: String = ""
        var email: String = ""
        var phone: String = ""
        
        enum CodingKeys: String, CodingKey {
            case name
            case email
            case phone
        }
    }
    
    struct WorkspaceInfo: Codable {
        var name: String = ""
        var industries: Set<Industry> = []
        var location: String = ""
        var type: Models.AccountType = .individual
        
        enum CodingKeys: String, CodingKey {
            case name
            case industries
            case location
            case type
        }
    }
}

// Empty state constructor
extension Models.OnboardingData {
    public static func empty() -> Self {
        .init()
    }
}
