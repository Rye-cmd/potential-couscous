//
//  WorkspaceSetupView.swift
//  Talent
//
//  Created by Advance Team on 3/1/25.
//


import SwiftUI

struct WorkspaceSetupView: View {
    @Binding var data: Models.OnboardingData
    let onComplete: () -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Select Industries")
                    .font(.title2)
                    .bold()
                
                LazyVGrid(columns: columns, spacing: 16) {
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
                
                Button("Complete Setup") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(data.selectedIndustries.isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    WorkspaceSetupView(
        data: .constant(Models.OnboardingData()),
        onComplete: {}
    )
}
