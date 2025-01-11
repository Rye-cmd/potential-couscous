import SwiftUI
import FirebaseFirestore


struct DashboardView: View {
    let user: User
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    // Workspace Settings Card
                    NavigationLink(destination: WorkspaceSettingsView(user: user)) {
                        DashboardCard(
                            icon: "gear",
                            title: "Workspace Settings",
                            description: "Manage your workspace details"
                        )
                    }
                    
                    // Talents Management Card
                    NavigationLink(destination: TalentListView(workspaceId: user.workspaceId)) {
                        DashboardCard(
                            icon: "person.2",
                            title: "Manage Talents",
                            description: "View and manage your talents"
                        )
                    }
                    
                    // Add more cards as needed
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Helper view for dashboard cards
struct DashboardCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
} 