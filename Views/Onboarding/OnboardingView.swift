import SwiftUI
import FirebaseFirestore

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var fullName = ""
    @State private var workspaceName = "My Workspace"
    @State private var selectedIndustries: Set<Models.Industry> = []
    @State private var selectedLocation = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    var onComplete: () -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    private let locations = [
        "United States",
        "United Kingdom",
        "Canada",
        "Australia",
        "Germany",
        "France",
        "Spain",
        "Italy",
        "Japan",
        "Other"
    ]
    
    private func completeOnboarding() async {
        guard !fullName.isEmpty, 
              !workspaceName.isEmpty, 
              !selectedLocation.isEmpty,
              !selectedIndustries.isEmpty else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let user = appState.currentUser else {
                throw OnboardingError.noUser
            }
            
            // Update workspace with multiple industries
            try await FirebaseAuthService.shared.updateWorkspace(
                workspaceId: user.workspaceId,
                data: [
                    "workspaceName": workspaceName,
                    "industries": Array(selectedIndustries).map { $0.rawValue },
                    "location": selectedLocation,
                ]
            )
            
            // Then update user profile
            try await FirebaseAuthService.shared.updateUserProfile(
                userId: user.id,
                data: [
                    "name": fullName,
                    "isOnboarding": false
                ]
            )
            
            // Refresh current user data
            await appState.fetchCurrentUser(userId: user.id)
            
            onComplete()
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Let's set up your profile")
                    .font(.title)
                    .bold()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Personal Info Section
                    Text("PERSONAL INFO")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Full Name", text: $fullName)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .disabled(isLoading)
                    
                    // Workspace Info Section
                    Text("WORKSPACE INFO")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Workspace Name", text: $workspaceName)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .disabled(isLoading)
                    
                    Text("Select Industries")
                        .font(.headline)
                    
                    Text("Choose one or more industries that best describe your workspace")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Models.Industry.allCases) { industry in
                            SelectableCard(
                                title: industry.name,
                                isSelected: selectedIndustries.contains(industry)
                            ) {
                                if selectedIndustries.contains(industry) {
                                    selectedIndustries.remove(industry)
                                } else {
                                    selectedIndustries.insert(industry)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Picker("Location", selection: $selectedLocation) {
                        Text("Select a location").tag("")
                        ForEach(locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .disabled(isLoading)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: { Task { await completeOnboarding() } }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || 
                             fullName.isEmpty || 
                             workspaceName.isEmpty || 
                             selectedLocation.isEmpty || 
                             selectedIndustries.isEmpty)
                }
                .padding()
            }
            .padding()
        }
    }
}

enum OnboardingError: LocalizedError {
    case noUser
    
    var errorDescription: String? {
        switch self {
        case .noUser:
            return "Unable to complete onboarding. Please try signing in again."
        }
    }
}
