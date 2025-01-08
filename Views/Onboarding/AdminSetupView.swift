//
//  AdminSetupView.swift
//  Talent
//
//  Created by Advance Team on 3/1/25.
//


import SwiftUI

struct AdminSetupView: View {
    @Binding var data: Models.OnboardingData
    let onNext: () -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Let's set up your profile")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Form Fields
                VStack(alignment: .leading, spacing: 16) {
                    Section("PERSONAL INFO") {
                        TextField("Name", text: $data.adminName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Section("WORKSPACE INFO") {
                        TextField("Workspace Name", text: $data.workspaceName)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("Industry")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Models.Industry.allCases) { industry in
                                SelectableCard(
                                    title: industry.name,
                                    isSelected: data.selectedIndustries.contains(industry)
                                ) {
                                    if data.selectedIndustries.contains(industry) {
                                        data.selectedIndustries.remove(industry)
                                    } else {
                                        data.selectedIndustries.insert(industry)
                                    }
                                }
                            }
                        }
                        
                        TextField("Location", text: $data.location)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
                
                // Continue Button
                Button(action: onNext) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    AdminSetupView(
        data: .constant(Models.OnboardingData()),
        onNext: {}
    )
}
