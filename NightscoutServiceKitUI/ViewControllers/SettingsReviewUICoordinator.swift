//
//  SettingsReviewUICoordinator.swift
//  NightscoutServiceKitUI
//
//  Created by Pete Schwamb on 9/7/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKitUI
import LoopKit
import NightscoutServiceKit
import HealthKit

enum SettingsReviewScreen {
    case setupChooser
    case login
    case correctionRangeInfo
    case correctionRangeEditor
    case correctionRangePreMealOverrideInfo
    case correctionRangePreMealOverrideEditor
    case correctionRangeWorkoutOverrideInfo
    case correctionRangeWorkoutOverrideEditor
    case suspendThresholdInfo
    case suspendThresholdEditor
    case basalRatesInfo
    case basalRatesEditor
    case deliveryLimitsInfo
    case deliveryLimitsEditor
    case insulinModelInfo
    case insulinModelEditor
    case carbRatioInfo
    case carbRatioEditor
    case insulinSensitivityInfo
    case insulinSensitivityEditor
    case therapySettingsRecap
    
    func next() -> SettingsReviewScreen? {
        switch self {
        case .setupChooser:
            return nil
        case .login:
            return .suspendThresholdInfo
        case .suspendThresholdInfo:
            return .suspendThresholdEditor
        case .suspendThresholdEditor:
            return .correctionRangeInfo
        case .correctionRangeInfo:
            return .correctionRangeEditor
        case .correctionRangeEditor:
            return .correctionRangePreMealOverrideInfo
        case .correctionRangePreMealOverrideInfo:
            return .correctionRangePreMealOverrideEditor
        case .correctionRangePreMealOverrideEditor:
            return .correctionRangeWorkoutOverrideInfo
        case .correctionRangeWorkoutOverrideInfo:
            return .correctionRangeWorkoutOverrideEditor
        case .correctionRangeWorkoutOverrideEditor:
            return .basalRatesInfo
        case .basalRatesInfo:
            return .basalRatesEditor
        case .basalRatesEditor:
            return .deliveryLimitsInfo
        case .deliveryLimitsInfo:
            return .deliveryLimitsEditor
        case .deliveryLimitsEditor:
            return .insulinModelInfo
        case .insulinModelInfo:
            return .insulinModelEditor
        case .insulinModelEditor:
            return .carbRatioInfo
        case .carbRatioInfo:
            return .carbRatioEditor
        case .carbRatioEditor:
            return .insulinSensitivityInfo
        case .insulinSensitivityInfo:
            return .insulinSensitivityEditor
        case .insulinSensitivityEditor:
            return .therapySettingsRecap
        case .therapySettingsRecap:
            return nil
        }
    }
}

class SettingsReviewUICoordinator: UINavigationController, CompletionNotifying, UINavigationControllerDelegate, ServiceSetupNotifying, ServiceSettingsNotifying {
    var screenStack = [SettingsReviewScreen]()
    weak var completionDelegate: CompletionDelegate?
    var onReviewFinished: ((TherapySettings) -> Void)?
    
    private let initialTherapySettings: TherapySettings
    private let preferredGlucoseUnit: HKUnit
    private let chartColors: ChartColorPalette
    private let carbTintColor: Color
    private let glucoseTintColor: Color
    private let guidanceColors: GuidanceColors
    private let insulinTintColor: Color
    
    public weak var serviceSetupDelegate: ServiceSetupDelegate?

    public weak var serviceSettingsDelegate: ServiceSettingsDelegate?
    

    public func notifyServiceCreated(_ service: Service) {
        serviceSetupDelegate?.serviceSetupNotifying(self, didCreateService: service)
    }

    public func notifyServiceDeleted(_ service: Service) {
        serviceSettingsDelegate?.serviceSettingsNotifying(self, didDeleteService: service)
    }

    let prescriptionViewModel = SettingsReviewViewModel() // Used for retreving & keeping track of prescription
    private var therapySettingsViewModel: TherapySettingsViewModel? // Used for keeping track of & updating settings
    
    var currentScreen: SettingsReviewScreen {
        return screenStack.last!
    }

