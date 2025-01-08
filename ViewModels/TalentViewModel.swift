import Foundation
import FirebaseFirestore

@MainActor
class TalentViewModel: ObservableObject {
    @Published var talents: [Models.Talent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = TalentService.shared
    private let workspaceId: String
    
    init(workspaceId: String) {
        self.workspaceId = workspaceId
    }
    
    // MARK: - Public Methods
    func fetchTalents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            talents = try await service.getTalents(forWorkspace: workspaceId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addTalent(name: String, email: String, phone: String?, bio: String, skills: [String], rate: Double) async {
        isLoading = true
        errorMessage = nil
        
        let newTalent = Models.Talent(
            id: nil,
            name: name,
            email: email,
            phone: phone,
            bio: bio,
            primarySkills: skills,
            rate: rate,
            status: .active,
            workspaceId: workspaceId,
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            _ = try await service.createTalent(newTalent)
            await fetchTalents() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateTalent(_ talent: Models.Talent) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.updateTalent(talent)
            await fetchTalents() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteTalent(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.deleteTalent(id: id)
            await fetchTalents() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 