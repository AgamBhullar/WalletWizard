import SwiftUI
import PhoneNumberKit

@main
struct WalletWizardApp: App {
    init() {
        Api.shared.appId = "QSQEo5xSmENL"
    }

    @StateObject var launchScreenManager = LaunchScreenManager()
    @StateObject var userModel = UserModel()
    
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let _ = userModel.authToken {
                    if userModel.currentUser != nil {
                        HomeView()
                            .environmentObject(userModel)
                    } else {
                        LoadingView()
                            .environmentObject(userModel)
                        
                    }
                } else {
                    ZStack {
                        LoginView()
                            .environmentObject(userModel)
                        if launchScreenManager.state != .completed {
                            LaunchScreenView()
                        }
                    }
                    .environmentObject(launchScreenManager)
                }
            }
        }
    }
}



