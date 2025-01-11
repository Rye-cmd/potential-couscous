import SwiftUI

struct TalentListView: View {
    @StateObject private var viewModel: TalentViewModel
    @State private var showAddTalent = false
    
    init(workspaceId: String) {
        _viewModel = StateObject(wrappedValue: TalentViewModel(workspaceId: workspaceId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.talents.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }) { talent in
                TalentRowView(talent: talent)
            }
        }
        .navigationTitle("Talents")
        .toolbar {
            Button {
                showAddTalent = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddTalent) {
            AddTalentView(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.fetchTalents()
        }
        .task {
            await viewModel.fetchTalents()
        }
    }
}

// Separate view for talent row
struct TalentRowView: View {
    let talent: Models.Talent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(talent.name)
                .font(.headline)
            Text(talent.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Rate: $\(String(format: "%.2f", talent.rate))/hr")
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
} 