//
//  SettingsReviewViewModel.swift
//  TidepoolServiceKitUI
//
//  Created by Pete Schwamb on 9/7/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import NightscoutServiceKit
import LoopKit
import LoopKitUI
import HealthKit

class SettingsReviewViewModel: ObservableObject {
    // MARK: Navigation
    var didFinishStep: (() -> Void)
    var didCancel: (() -> Void)?
    
    // MARK: State
    @Published var shouldDisplayError = false
    
    // MARK: Prescription Information
    var settings: TherapySettings?

    init(finishedStepHandler: @escaping () -> Void = { }) {
        self.didFinishStep = finishedStepHandler
    }
    
    func entryNavigation(success: Bool) {
        if success {
            shouldDisplayError = false
            didFinishStep()
        } else {
           shouldDisplayError = true
        }
    }
}
