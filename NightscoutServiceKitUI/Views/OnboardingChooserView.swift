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
            Text("Nightscout")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(frameworkImage: "nightscout", decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 125, height: 125)
            Text("Loop can work with Nightscout to provide remote caregivers a way to see what Loop is doing. Nightscout use is completely optional with Loop, and you can always set it up later.")
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
            Spacer()
            Button(action: {
                self.setupWithNightscout?()
            }) {
                Text(LocalizedString("Use Nightscout with Loop", comment:"Button title for choosing onboarding with nightscout"))
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
        .navigationBarTitle("")
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
