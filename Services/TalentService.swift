import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// MARK: - Errors
enum CustomFirebaseError: LocalizedError {
    case invalidId
    case decodingError
    case encodingError
    case documentNotFound
    case unauthorized
    case transactionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidId:
            return "Invalid document ID"
        case .decodingError:
            return "Failed to decode document"
        case .encodingError:
            return "Failed to encode document"
        case .documentNotFound:
            return "Document not found"
        case .unauthorized:
            return "Unauthorized access"
        case .transactionFailed:
            return "Failed to complete transaction"
        }
    }
}

actor TalentService {
    static let shared = TalentService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Onboarding
    func completeOnboarding(_ data: Models.OnboardingData) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        let workspaceRef = db.collection("workspaces").document()
        
        let workspace = Models.Workspace(
            id: workspaceRef.documentID,
            workspaceName: data.workspaceInfo.name,
            industries: Array(data.workspaceInfo.industries),
            location: data.workspaceInfo.location,
            ownerId: user.uid,
            type: data.accountType,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await workspaceRef.setData(from: workspace)
        
        try await db.collection("users").document(user.uid).updateData([
            "workspaceId": workspaceRef.documentID,
            "accountType": data.accountType.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - Basic CRUD Operations
    func createTalent(_ talent: Models.Talent) async throws -> String {
        let docRef = db.collection("talents").document()
        try await docRef.setData(from: talent)
        return docRef.documentID
    }
    
    func getTalent(id: String) async throws -> Models.Talent {
        let docRef = db.collection("talents").document(id)
        let document = try await docRef.getDocument()
        
        guard let talent = try? document.data(as: Models.Talent.self) else {
            throw CustomFirebaseError.decodingError
        }
        return talent
    }
    
    func getTalents(forWorkspace workspaceId: String) async throws -> [Models.Talent] {
        let snapshot = try await db.collection("talents")
            .whereField("workspaceId", isEqualTo: workspaceId)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Models.Talent.self)
        }
    }
    
    func updateTalent(_ talent: Models.Talent) async throws {
        guard let id = talent.id else {
            throw CustomFirebaseError.invalidId
        }
        try await db.collection("talents").document(id).setData(from: talent, merge: true)
    }
    
    func deleteTalent(id: String) async throws {
        try await db.collection("talents").document(id).delete()
    }
} 