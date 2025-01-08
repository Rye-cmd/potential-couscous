import SwiftUI

struct SelectableCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // Add icon property with a default SF Symbol
    private var iconName: String {
        switch title {
        case "Creative Arts": "paintbrush.fill"
        case "Technology": "laptopcomputer"
        case "Healthcare": "heart.fill"
        case "Education": "book.fill"
        case "Finance": "dollarsign.circle.fill"
        case "Retail": "cart.fill"
        case "Manufacturing": "gearshape.2.fill"
        case "Other": "ellipsis.circle.fill"
        default: "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .accentColor : .gray)
                
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Add a custom button style for better touch feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Preview
#Preview {
    VStack(spacing: 16) {
        SelectableCard(
            title: "Technology",
            isSelected: true,
            action: {}
        )
        SelectableCard(
            title: "Healthcare",
            isSelected: false,
            action: {}
        )
    }
    .padding()
} 