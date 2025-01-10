import SwiftUI

struct TeamSetupView: View {
    @Binding var teamInvites: [Models.OnboardingData.TeamInvite]
    let onComplete: () -> Void
    
    @State private var newInvite = Models.OnboardingData.TeamInvite(
        email: "",
        role: "",
        status: .pending
    )
    @State private var showEmailError = false
    
    private let roles = [
        "Team Member",
        "Photographer",
        "Model",
        "Makeup Artist",
        "Hair Stylist",
        "Fashion Designer",
        "Art Director",
        "Producer"
    ]
    
    private var isValidNewInvite: Bool {
        isValidEmail(newInvite.email) && !newInvite.role.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Invite Your Team")
                    .font(.title)
                    .bold()
                
                Text("Add team members or skip to invite them later")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Invite Form
            VStack(alignment: .leading, spacing: 20) {
                // New Invite Section
                VStack(alignment: .leading, spacing: 12) {
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email address", text: $newInvite.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                        
                        if showEmailError {
                            Text("Please enter a valid email")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Role Selection
                    Menu {
                        ForEach(roles, id: \.self) { role in
                            Button(role) {
                                newInvite.role = role
                            }
                        }
                    } label: {
                        HStack {
                            Text(newInvite.role.isEmpty ? "Select role" : newInvite.role)
                                .foregroundColor(newInvite.role.isEmpty ? .secondary : .primary)
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
                    
                    // Add Button
                    Button(action: addInvite) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Team Member")
                        }
                    }
                    .disabled(!isValidNewInvite)
                }
                
                // Pending Invites List
                if !teamInvites.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pending Invites")
                            .font(.headline)
                        
                        ForEach(teamInvites.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(teamInvites[index].email)
                                        .font(.subheadline)
                                    Text(teamInvites[index].role)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    teamInvites.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: onComplete) {
                    Text(teamInvites.isEmpty ? "Skip for now" : "Send invites & continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if !teamInvites.isEmpty {
                    Button(action: { teamInvites.removeAll() }) {
                        Text("Clear all")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func addInvite() {
        guard isValidEmail(newInvite.email) else {
            showEmailError = true
            return
        }
        
        showEmailError = false
        teamInvites.append(newInvite)
        newInvite = Models.OnboardingData.TeamInvite(
            email: "",
            role: "",
            status: .pending
        )
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    TeamSetupView(
        teamInvites: .constant([]),
        onComplete: {}
    )
} 