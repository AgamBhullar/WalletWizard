//
//  AddAccountView.swift
//  WalletWizard
//
//  Created by Agam Bhullar on 2/7/24.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var userModel: UserModel
    @State private var accountName: String = ""
    @State private var isButtonPressed = false
    @State private var showingErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @Binding var isPresented: Bool
    @State private var buttonScale: CGFloat = 1.0
    @Environment(\.presentationMode) var presentationMode
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 22)]
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: CustomSectionHeader1(text: "Account name")) {
                        CustomTextField(placeholder: "Name", text: $accountName, placeholderColor: UIColor.gray)
                            .foregroundColor(.white)
                            .listRowBackground(Color.black.opacity(0.2))
                    }
                }
               // .listStyle(GroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(Image("Background2").overlay(Color("CustomColor1").opacity(0.2)).edgesIgnoringSafeArea(.all))
                
                Button(action: {
                    addAccount(name: accountName)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        buttonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            buttonScale = 1.0
                        }
                    }
                }) {
                    Text("Create Account")
                        .scaleEffect(buttonScale)
                        .disabled(accountName.isEmpty)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .animation(.easeInOut, value: buttonScale)
                
            }
            .navigationBarTitle("Add New Account", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }.foregroundColor(.red))
        }
    }

    func addAccount(name: String) {
        Task {
            do {
                let userResponse = try await Api.shared.createAccount(authToken: userModel.authToken ?? "", name: name)
                DispatchQueue.main.async {
                    userModel.currentUser = userResponse.user
                    isPresented = false
                }
            } catch {
                print("An error occurred while creating the account.")
            }
        }
    }
}


struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView(isPresented: .constant(true)).environmentObject(UserModel())
    }
}
