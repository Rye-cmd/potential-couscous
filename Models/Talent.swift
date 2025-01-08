import Foundation
import FirebaseFirestore

extension Models {
    public struct Talent: Codable, Identifiable {
        public var id: String?
        public var name: String
        public var email: String
        public var phone: String?
        public var bio: String
        public var primarySkills: [String]
        public var rate: Double
        public var status: TalentStatus
        public var workspaceId: String
        public var profileImageUrl: String?
        public var createdAt: Date
        public var updatedAt: Date
        
        public enum TalentStatus: String, Codable {
            case active
            case inactive
            case pending
        }
    }
    
    public struct PortfolioItem: Codable, Identifiable {
        public var id: String?
        public let title: String
        public let description: String
        public let mediaUrls: [String]
        public let date: Date
        public let talentId: String
        
        public init(
            id: String? = nil,
            title: String,
            description: String,
            mediaUrls: [String],
            date: Date,
            talentId: String
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.mediaUrls = mediaUrls
            self.date = date
            self.talentId = talentId
        }
    }
} 