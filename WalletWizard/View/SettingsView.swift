//
//  SettingsView.swift
//  WalletWizard
//
//  Created by Agam Bhullar on 1/30/24.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var userModel: UserModel
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var editingName: Bool = false
    @FocusState private var isUsernameFocused: Bool
    @State private var showSuccessMessage = false
    @State private var buttonScale: CGFloat = 1.0
    
    init() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 30)]
            appearance.shadowColor = nil
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }

    var body: some View {
        NavigationView {
            List {
                Section(header: CustomSectionHeader(text: "Profile")) {
                    CustomTextField(placeholder: "Username", text: $username, placeholderColor: UIColor.gray)
                        .foregroundColor(.white)
                        .focused($isUsernameFocused)
                        .disabled(!editingName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                    HStack {
                        Text(userModel.currentUser?.e164PhoneNumber ?? "")
                            .foregroundColor(.white)
                    }
                }
                .listRowSeparatorTint(.orange)
                .listRowBackground(Color.black.opacity(0.2))
                
                Section {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                                buttonScale = 0.95
                            }
                            // Reset the scale back to normal after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                buttonScale = 1.0 // Scale back to 100%
                            }
                        }
                        
                        if editingName {
                            updateUsername()
                        }
                        editingName.toggle()
                        if editingName { // Check if the mode is now editing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isUsernameFocused = true
                            }
                        }
                    }) {
                        ZStack {
                            Color.black.opacity(0.2)
                                .frame(width: 80, height: 40)
                                .cornerRadius(10)
                            
                            Text(editingName ? "Save" : "Edit")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                    .scaleEffect(buttonScale)
                    .animation(.easeInOut, value: buttonScale)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    
                    Button(action: userModel.logout) {
                        ZStack {
                            Color.black.opacity(0.2)
                                .frame(width: 100, height: 40)
                                .cornerRadius(10)
                            
                            Text("Logout")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                    }
                    
                    
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                if showSuccessMessage {
                    Text("Username updated successfully!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 1), value: showSuccessMessage)
                }
                
            }
            .environment(\.defaultMinListRowHeight, 45)
            .environment(\.defaultMinListHeaderHeight, 50)
            .scrollContentBackground(.hidden)
            
            .background {
                Image("Background2")
                    
                    .overlay(Color("CustomColor1").opacity(0.2))
            }

            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(Color("CustomColor1"))
                    .imageScale(.large)
            })
            .onAppear {
                if let currentName = userModel.currentUser?.name {
                    username = currentName
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }

    private func updateUsername() {
        Task {
            await userModel.updateUsername(username)
            if let error = userModel.apiError {
                
            } else {
                editingName = false
                withAnimation {
                    showSuccessMessage = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                    showSuccessMessage = false
                    }
                }
            }
        }
    }
}

struct CustomSectionHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title3)
            .bold()
            .foregroundColor(.white)
            .shadow(radius: 5)
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(UserModel())
    }
}
