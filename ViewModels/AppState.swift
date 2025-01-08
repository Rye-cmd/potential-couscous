import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isOnboarding = false
    @Published var errorMessage: String?
    
    init() {
        // Start with logged out state
        self.isAuthenticated = false
        self.currentUser = nil
        self.isOnboarding = false
        
        // Then setup auth listener
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let userId = user?.uid {
                    await self?.fetchCurrentUser(userId: userId)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                    self?.isOnboarding = false
                }
            }
        }
    }
    
    func fetchCurrentUser(userId: String) async {
        do {
            let db = Firestore.firestore()
            let doc = try await db.collection("users").document(userId).getDocument()
            
            guard let data = doc.data() else {
                self.errorMessage = "No user data found"
                self.isAuthenticated = false
                return
            }
            
            let roleString = data["role"] as? String ?? "member"
            let role = UserRole(rawValue: roleString) ?? .member
            
            self.currentUser = User(
                id: doc.documentID,
                email: data["email"] as? String ?? "",
                name: data["name"] as? String ?? "",
                role: role,
                workspaceId: data["workspaceId"] as? String ?? "",
                isOnboarding: data["isOnboarding"] as? Bool ?? true,
                profileImageUrl: data["profileImageUrl"] as? String
            )
            
            self.isAuthenticated = true
            self.isOnboarding = self.currentUser?.isOnboarding ?? true
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }
    }
    
    func completeOnboarding() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            try await FirebaseAuthService.shared.updateUserProfile(
                userId: userId,
                data: [
                    "isOnboarding": false,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
            )
            await fetchCurrentUser(userId: userId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.isOnboarding = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
