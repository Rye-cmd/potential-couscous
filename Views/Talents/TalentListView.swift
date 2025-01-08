import SwiftUI

struct TalentListView: View {
    @StateObject private var viewModel: TalentViewModel
    @State private var showAddTalent = false
    
    init(workspaceId: String) {
        _viewModel = StateObject(wrappedValue: TalentViewModel(workspaceId: workspaceId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.talents) { talent in
                VStack(alignment: .leading) {
                    Text(talent.name)
                        .font(.headline)
                    Text(talent.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Rate: $\(String(format: "%.2f", talent.rate))/hr")
                        .font(.caption)
                }
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
        .task {
            await viewModel.fetchTalents()
        }
    }
} 