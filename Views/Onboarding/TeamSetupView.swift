//
//  TeamSetupView.swift
//  Talent
//
//  Created by Advance Team on 31/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore

struct TeamSetupView: View {
    @Binding var teamMembers: [(email: String, name: String, role: String)]
    var onFinish: () -> Void

    @State private var teamMemberEmail: String = ""
    @State private var teamMemberName: String = ""
    @State private var selectedRole: String = "Booker"

    var body: some View {
        VStack {
            Text("Invite Team Members")
                .font(.headline)
                .padding()

            HStack {
                VStack {
                    TextField("Team Member Name", text: $teamMemberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Team Member Email", text: $teamMemberEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Picker("Role", selection: $selectedRole) {
                    Text("Agency Admin").tag("agencyAdmin")
                    Text("Booker").tag("booker")
                    Text("Agent").tag("agent")
                }
                .pickerStyle(MenuPickerStyle())
                Button("Add") {
                    addTeamMember()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()

            List {
                ForEach(teamMembers, id: \.email) { member in
                    Text("\(member.name) (\(member.email)) - \(member.role.capitalized)")
                }
            }

            Button("Finish") {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue) // Optional, customize the color
        }
        .padding()
    }

    func addTeamMember() {
        guard !teamMemberEmail.isEmpty, !teamMemberName.isEmpty else { return }
        teamMembers.append((email: teamMemberEmail, name: teamMemberName, role: selectedRole))
        teamMemberEmail = ""
        teamMemberName = ""
    }
}
