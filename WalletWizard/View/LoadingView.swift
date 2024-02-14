import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var userModel: UserModel
    @State var isLoading = true
    @State var errorString: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let errorString = errorString {
                Text(errorString)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("Background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all) 
                )
        
        .onAppear {
            Task {
                await loadUserData()
            }
        }
    }

    func loadUserData() async {
        await userModel.loadUser()
        if userModel.apiError != nil {
            errorString = userModel.apiError?.message
        } else {
            isLoading = false
        }
    }
}

