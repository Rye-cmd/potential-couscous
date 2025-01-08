import Foundation

extension Models {
    public struct Workspace: Codable, Identifiable {
        public let id: String
        public let workspaceName: String
        public let industries: [Models.Industry]
        public let location: String
        public let ownerId: String
        public let createdAt: Date?
        public let updatedAt: Date?
        
        public var primaryIndustry: Models.Industry {
            industries.first ?? .modeling
        }
        
        public init(
            id: String,
            workspaceName: String,
            industries: [Models.Industry],
            location: String,
            ownerId: String,
            createdAt: Date?,
            updatedAt: Date?
        ) {
            self.id = id
            self.workspaceName = workspaceName
            self.industries = industries
            self.location = location
            self.ownerId = ownerId
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

extension Models.Workspace {
    public static func mock() -> Self {
        .init(
            id: "mock-id",
            workspaceName: "Mock Workspace",
            industries: [Models.Industry.modeling],
            location: "United States",
            ownerId: "mock-owner-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
