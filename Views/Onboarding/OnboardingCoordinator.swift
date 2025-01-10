import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum OnboardingStep: CaseIterable {
    case accountType
    case basicInfo
    case workspaceSetup
    case teamSetup
    
    var id: Self { self }
}

struct OnboardingCoordinator: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appState: AppState
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        // Ensure we start at the first step
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(initialStep: .accountType))
    }
    
    var body: some View {
        VStack {
            // Progress indicator (except for first step)
            if viewModel.currentStep != .accountType {
                ProgressView(
                    value: Double(viewModel.currentStepIndex + 1),
                    total: Double(viewModel.totalSteps)
                )
                .padding()
            }
            
            // Current step view
            switch viewModel.currentStep {
            case .accountType:
                AccountTypeSelectionView(
                    selectedType: $viewModel.onboardingData.accountType,
                    onNext: { viewModel.moveToNextStep() }
                )
                
            case .basicInfo:
                BasicInfoView(
                    personalInfo: $viewModel.onboardingData.personalInfo,
                    onNext: { viewModel.moveToNextStep() }
                )
                
            case .workspaceSetup:
                WorkspaceSetupView(
                    data: $viewModel.onboardingData,
                    onComplete: { 
                        Task {
                            await viewModel.completeOnboarding()
                            onComplete()
                        }
                    }
                )
                
            case .teamSetup:
                TeamSetupView(
                    teamInvites: $viewModel.onboardingData.teamInvites,
                    onComplete: {
                        Task {
                            await viewModel.completeOnboarding()
                            onComplete()
                        }
                    }
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// ViewModel to handle onboarding logic
@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var onboardingData = Models.OnboardingData()
    @Published var currentStep: OnboardingStep
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let talentService = TalentService.shared
    
    init(initialStep: OnboardingStep = .accountType) {
        self.currentStep = initialStep
    }
    
    var currentStepIndex: Int {
        availableSteps.firstIndex(of: currentStep) ?? 0
    }
    
    var totalSteps: Int {
        availableSteps.count
    }
    
    private var availableSteps: [OnboardingStep] {
        OnboardingStep.allCases.filter { step in
            if case .teamSetup = step {
                return onboardingData.accountType == .team
            }
            return true
        }
    }
    
    func moveToNextStep() {
        guard let currentIndex = availableSteps.firstIndex(of: currentStep),
              currentIndex < availableSteps.count - 1 else { return }
        
        currentStep = availableSteps[currentIndex + 1]
    }
    
    func completeOnboarding() async {
        do {
            try await talentService.completeOnboarding(onboardingData)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    OnboardingCoordinator(onComplete: {})
        .environmentObject(AppState())
} 
