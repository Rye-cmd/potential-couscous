import Foundation

extension Models {
    public struct OnboardingData {
        public var adminName: String
        public var workspaceName: String
        public var selectedIndustries: Set<Models.Industry>
        public var location: String
        public var categories: [String]
        
        public init(
            adminName: String = "",
            workspaceName: String = "",
            selectedIndustries: Set<Models.Industry> = [.modeling],
            location: String = "",
            categories: [String] = []
        ) {
            self.adminName = adminName
            self.workspaceName = workspaceName
            self.selectedIndustries = selectedIndustries
            self.location = location
            self.categories = categories
        }
    }
}

extension Models.OnboardingData {
    public static func empty() -> Self {
        .init(
            adminName: "",
            workspaceName: "",
            selectedIndustries: [.modeling],
            location: "",
            categories: []
        )
    }
    
    public var isComplete: Bool {
        !adminName.isEmpty &&
        !workspaceName.isEmpty &&
        !selectedIndustries.isEmpty &&
        !location.isEmpty &&
        !categories.isEmpty
    }
    
    public func toWorkspace(id: String, ownerId: String) -> Models.Workspace {
        Models.Workspace(
            id: id,
            workspaceName: workspaceName,
            industries: Array(selectedIndustries),
            location: location,
            ownerId: ownerId,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
