//
//  OnboardingChooserView.swift
//  NightscoutServiceKitUI
//
//  Created by Pete Schwamb on 9/11/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI


struct OnboardingChooserView: View, HorizontalSizeClassOverride {
    
    var setupWithNightscout: (() -> Void)?
    var setupWithoutNightscout: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Before using Loop you need to configure it. If you already use Nightscout, Loop can use it as a place to read and store your configuration. But if not, no worries. Nightscout use is completely optional with Loop, and you can always set it up later.")
                .foregroundColor(.secondary)
            Spacer()
            Button(action: {
                self.setupWithNightscout?()
            }) {
                Text(LocalizedString("I have Nightscout", comment:"Button title for choosing onboarding with nightscout"))
                    .actionButtonStyle(.secondary)
            }
            Button(action: {
                self.setupWithoutNightscout?()
            }) {
                Text(LocalizedString("Setup Loop without Nightscout", comment:"Button title for choosing onboarding without nightscout"))
                    .actionButtonStyle(.secondary)
            }
        }
        .padding()
        .environment(\.horizontalSizeClass, .compact)
        .navigationBarTitle(Text("Welcome"))

    }
}

struct OnboardingChooserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingChooserView()
        }
        .previewDevice("iPod touch (7th generation)")
    }
}
