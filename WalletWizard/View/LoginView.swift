//
// LoginView.swift
// WalletWizard
// Created by Agam Bhullar on 1/14/24.
//

import SwiftUI
import PhoneNumberKit

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var navigateToVerify = false
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isInputActive: Bool
    @State private var isButtonPressed = false
    @State private var animate: Bool = false
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject var launchScreenManager: LaunchScreenManager
    

    var body: some View {
        NavigationStack(path: $navigationPath){
                VStack {
                    Spacer()
                    // Main content
                    //logo customization
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 250)
                        .frame(width: 200, height: 250)
                    
                    //slogan customization
                    Image("slogan")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 70)
                        .frame(width: 200, height: 50)
                    //DispatchQueue for launch screen animation
                        .onAppear {
                            DispatchQueue
                                .main
                                .asyncAfter(deadline: .now() + 1.5) {
                                    launchScreenManager.dismiss()
                                }
                        }
                    
                    HStack {
                        Text("+1") // Country code for US
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.numberPad)
                            .focused($isInputActive)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 5)
                            .onChange(of: phoneNumber) { newValue in
                                let formatter = PartialFormatter()
                                phoneNumber = formatter.formatPartial(newValue)
                            }
                    }
                    .padding()
                    //Button customization
                    Button(action: sendOTP) {
                        Text("Send OTP")
                            .foregroundColor(.white)
                            .padding()
                            .background(isButtonPressed ? Color("CustomColor1").opacity(0.8) : Color("CustomColor1"))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                    }
                    //Animation for Button Press
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isButtonPressed = true }
                            .onEnded { _ in isButtonPressed = false }
                    )
                    .animation(.easeInOut(duration: 0.2), value: isButtonPressed)
                    
                    //Alert message
                    if !alertMessage.isEmpty {
                        Text(alertMessage)
                            .foregroundColor(.red)
                    }
                    
                }
            
            .padding()
            .contentShape(Rectangle()) // Make the whole VStack tappable
            .onTapGesture {
                self.isInputActive = false
            }
            //Keyboard dismissal
            .onPreferenceChange(ViewOffsetKey.self) { minY in
                let globalButtonY = minY - keyboardHeight
                let screenHeight = UIScreen.main.bounds.height
                if globalButtonY > screenHeight / 2 {
                    keyboardHeight = 0
                }
            }
            .navigationDestination(for: String.self) { phoneNumber in
                VerificationView(phoneNumber: phoneNumber)
            }
        }
      
    }

    private func sendOTP() {
        let phoneNumberKit = PhoneNumberKit()

        do {
            let phoneNumberObject = try phoneNumberKit.parse(phoneNumber)
            let e164PhoneNumber = phoneNumberKit.format(phoneNumberObject, toType: .e164)

            Task {
                let response = try await Api.shared.sendVerificationToken(e164PhoneNumber: e164PhoneNumber)
                if response != nil {
                    DispatchQueue.main.async {
                        self.navigationPath.append(phoneNumber)
                        self.navigateToVerify = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Failed to send OTP"
                        self.showingAlert = true
                    }
                }
            }
        } catch let error as PhoneNumberError {
            DispatchQueue.main.async {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "An unexpected error occurred"
                self.showingAlert = true
            }
        }
    }


    // Function for isValidPhoneNumber
    private func isValidPhoneNumber(_ number: String) -> Bool {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let _ = try phoneNumberKit.parse(number)
                // Ensure the unformatted number is 10 digits long
                let digitsOnly = number.filter("0123456789".contains)
                return digitsOnly.count == 10
            } catch {
                return false
            }
        }
    
        // Function for convertToE164Format
        private func convertToE164Format(_ number: String) -> String? {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumber = try phoneNumberKit.parse(number)
                return phoneNumberKit.format(phoneNumber, toType: .e164)
            } catch {
                return nil
            }
        }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LaunchScreenManager())
    }
}

