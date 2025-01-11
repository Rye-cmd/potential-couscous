extension Models {
    struct PersonalInfo: Codable {
        var name: String = ""
        var email: String = ""
        var role: String = ""
        
        enum CodingKeys: String, CodingKey {
            case name
            case email
            case role
        }
        
        init() {
            self.name = ""
            self.email = ""
            self.role = ""
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            email = try container.decode(String.self, forKey: .email)
            role = try container.decode(String.self, forKey: .role)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(email, forKey: .email)
            try container.encode(role, forKey: .role)
        }
    }
} 