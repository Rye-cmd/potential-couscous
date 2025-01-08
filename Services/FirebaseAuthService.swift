import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws -> (User, String) {
        do {
            // 1. Create Auth user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = authResult.user.uid
            
            // 2. Create workspace
            let workspaceRef = db.collection("workspaces").document()
            let workspaceId = workspaceRef.documentID
            
            // Use a batch write to ensure all documents are created
            let batch = db.batch()
            
            // 3. Set workspace data
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
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            batch.setData(userData, forDocument: userRef)
            
            // 5. Commit the batch
            try await batch.commit()
            
            // 6. Create and return user model
            let user = User(
                id: userId,
                email: email,
                name: "",
                role: .admin,
                workspaceId: workspaceId,
                isOnboarding: true,
                profileImageUrl: nil
            )
            
            return (user, workspaceId)
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Log In
    func logIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Successfully logged in user: \(result.user.uid)")
        } catch let error as NSError {
            if error.domain == AuthErrorDomain {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    throw AuthError.invalidCredentials
                case AuthErrorCode.userNotFound.rawValue:
                    throw AuthError.userNotFound
                default:
                    throw AuthError.other(error)
                }
            }
            throw error
        }
    }
    
    // MARK: - Update Methods
    func updateWorkspace(workspaceId: String, data: [String: Any]) async throws {
        var updatedData = data
        updatedData["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection("workspaces").document(workspaceId).updateData(updatedData)
    }
    
    func updateUserProfile(userId: String, data: [String: Any]) async throws {
        var updatedData = data
        updatedData["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection("users").document(userId).updateData(updatedData)
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case invalidCredentials
    case userNotFound
    case signUpFailed(String)
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email address is already in use. Please try signing in instead."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Your password must be at least 6 characters long."
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .userNotFound:
            return "No account found with this email. Please sign up first."
        case .signUpFailed(let message):
            return "Failed to sign up: \(message)"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
