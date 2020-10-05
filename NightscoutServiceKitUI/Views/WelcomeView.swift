//
//  WelcomeView.swift
//  NightscoutServiceKitUI
//
//  Created by Pete Schwamb on 9/11/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI

struct WelcomeView: View, HorizontalSizeClassOverride {
    
    var didContinue: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("Welcome to Loop")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(frameworkImage: "Loop", decorative: true)
            Text("Before using Loop you need to configure a few settings. These settings should be entered with precision and care; they are ultimately what Loop uses to determine how much insulin to deliver. If you are new to Loop, work with your diabetes support team to come up with a plan for finding out what settings will work best for you.")
                .foregroundColor(.secondary)
            Spacer()
            Button(action: {
                self.didContinue?()
            }) {
                Text(LocalizedString("I'm Ready!", comment:"Button title for starting setup"))
                    .actionButtonStyle(.primary)
            }
        }
        .padding()
        .environment(\.horizontalSizeClass, .compact)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeView()
        }
        .previewDevice("iPod touch (7th generation)")
    }
}
