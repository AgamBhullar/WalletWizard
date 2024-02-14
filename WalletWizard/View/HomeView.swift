//
//  HomeView.swift
//  WalletWizard
//
//  Created by Agam Bhullar on 1/22/24.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var userModel: UserModel
    @State private var accountsLoaded = false
    @State private var showingAddAccountView = false

    var totalAssets: Double {
        userModel.currentUser?.accounts.reduce(0) { $0 + $1.balanceInUsd() } ?? 0
    }
    
    init() {
            // Use UINavigationBarAppearance to change the title color
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "Background")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            appearance.shadowColor = .black 
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

    var body: some View {
        NavigationView {
            ZStack {
                // Set the background color for the entire view
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("\(String(format: "$%.2f", totalAssets))")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 100)
                    
                    if let accounts = userModel.currentUser?.accounts, !accounts.isEmpty {
                        List(accounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account).environmentObject(userModel)) {
                                HStack {
                                    Text(account.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(account.balanceString())
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                .listRowInsets(EdgeInsets())
                            }
                            .listRowBackground(Color.clear)
                            
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    } else if accountsLoaded {
                        Text("No Accounts Created")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ProgressView().padding()
                    }
                    
                    Spacer()
                }
                .navigationBarTitle("Wallet Wizard", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        showingAddAccountView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    },
                    trailing: NavigationLink(destination: SettingsView().environmentObject(userModel)) {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                        
                    }
                )
                .sheet(isPresented: $showingAddAccountView) {
                    AddAccountView(isPresented: $showingAddAccountView).environmentObject(userModel)
                }
                
                .onAppear {
                    loadAccounts()
                }
            }
        }
    }

    private func loadAccounts() {
        guard let authToken = userModel.authToken else {
            print("No auth token available.")
            return
        }

        Task {
            do {
                let userResponse = try await Api.shared.user(authToken: authToken)
                DispatchQueue.main.async {
                    userModel.currentUser = userResponse.user
                    accountsLoaded = true
                }
            } catch {
                print("Failed to fetch accounts.")
                accountsLoaded = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserModel())
    }
}
