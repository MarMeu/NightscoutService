//
//  NightscoutService+UI.swift
//  NightscoutServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit
import LoopKitUI
import NightscoutServiceKit

extension NightscoutService: ServiceUI {

    public static func setupViewController() -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)? {
        let service = NightscoutService(rawState: [:]) ?? NightscoutService() // Handle migration
        return ServiceViewController(rootViewController: NightscoutServiceTableViewController(service: service, for: .create))
    }

    public func settingsViewController() -> (UIViewController & ServiceSettingsNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: NightscoutServiceTableViewController(service: self, for: .update))
    }

}
