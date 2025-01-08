import SwiftUI
import FirebaseFirestore

enum OnboardingStep {
    case adminSetup
    case workspaceSetup
}

struct OnboardingCoordinator: View {
    @State private var currentStep: OnboardingStep = .adminSetup
    @State private var onboardingData = Models.OnboardingData()
    @EnvironmentObject var appState: AppState
    let onComplete: () -> Void
    
    var body: some View {
        switch currentStep {
        case .adminSetup:
            AdminSetupView(
                data: $onboardingData,
                onNext: { currentStep = .workspaceSetup }
            )
            
        case .workspaceSetup:
            WorkspaceSetupView(data: $onboardingData) {
                Task {
                    do {
                        if let user = appState.currentUser {
                            try await saveOnboardingData(user: user)
                            onComplete()
                        }
                    } catch {
                        print("Error during onboarding: \(error)")
                    }
                }
            }
        }
    }
    
    private func saveOnboardingData(user: User) async throws {
        let db = Firestore.firestore()
        
        // Convert industries to array of strings for Firestore
        let industryStrings = Array(onboardingData.selectedIndustries).map { $0.rawValue }
        
        // Update workspace with all relevant data
        try await db.collection("workspaces").document(user.workspaceId).setData([
            "workspaceName": onboardingData.workspaceName,
            "industries": industryStrings,
            "location": onboardingData.location,
            "ownerId": user.id,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        
        // Update user with all relevant data
        try await db.collection("users").document(user.id).setData([
            "name": onboardingData.adminName,
            "role": "admin",
            "isOnboarding": false,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

#Preview {
    OnboardingCoordinator(onComplete: {})
        .environmentObject(AppState())
} 
