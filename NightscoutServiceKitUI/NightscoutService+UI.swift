//
//  NightscoutService+UI.swift
//  NightscoutServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import NightscoutServiceKit

extension NightscoutService: ServiceUI {
    
    public static var image: UIImage? {
        UIImage(named: "nightscout", in: Bundle(for: NightscoutServiceCredentialsTableViewController.self), compatibleWith: nil)!
    }

    public static func setupViewController(chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)? {
        
        return SettingsReviewUICoordinator(chartColors: chartColors, carbTintColor: carbTintColor, glucoseTintColor: glucoseTintColor, guidanceColors: guidanceColors, insulinTintColor: insulinTintColor)
    }

    public func settingsViewController(chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & ServiceSettingsNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: NightscoutServiceCredentialsTableViewController(service: self, for: .update))
    }

}
