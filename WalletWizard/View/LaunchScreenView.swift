//
//  launchScreenView.swift
//  WalletWizard
//  Created by Agam Bhullar on 1/16/24.
//

import SwiftUI

struct LaunchScreenView: View {
    
    @EnvironmentObject var launchScreenManager: LaunchScreenManager
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var secondPhaseIsAnimating: Bool = false

    private let timer = Timer.publish(every: 0.45,
                                      on: .main,
                                      in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            background
            logo1x
        }
        .onReceive(timer) { input in
        
            switch launchScreenManager.state {
            case .first:
                withAnimation(.spring()) {
                    // First phase with continous scaling
                    firstPhaseIsAnimating.toggle()
                }
            case .second:
                withAnimation(.easeInOut) {
                    // First phase with continous scaling
                    secondPhaseIsAnimating.toggle()
                }
            default: break
                
            }
        }
        .opacity(secondPhaseIsAnimating ? 0 : 1)
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(LaunchScreenManager())
    }
}

private extension LaunchScreenView {
    
    var background: some View {
        Color("LaunchScreenBackground")
            .edgesIgnoringSafeArea(.all)
    }
    
    var logo1x: some View {
        Image("logo1x")
            .scaleEffect(firstPhaseIsAnimating ? 0.6 : 1)
            .scaleEffect(secondPhaseIsAnimating ? UIScreen.main.bounds.size.height / 4 : 1)
    }
}
