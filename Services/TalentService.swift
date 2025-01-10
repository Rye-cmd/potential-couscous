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
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CustomFirebaseError.unauthorized
        }
        
        let workspaceRef = db.collection("workspaces").document()
        let userRef = db.collection("users").document(userId)
        let invitesRef = workspaceRef.collection("invites")
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    // Create workspace
                    transaction.setData([
                        "name": data.workspaceInfo.name,
                        "industries": Array(data.workspaceInfo.industries).map(\.rawValue),
                        "type": data.accountType.rawValue,
                        "location": data.workspaceInfo.location,
                        "createdAt": FieldValue.serverTimestamp(),
                        "updatedAt": FieldValue.serverTimestamp()
                    ], forDocument: workspaceRef)
                    
                    // Update user profile
                    transaction.setData([
                        "name": data.personalInfo.fullName,
                        "role": data.personalInfo.role,
                        "workspaceId": workspaceRef.documentID,
                        "isOnboarding": false,
                        "updatedAt": FieldValue.serverTimestamp()
                    ], forDocument: userRef, merge: true)
                    
                    // Create team invites if any
                    for invite in data.teamInvites {
                        let inviteDoc = invitesRef.document()
                        transaction.setData([
                            "email": invite.email,
                            "role": invite.role,
                            "status": invite.status.rawValue,
                            "createdAt": FieldValue.serverTimestamp()
                        ], forDocument: inviteDoc)
                    }
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }) { object, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
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