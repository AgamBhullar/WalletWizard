//
//  AccountDetailView.swift
//  WalletWizard
//
//  Created by Agam Bhullar on 2/7/24.
//

import SwiftUI
import UIKit


struct AccountDetailView: View {
    @EnvironmentObject var userModel: UserModel
    @State private var transactionAmount: String = ""
    @State private var showingErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingTransferView: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isInputActive: Bool
    @Environment(\.presentationMode) var presentationMode
    var account: Account
    
    init(account: Account) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        self.account = account
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        Text(account.balanceString())
                            .padding(.top, 10)
                            .font(.system(size: 40))
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .listRowBackground(Color.clear)
                    }
                    
                    Section(header: CustomSectionHeader1(text: "Enter an Amount")) {
                        CustomTextField2(placeholder: "$", text: $transactionAmount, placeholderColor: UIColor.gray)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.2)))
                            .listRowBackground(Color.clear)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                }
                .listStyle(GroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(Image("Background2").blur(radius: 3).overlay(Color("CustomColor1").opacity(0.2)).edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                
                HStack(spacing: 10) {
                    Button(action: {
                        performTransaction(amount: transactionAmount, type: .deposit)
                    }) {
                        Text("Deposit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {
                        performTransaction(amount: transactionAmount, type: .withdraw)
                    }) {
                        Text("Withdraw")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {
                        showingTransferView = true
                    }) {
                        Text("Transfer")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .sheet(isPresented: $showingTransferView) {
                        TransferView(sourceAccount: account).environmentObject(userModel)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            
            
            .navigationTitle("\(account.name) Details")
            .navigationBarItems(trailing: Button(action: deleteAccount) {
                Image(systemName: "trash").foregroundColor(.red)
            })
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left").foregroundColor(.orange).imageScale(.large)
            })
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarBackButtonHidden(true)
    }

        func performTransaction(amount: String, type: TransactionType) {
            guard let amountInDollars = Double(amount), amountInDollars > 0 else {
                errorMessage = "Please enter a valid amount"
                showingErrorAlert = true
                return
            }
    
            let amountInCents = Int(amountInDollars * 100)
    
            guard amountInCents > 0 else {
                showingErrorAlert = true
                return
            }
    
            Task {
                do {
                    let userResponse: UserResponse
                    if type == .deposit {
                        userResponse = try await Api.shared.deposit(authToken: userModel.authToken ?? "", account: account, amountInCents: amountInCents)
                    } else if type == .withdraw {
                        userResponse = try await Api.shared.withdraw(authToken: userModel.authToken ?? "", account: account, amountInCents: amountInCents)
                    } else {
                        return
                    }
                    DispatchQueue.main.async {
                        userModel.currentUser = userResponse.user
                    }
                } catch {
                    errorMessage = type == .deposit ? "Failed to deposit. Please try again." : "Insufficient balance for withdrawal"
                    showingErrorAlert = true
                }
            }
        }
    
    
        func deleteAccount() {
            Task {
                do {
                    let userResponse = try await Api.shared.deleteAccount(authToken: userModel.authToken ?? "", account: account)
                    DispatchQueue.main.async {
                        userModel.currentUser = userResponse.user
                    }
                } catch {
                    showingErrorAlert = true
                }
            }
        }
    }

enum TransactionType {
    case deposit
    case withdraw
}

struct CustomSectionHeader1: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15))
            //.frame(maxWidth: .infinity)
            .bold()
            .foregroundColor(.white)
            .shadow(radius: 5)
            //.keyboardType(.decimalPad)

    }
}

#if canImport(UIKit)
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailView(account: Account(name: "Sample Account", id: "1", balance: 10000))
            .environmentObject(UserModel())
    }
}
