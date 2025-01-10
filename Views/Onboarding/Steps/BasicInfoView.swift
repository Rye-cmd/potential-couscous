import SwiftUI

struct BasicInfoView: View {
    @Binding var personalInfo: Models.OnboardingData.PersonalInfo
    let onNext: () -> Void
    
    // Professional roles available
    private let roles = [
        "Photographer",
        "Model",
        "Makeup Artist",
        "Hair Stylist",
        "Fashion Designer",
        "Art Director",
        "Producer",
        "Other"
    ]
    
    private var isFormValid: Bool {
        !personalInfo.fullName.isEmpty && !personalInfo.role.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("About You")
                    .font(.title)
                    .bold()
                
                Text("Tell us about yourself")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Form Fields
            VStack(alignment: .leading, spacing: 20) {
                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.headline)
                    
                    TextField("Enter your full name", text: $personalInfo.fullName)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                }
                
                // Role Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Professional Role")
                        .font(.headline)
                    
                    Menu {
                        ForEach(roles, id: \.self) { role in
                            Button(role) {
                                personalInfo.role = role
                            }
                        }
                    } label: {
                        HStack {
                            Text(personalInfo.role.isEmpty ? "Select your role" : personalInfo.role)
                                .foregroundColor(personalInfo.role.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
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
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    BasicInfoView(
        personalInfo: .constant(Models.OnboardingData.PersonalInfo()),
        onNext: {}
    )
} 