import Foundation

class UserModel: ObservableObject {
    @Published var authToken: String? {
        didSet {
            UserDefaults.standard.set(authToken, forKey: "authToken")
        }
    }
    @Published var currentUser: User? {
        didSet {
            if let currentUser = currentUser {
                UserDefaults.standard.set(currentUser.name, forKey: "username")
                UserDefaults.standard.set(currentUser.e164PhoneNumber, forKey: "phoneNumber")
            } else {
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.removeObject(forKey: "phoneNumber")
            }
        }
    }
    @Published var apiError: ApiError?

    init() {
        authToken = UserDefaults.standard.string(forKey: "authToken")
        if authToken != nil {
            Task {
                await loadUser()
            }
        }
    }
    
    
    func saveUserDetails(name: String?, phoneNumber: String) {
        UserDefaults.standard.set(name, forKey: "username")
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.synchronize()
        
        
        self.currentUser = User(e164PhoneNumber: phoneNumber, name: name, userId: currentUser?.userId ?? "", accounts: currentUser?.accounts ?? [])
    }

    func updateUsername(_ newName: String) async {
        guard let authToken = authToken else {
            self.apiError = ApiError(errorCode: "missing_token", message: "No authentication token found")
            return
        }

        do {
            let userResponse = try await Api.shared.setUserName(authToken: authToken, name: newName)
            DispatchQueue.main.async {
                self.currentUser = userResponse.user
                UserDefaults.standard.set(newName, forKey: "username")
                UserDefaults.standard.synchronize()
            }
        } catch let error as ApiError {
            DispatchQueue.main.async {
                self.apiError = error
            }
        } catch {
            DispatchQueue.main.async {
                self.apiError = ApiError.unknownError
            }
        }
    }

    func savePhoneNumber(_ phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.synchronize()

        if let currentUser = currentUser {
            let updatedUser = User(e164PhoneNumber: phoneNumber,
                                   name: currentUser.name,
                                   userId: currentUser.userId,
                                   accounts: currentUser.accounts)
            self.currentUser = updatedUser
        } else {
            self.currentUser = User(e164PhoneNumber: phoneNumber, name: nil, userId: "", accounts: [])
        }
    }
    
    func loadUser() async {
        guard let authToken = authToken else {
            self.apiError = ApiError(errorCode: "missing_token", message: "No authentication token found")
            return
        }

        do {
            let userResponse = try await Api.shared.user(authToken: authToken)
            DispatchQueue.main.async {
                self.currentUser = userResponse.user
                UserDefaults.standard.set(userResponse.user.name, forKey: "username")
                UserDefaults.standard.set(userResponse.user.e164PhoneNumber, forKey: "phoneNumber")
            }
        } catch let error as ApiError {
            DispatchQueue.main.async {
                self.apiError = error
            }
        } catch {
            DispatchQueue.main.async {
                self.apiError = ApiError.unknownError
            }
        }
    }
    
    func saveAuthToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: "authToken")
        UserDefaults.standard.synchronize()
        self.authToken = token
        print("Token saved: \(token)")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.authToken = nil
            self.currentUser = nil
            self.apiError = nil
        }
    }
    
}
