import SwiftUI

struct AccountTypeSelectionView: View {
    @Binding var selectedType: Models.AccountType
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .bold()
                
                Text("How will you use the platform?")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Account Type Options
            VStack(spacing: 16) {
                // Team Option
                AccountTypeCard(
                    title: "For My Team",
                    description: "Set up your workspace and invite your team",
                    isSelected: selectedType == .team,
                    action: {
                        selectedType = .team
                    }
                )
                
                // Solo Option
                AccountTypeCard(
                    title: "For Myself",
                    description: "Work on your own for now—you can invite collaborators later",
                    isSelected: selectedType == .individual,
                    action: {
                        selectedType = .individual
                    }
                )
            }
            .padding(.vertical)
            
            Spacer()
            
            // Continue Button
            Button(action: onNext) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// Helper view for account type selection cards
private struct AccountTypeCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AccountTypeSelectionView(
        selectedType: .constant(.individual),
        onNext: {}
    )
    .environmentObject(AppState())
} 