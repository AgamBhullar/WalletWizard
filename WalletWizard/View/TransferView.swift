import SwiftUI

struct TransferView: View {
    @EnvironmentObject var userModel: UserModel
    var sourceAccount: Account
    @State private var selectedAccountId: String = ""
    @State private var transferAmount: String = ""
    @State private var showingErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            
            List {
                Section(header: CustomSectionHeader1(text: "Transfer Amount")) {
                    CustomTextField2(placeholder: "$", text: $transferAmount, placeholderColor: UIColor.black)
                        .foregroundColor(.white)
                        .listRowBackground(Color.white.opacity(0.4))
                        .listRowBackground(Color.clear)

                }

                Section(header: CustomSectionHeader1(text: "To Account")) {
                    Picker(selection: $selectedAccountId, label: Text("Select Account").foregroundColor(.black)) {
                        Text("Select").tag("").foregroundColor(.white)
                        
                        ForEach(userModel.currentUser?.accounts.filter { $0.id != sourceAccount.id } ?? [], id: \.id) { account in
                            Text(account.name).tag(account.id)
                        }
                        .accentColor(.white)
                    }
                    
                    .listRowBackground(Color.white.opacity(0.4))
                }

                Button("Transfer") {
                    performTransfer()
                }
                //.foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.4))
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                        .frame(width: 100, height: 40)
                )
                .disabled(selectedAccountId.isEmpty || transferAmount.isEmpty)
            }
            
            .environment(\.defaultMinListRowHeight, 45)
            .environment(\.defaultMinListHeaderHeight, 50)
            .scrollContentBackground(.hidden)
            
            .background {
                Image("Background2")
                    .overlay(Color("CustomColor1").opacity(0.2))
            }

            .navigationBarTitle("Transfer Money", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func performTransfer() {
        guard let amountInDollars = Double(transferAmount) else {
            errorMessage = "Please enter a valid amount."
            showingErrorAlert = true
            return
        }

        
        let amountInCents = Int(round(amountInDollars * 100))

        guard amountInCents > 0 else {
            errorMessage = "Amount must be greater than 0."
            showingErrorAlert = true
            return
        }

        Task {
            do {
                let userResponse = try await Api.shared.transfer(authToken: userModel.authToken ?? "", from: sourceAccount, to: Account(name: "", id: selectedAccountId, balance: 0), amountInCents: amountInCents)
                DispatchQueue.main.async {
                    userModel.currentUser = userResponse.user
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                errorMessage = "Transfer failed. Please try again."
                showingErrorAlert = true
            }
        }
    }
}

