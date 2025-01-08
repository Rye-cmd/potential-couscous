//
//  CoreSetupDetailsView.swift
//  Talent
//
//  Created by Advance Team on 31/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CoreSetupDetailsView: View {
    @State private var agencyName: String = ""
    @State private var contactEmail: String = ""
    @State private var errorMessage: String? = nil

    var onNext: (String, String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Agency Details")
                .font(.largeTitle)
                .bold()

            Form {
                Section(header: Text("Agency Information")) {
                    TextField("Agency Name", text: $agencyName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField("Contact Email", text: $contactEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }

            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // Next Button
            Button(action: validateAndNext) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    private func validateAndNext() {
        // Validation Logic
        guard !agencyName.isEmpty else {
            errorMessage = "Agency name cannot be empty."
            return
        }

        guard !contactEmail.isEmpty, isValidEmail(contactEmail) else {
            errorMessage = "Please enter a valid email address."
            return
        }

        errorMessage = nil
        onNext(agencyName, contactEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        // Basic email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
