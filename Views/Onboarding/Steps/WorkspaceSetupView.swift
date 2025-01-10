import SwiftUI

struct WorkspaceSetupView: View {
    @Binding var data: Models.OnboardingData
    let onComplete: () -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    private var isFormValid: Bool {
        !data.workspaceInfo.name.isEmpty && !data.workspaceInfo.industries.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Workspace Setup")
                    .font(.title)
                    .bold()
                
                Text("Set up your workspace details")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Form Fields
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Workspace Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workspace Name")
                            .font(.headline)
                        
                        TextField("Enter workspace name", text: $data.workspaceInfo.name)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.words)
                    }
                    
                    // Industry Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Industries")
                            .font(.headline)
                        
                        Text("Select industries that best describe your work")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Models.Industry.allCases) { industry in
                                IndustryCard(
                                    industry: industry,
                                    isSelected: data.workspaceInfo.industries.contains(industry)
                                ) {
                                    if data.workspaceInfo.industries.contains(industry) {
                                        data.workspaceInfo.industries.remove(industry)
                                    } else {
                                        data.workspaceInfo.industries.insert(industry)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Spacer()
            
            // Continue Button
            Button("Continue") {
                // Validate inputs if needed
                if !data.workspaceInfo.name.isEmpty {
                    onComplete()  // Call the completion handler
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
}

// Helper view for industry selection cards
private struct IndustryCard: View {
    let industry: Models.Industry
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(industry.name)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    WorkspaceSetupView(
        data: .constant(Models.OnboardingData()),
        onComplete: {}
    )
} 