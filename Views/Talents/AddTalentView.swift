import SwiftUI

struct AddTalentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TalentViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var rate = ""
    @State private var skill = ""
    @State private var skills: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Rate (per hour)", text: $rate)
                        .keyboardType(.decimalPad)
                }
                
                Section("Skills") {
                    HStack {
                        TextField("Add skill", text: $skill)
                        Button("Add") {
                            addSkill()
                        }
                        .disabled(skill.isEmpty)
                    }
                    
                    ForEach(skills, id: \.self) { skill in
                        Text(skill)
                    }
                }
            }
            .navigationTitle("Add Talent")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty && !rate.isEmpty && !skills.isEmpty
    }
    
    private func addSkill() {
        let trimmedSkill = skill.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSkill.isEmpty && !skills.contains(trimmedSkill) {
            skills.append(trimmedSkill)
            skill = ""
        }
    }
    
    private func save() {
        Task {
            await viewModel.addTalent(
                name: name,
                email: email,
                phone: nil,
                bio: "",
                skills: skills,
                rate: Double(rate) ?? 0
            )
            dismiss()
        }
    }
}

#Preview {
    AddTalentView(viewModel: TalentViewModel(workspaceId: "preview"))
} 