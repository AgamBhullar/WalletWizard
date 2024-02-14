//
//  VerificationView.swift
//  WalletWizard
//
//  Created by Agam Bhullar on 1/22/24.
//

import SwiftUI
import PhoneNumberKit



struct VerificationView: View {
    @State private var isButtonPressed = false
    @State private var animate: Bool = false
    @State private var codeDigits = Array(repeating: "", count: 6)
    @State private var errorMessage: String = ""
    @State private var isVerificationSuccessful = false
    @State private var otpSentMessage: String = ""
    @State var otpText: String = ""
    @FocusState private var isKeyboardShowing: Bool
    let phoneNumber: String
    
    @EnvironmentObject var userModel: UserModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                        Image(systemName: "arrow.left")
                        .foregroundColor(Color("CustomColor1"))
                        .imageScale(.large)
                        .padding(.top, 30)
                    }
                    Spacer()
                }
           
            Image("Frame")
                .resizable()
                .scaledToFill()
                .frame(width: 420, height: 180)
                .padding(.bottom, 30)
                .overlay {
                    Text("Verification Code")
                        .font(Font.custom("Salsa-Regular", size:40))
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(width: 350, height: 350)
                    }
                
            Text("Enter the code sent to \(phoneNumber)")
            .font(Font.custom("Salsa-Regular", size: 20))
                    .foregroundColor(Color.black)
                        
            HStack(spacing: 0){
                ForEach(0..<6,id: \.self){index in
                    OTPTextBox(index)
                }
                .onSubmit {
                    verifyCode()
                }
            }
            .background(content: {
                TextField("", text: $otpText.limit(6))
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .blendMode(.screen)
                    .focused($isKeyboardShowing)
                    .onChange(of: otpText) { newValue in
                        if newValue.count == 6 {
                            verifyCode()
                        }
                    }
            })
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardShowing = true
            }
            .onAppear {
                isKeyboardShowing = true
            }
            
            .padding(.bottom, 20)
            
            Button(action: resendCode) {
                Text("Resend Code")
                    .font(Font.custom("Salsa-Regular", size:18))
                    .foregroundColor(.white)
                    .padding()
                    .background(isButtonPressed ? Color("CustomColor1").opacity(0.8) : Color("CustomColor1"))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .scaleEffect(isButtonPressed ? 0.95 : 1.0)
            }

            Text(errorMessage)
                .font(Font.custom("Salsa-Regular", size: 16))
                .foregroundColor(.red)
                .padding(.top, 10)
            
            if !otpSentMessage.isEmpty {
                    Text(otpSentMessage)
                        .foregroundColor(Color.green)
                        .padding()
                }
            
            Text(otpSentMessage)
                .foregroundColor(Color.green)
                .padding()
                .opacity(otpSentMessage.isEmpty ? 0 : 1)
            
            Spacer()
            
            NavigationLink("", destination: HomeView(), isActive: $isVerificationSuccessful)
            
                
        }
        
        .navigationBarBackButtonHidden(true)
    }

    func verifyCode() {
        guard otpText.count == 6 else {
            errorMessage = "Please enter the 6-digit code."
            return
        }

        let phoneNumberKit = PhoneNumberKit()

        Task {
            do {
                let phoneNumberObject = try phoneNumberKit.parse(phoneNumber)
                let e164PhoneNumber = phoneNumberKit.format(phoneNumberObject, toType: .e164)

                let response = try await Api.shared.checkVerificationToken(e164PhoneNumber: e164PhoneNumber, code: otpText)
                
                DispatchQueue.main.async {
                    userModel.saveAuthToken(response.authToken)
                    userModel.savePhoneNumber(e164PhoneNumber)
                    isVerificationSuccessful = true
                }
                
            } catch let apiError as ApiError {
                DispatchQueue.main.async {
                    errorMessage = apiError.message
                    otpText = ""
                    isKeyboardShowing = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "An unknown server error occurred"
                    otpText = ""
                    isKeyboardShowing = true
                }
            }
        }
    }

    func resendCode() {
        let phoneNumberKit = PhoneNumberKit()

        Task {
            do {
                let phoneNumberObject = try phoneNumberKit.parse(phoneNumber)
                let e164PhoneNumber = phoneNumberKit.format(phoneNumberObject, toType: .e164)
                
                let _ = try await Api.shared.sendVerificationToken(e164PhoneNumber: e164PhoneNumber)
                
                DispatchQueue.main.async {
                    self.otpSentMessage = "OTP Sent"
                    self.errorMessage = ""
                    self.otpText = ""
                    self.codeDigits = Array(repeating: "", count: 6)
                    self.isKeyboardShowing = true
                }
            } catch let error as PhoneNumberError {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            } catch let apiError as ApiError {
                DispatchQueue.main.async {
                    errorMessage = apiError.message
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to resend code"
                }
            }
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int)->some View{
        ZStack{
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            }else{
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color("CustomColor1"),lineWidth: 0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(phoneNumber: "+16692514001")
    }
}


extension Binding where Value == String {
    func limit(_ length: Int)->Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
