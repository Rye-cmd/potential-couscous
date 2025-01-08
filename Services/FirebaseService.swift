import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createUser(email: String, password: String) async throws -> (User, String) {
        print("Starting signup process...")
        
        // 1. Create Auth user first
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userId = authResult.user.uid
        print("User created with ID: \(userId)")
        
        do {
            // 2. Create workspace first
            let workspaceRef = db.collection("workspaces").document()
            let workspaceId = workspaceRef.documentID
            print("Workspace created with ID: \(workspaceId)")
            
            // Use a batch write to ensure both documents are created or neither is
            let batch = db.batch()
            
            // 3. Create workspace document
            let workspaceData: [String: Any] = [
                "ownerId": userId,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            batch.setData(workspaceData, forDocument: workspaceRef)
            
            // 4. Create user document
            let userRef = db.collection("users").document(userId)
            let userData: [String: Any] = [
                "email": email,
                "role": UserRole.admin.rawValue,
                "workspaceId": workspaceId,
                "isOnboarding": true,
                "name": "",
                "profileImageUrl": "",
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            batch.setData(userData, forDocument: userRef)
            
            // Commit the batch
            try await batch.commit()
            
            // 5. Create and return user object
            let user = User(
                id: userId,
                email: email,
                name: "",
                role: .admin,
                workspaceId: workspaceId,
                isOnboarding: true,
                profileImageUrl: ""
            )
            
            print("User and workspace documents created successfully")
            return (user, workspaceId)
            
        } catch {
            // If anything fails after auth creation, attempt to delete the auth user
            try? await Auth.auth().currentUser?.delete()
            throw error
        }
    }
    
    func fetchUser(withId userId: String) async throws -> User {
        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else {
            throw FirebaseError.noData
        }
        
        guard let roleString = data["role"] as? String,
              let role = UserRole(rawValue: roleString) else {
            throw FirebaseError.invalidUser
        }
        
        return User(
            id: userId,
            email: data["email"] as? String ?? "",
            name: data["name"] as? String ?? "",
            role: role,
            workspaceId: data["workspaceId"] as? String ?? "",
            isOnboarding: data["isOnboarding"] as? Bool ?? true,
            profileImageUrl: data["profileImageUrl"] as? String ?? ""
        )
    }
    
    func updateUser(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func updateUserProfileImage(userId: String, imageUrl: String) async throws {
        try await updateUser(userId: userId, data: [
            "profileImageUrl": imageUrl,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}

enum FirebaseError: Error {
    case noData
    case decodingError
    case invalidUser
    case imageUploadFailed
} 

