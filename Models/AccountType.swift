import Foundation

extension Models {
    public enum AccountType: String, Codable {
        case individual = "individual"
        case team = "team"
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = AccountType(rawValue: rawValue) ?? .individual
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
} 