    init(therapySettings: TherapySettings, preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) {
        self.initialTherapySettings = therapySettings
        self.preferredGlucoseUnit = preferredGlucoseUnit
        self.chartColors = chartColors
        self.carbTintColor = carbTintColor
        self.glucoseTintColor = glucoseTintColor
        self.guidanceColors = guidanceColors
        self.insulinTintColor = insulinTintColor
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.navigationBar.prefersLargeTitles = true // ensure nav bar text is displayed correctly
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func viewControllerForScreen(_ screen: SettingsReviewScreen) -> UIViewController {
        switch screen {
        case .setupChooser:
            let view = OnboardingChooser {
                self.navigate(to: .login)
            } setupWithoutNightscout: {
                self.navigate(to: .suspendThresholdInfo)
            }

            let hostedView = hostingController(rootView: view)
            return hostedView

        case .login:
            let service = NightscoutService()
            service.restoreCredentials()
            let model = CredentialsViewModel(service: service)
            model.didSkip = {
                self.stepFinished()
            }
            model.didSucceed = {
                self.serviceSetupDelegate?.serviceSetupNotifying(self, didCreateService: service)
                self.stepFinished()
            }
            let view = CredentialsView(viewModel: model, url: service.siteURL?.absoluteString ?? "", apiSecret: service.apiSecret ?? "")
            let hostedView = hostingController(rootView: view)
            return hostedView
        case .correctionRangeInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.glucoseTargetRange.title
            return hostedView
        case .correctionRangeEditor:
            let view = CorrectionRangeScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .correctionRangePreMealOverrideInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeOverrideInformationView(preset: .preMeal, onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.preMealCorrectionRangeOverride.smallTitle
            return hostedView
        case .correctionRangePreMealOverrideEditor:
            let view = CorrectionRangeOverridesEditor(viewModel: therapySettingsViewModel!, preset: .preMeal)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .correctionRangeWorkoutOverrideInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeOverrideInformationView(preset: .workout, onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.workoutCorrectionRangeOverride.smallTitle
            return hostedView
        case .correctionRangeWorkoutOverrideEditor:
            let view = CorrectionRangeOverridesEditor(viewModel: therapySettingsViewModel!, preset: .workout)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .suspendThresholdInfo:
            therapySettingsViewModel = constructTherapySettingsViewModel(therapySettings: initialTherapySettings)
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = SuspendThresholdInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.suspendThreshold.title
            return hostedView
        case .suspendThresholdEditor:
            let view = SuspendThresholdEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .basalRatesInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = BasalRatesInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.basalRate.title
            return hostedView
        case .basalRatesEditor:
            let view = BasalRateScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .deliveryLimitsInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = DeliveryLimitsInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.deliveryLimits.title
            return hostedView
        case .deliveryLimitsEditor:
            let view = DeliveryLimitsEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinModelInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinModelInformationView(onExit: onExit).environment(\.appName, Bundle.main.bundleDisplayName)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .insulinModelEditor:
            
            let view = InsulinModelSelection(viewModel: therapySettingsViewModel!).environment(\.appName, Bundle.main.bundleDisplayName)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .carbRatioInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CarbRatioInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.carbRatio.title
            return hostedView
        case .carbRatioEditor:
            let view = CarbRatioScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinSensitivityInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinSensitivityInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinSensitivity.title
            return hostedView
        case .insulinSensitivityEditor:
            let view = InsulinSensitivityScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .therapySettingsRecap:
            // Get rid of the "prescription" card because it should not be shown as part of the recap
            therapySettingsViewModel?.prescription = nil
            let nextButtonString = LocalizedString("Save Settings", comment: "Therapy settings save button title")
            let actionButton = TherapySettingsView.ActionButton(localizedString: nextButtonString) { [weak self] in
                self?.stepFinished()
            }
            let view = TherapySettingsView(viewModel: therapySettingsViewModel!, actionButton: actionButton)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = LocalizedString("Therapy Settings", comment: "Navigation view title")
            return hostedView
        }
    }
    
    private func hostingController<Content: View>(rootView: Content) -> DismissibleHostingController {
        return DismissibleHostingController(rootView: rootView, carbTintColor: carbTintColor, glucoseTintColor: glucoseTintColor, guidanceColors: guidanceColors, insulinTintColor: insulinTintColor)
    }
    
    private func constructTherapySettingsViewModel(therapySettings: TherapySettings) -> TherapySettingsViewModel? {
        let supportedBasalRates = (1...600).map { round(Double($0) / Double(1/0.05) * 100) / 100 }
        
        let maximumBasalScheduleEntryCount = 24
        
        let supportedBolusVolumes = (1...600).map { Double($0) / Double(1/0.05) }
        
        let pumpSupportedIncrements = PumpSupportedIncrements(
            basalRates: supportedBasalRates,
            bolusVolumes: supportedBolusVolumes,
            maximumBasalScheduleEntryCount: maximumBasalScheduleEntryCount
        )
        let supportedInsulinModelSettings = SupportedInsulinModelSettings(fiaspModelEnabled: true, walshModelEnabled: false)
        
        return TherapySettingsViewModel(
            mode: .acceptanceFlow,
            therapySettings: therapySettings,
            glucoseUnit: preferredGlucoseUnit,
            supportedInsulinModelSettings: supportedInsulinModelSettings,
            pumpSupportedIncrements: pumpSupportedIncrements,
            syncPumpSchedule: { _, _ in
                // Since pump isn't set up, this syncing shouldn't do anything
                assertionFailure()
            },
            prescription: nil,
            chartColors: chartColors
        ) { [weak self] _, _ in
            self?.stepFinished()
        }
    }

    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {
        // Pop the current screen from the stack if we're navigating back
        if viewControllers.count < screenStack.count {
            // Navigation back
            let _ = screenStack.popLast()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        screenStack = [.setupChooser]
        let viewController = viewControllerForScreen(currentScreen)
        setViewControllers([viewController], animated: false)
    }
    
    // TODO: have separate flow for cancelling
    private func setupCanceled() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
    
    private func stepFinished() {
        if let nextStep = currentScreen.next() {
            navigate(to: nextStep)
        } else {
            onReviewFinished?(therapySettingsViewModel!.therapySettings)
            completionDelegate?.completionNotifyingDidComplete(self)
        }
    }
    
    func navigate(to screen: SettingsReviewScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        self.pushViewController(viewController, animated: true)
    }
}

extension Bundle {

    var bundleDisplayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
}

