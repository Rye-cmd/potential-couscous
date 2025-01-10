import Foundation
import FirebaseFirestore

extension Models {
    public struct OnboardingData {
        // Main properties
        public var accountType: AccountType = .solo
        public var personalInfo: PersonalInfo = .init()
        public var workspaceInfo: WorkspaceInfo = .init()
        public var teamInvites: [TeamInvite] = []
        
        // Personal Info structure
        public struct PersonalInfo {
            public var fullName: String = ""
            public var role: String = ""
            
            public var isComplete: Bool {
                !fullName.isEmpty && !role.isEmpty
            }
        }
        
        // Workspace Info structure
        public struct WorkspaceInfo {
            public var name: String = ""
            public var industries: Set<Models.Industry> = []
            public var location: String = ""
            
            public var isComplete: Bool {
                !name.isEmpty && !industries.isEmpty
            }
        }
        
        // Team Invite structure
        public struct TeamInvite {
            public var email: String
            public var role: String
            public var status: InviteStatus = .pending
            
            public enum InviteStatus: String, Codable {
                case pending
                case sent
                case accepted
                case declined
            }
        }
        
        // Account Type enum
        public enum AccountType: String, Codable {
            case solo
            case team
            
            var description: String {
                switch self {
                case .solo:
                    return "Work on your own for now—you can invite collaborators later"
                case .team:
                    return "Set up your workspace and invite your team"
                }
            }
        }
        
        // Helper methods
        public var isComplete: Bool {
            personalInfo.isComplete &&
            workspaceInfo.isComplete &&
            (accountType == .solo || !teamInvites.isEmpty)
        }
        
        // Firebase conversion helpers
        public func toFirestore() -> [String: Any] {
            let timestamp = Timestamp()
            return [
                "accountType": accountType.rawValue,
                "name": personalInfo.fullName,
                "role": personalInfo.role,
                "workspaceName": workspaceInfo.name,
                "industries": Array(workspaceInfo.industries).map(\.rawValue),
                "isOnboarding": false,
                "updatedAt": timestamp
            ]
        }
        
        public func workspaceData() -> [String: Any] {
            let timestamp = Timestamp()
            return [
                "name": workspaceInfo.name,
                "industries": Array(workspaceInfo.industries).map(\.rawValue),
                "type": accountType.rawValue,
                "createdAt": timestamp,
                "updatedAt": timestamp
            ]
        }
        
        public func inviteData(_ invite: TeamInvite) -> [String: Any] {
            let timestamp = Timestamp()
            return [
                "email": invite.email,
                "role": invite.role,
                "status": invite.status.rawValue,
                "createdAt": timestamp
            ]
        }
        
        // Computed properties for AdminSetupView
        public var adminName: String {
            get { personalInfo.fullName }
            set { personalInfo.fullName = newValue }
        }
        
        public var workspaceName: String {
            get { workspaceInfo.name }
            set { workspaceInfo.name = newValue }
        }
        
        public var selectedIndustries: Set<Models.Industry> {
            get { workspaceInfo.industries }
            set { workspaceInfo.industries = newValue }
        }
        
        public var location: String {
            get { workspaceInfo.location }
            set { workspaceInfo.location = newValue }
        }
    }
}

// Empty state constructor
extension Models.OnboardingData {
    public static func empty() -> Self {
        .init()
    }
}
