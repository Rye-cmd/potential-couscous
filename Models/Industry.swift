import Foundation

extension Models {
    public enum Industry: String, Codable, Hashable, CaseIterable, Identifiable {
        case modeling = "modeling"
        case actingPerformance = "acting_performance"
        case musicEntertainment = "music_entertainment"
        case sportsAthletics = "sports_athletics"
        case influencersContent = "influencers_content"
        case creativeFreelancers = "creative_freelancers"
        case eventsHospitality = "events_hospitality"
        case other = "other"
        
        public var id: String { rawValue }
        public var name: String {
            switch self {
            case .modeling: return "Modeling"
            case .actingPerformance: return "Acting & Performance"
            case .musicEntertainment: return "Music & Entertainment"
            case .sportsAthletics: return "Sports & Athletics"
            case .influencersContent: return "Influencers & Content Creators"
            case .creativeFreelancers: return "Creative Freelancers"
            case .eventsHospitality: return "Events & Hospitality"
            case .other: return "Other"
            }
        }
        
        // Helper for default industry
        public static var defaultIndustry: Industry {
            .modeling
        }
    }
}
