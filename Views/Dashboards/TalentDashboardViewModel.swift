import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
class TalentDashboardViewModel: ObservableObject {
    @Published var workspace: Models.Workspace?
    @Published var isUploadingImage = false
    @Published var profileImage: UIImage?
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let user: User
    private weak var appState: AppState?
    
    init(user: User) {
        self.user = user
        Task {
            await loadInitialData()
        }
    }
    
    func updateAppState(_ newAppState: AppState) {
        self.appState = newAppState
    }
    
    private func loadInitialData() async {
        if let imageUrl = user.profileImageUrl {
            await loadProfileImage(from: imageUrl)
        }
        if !user.workspaceId.isEmpty {
            await loadWorkspace(workspaceId: user.workspaceId)
        }
    }
    
    func uploadProfileImage(_ image: UIImage) async {
        isUploadingImage = true
        errorMessage = nil
        showError = false
        
        do {
            let imageUrl = try await ImageService.shared.uploadProfileImage(image, userId: user.id)
            
            try await FirebaseAuthService.shared.updateUserProfile(
                userId: user.id,
                data: [
                    "profileImageUrl": imageUrl,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
            )
            
            self.profileImage = image
            if let appState = appState {
                await appState.fetchCurrentUser(userId: user.id)
            }
            
        } catch {
            self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
            self.showError = true
        }
        
        isUploadingImage = false
    }
    
    func loadProfileImage(from url: String) async {
        if let cachedImage = await ImageService.shared.getCachedImage(forKey: url) {
            self.profileImage = cachedImage
            return
        }
        
        do {
            guard let imageUrl = URL(string: url) else { return }
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            if let image = UIImage(data: data) {
                self.profileImage = image
                await ImageService.shared.cacheImage(image, forKey: url)
            }
        } catch {
            self.errorMessage = "Failed to load profile image"
            self.showError = true
        }
    }
    
    func loadWorkspace(workspaceId: String) async {
        do {
            let db = Firestore.firestore()
            let doc = try await db.collection("workspaces")
                .document(workspaceId)
                .getDocument()
            
            guard let data = doc.data() else { return }
            
            let industryStrings = data["industries"] as? [String] ?? []
            let industries = industryStrings.compactMap { industryString in
                Models.Industry.allCases.first { $0.rawValue == industryString }
            }
            
            self.workspace = Models.Workspace(
                id: doc.documentID,
                workspaceName: data["workspaceName"] as? String ?? "",
                industries: industries.isEmpty ? [.modeling] : industries,
                location: data["location"] as? String ?? "",
                ownerId: data["ownerId"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
            )
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    func signOut() async {
        if let appState = appState {
            await appState.signOut()
        }
    }
} 
