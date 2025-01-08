import SwiftUI
import FirebaseFirestore

struct TalentDashboardView: View {
    let user: User
    @StateObject private var viewModel: TalentDashboardViewModel
    @EnvironmentObject private var appState: AppState
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    init(user: User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: TalentDashboardViewModel(user: user))
    }

    var body: some View {
        List {
            // User Info Section
            Section("USER INFO") {
                HStack(spacing: 16) {
                    ProfileImageView(
                        user: user,
                        profileImage: viewModel.profileImage,
                        size: 80,
                        showEditButton: true,
                        onEditTap: { showImagePicker = true }
                    )
                    
                    VStack(alignment: .leading) {
                        Text("Welcome \(user.name.isEmpty ? "Admin" : user.name)")
                            .font(.headline)
                        Text("Email: \(user.email)")
                            .foregroundColor(.secondary)
                        Text("Role: \(user.role.rawValue.capitalized)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Workspace Details Section
            Section("WORKSPACE DETAILS") {
                if let workspace = viewModel.workspace {
                    VStack(alignment: .leading, spacing: 8) {
                        if !workspace.workspaceName.isEmpty {
                            Text("Workspace Name: \(workspace.workspaceName)")
                        } else {
                            Text("Workspace Name: Not set")
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Industries:")
                                .font(.headline)
                            ForEach(workspace.industries, id: \.self) { industry in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                    Text(industry.name)
                                        .foregroundColor(.primary)
                                }
                                .padding(.leading)
                            }
                        }
                        
                        if !workspace.location.isEmpty {
                            Text("Location: \(workspace.location)")
                        } else {
                            Text("Location: Not set")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    ProgressView("Loading workspace...")
                }
            }
            
            // Admin Controls Section
            Section("ADMIN CONTROLS") {
                NavigationLink {
                    // Workspace Settings View
                    Text("Workspace Settings")
                } label: {
                    Text("Workspace Settings")
                }
                
                NavigationLink {
                    TalentListView(workspaceId: user.workspaceId)
                } label: {
                    HStack {
                        Image(systemName: "person.2")
                        Text("Manage Talents")
                    }
                }
                
                Text("Admin Dashboard")
            }
            
            // Sign Out Section
            Section {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await viewModel.signOut()
                    }
                }
            }
        }
        .navigationTitle("Dashboard")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                Task {
                    await viewModel.uploadProfileImage(image)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            if let imageUrl = user.profileImageUrl {
                await viewModel.loadProfileImage(from: imageUrl)
            }
        }
        .onAppear {
            viewModel.updateAppState(appState)
        }
    }
}

