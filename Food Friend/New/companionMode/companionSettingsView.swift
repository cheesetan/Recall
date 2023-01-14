//
//  companionSettingsView.swift
//  Food Friend
//
//  Created by Tristan on 1/11/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct companionSettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("companionpremiumMode", store: .standard) private var companionpremiumMode = false
    
    @AppStorage("finalDN", store: .standard) private var finalDN = "Companion"
    
    @AppStorage("autoDeleteRecalls", store: .standard) private var autoDeleteRecalls = true
    
    @State private var showingSignOutAlert = false
    
    @State private var showingChangeAccount = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Current Account")) {
                    VStack {
                        Text("Connected")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            showingChangeAccount.toggle()
                        } label: {
                            HStack {
                                VStack {
                                    ZStack {
                                        Image(systemName: "person.fill")
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40, alignment: .center)
                                            .foregroundColor(Color.white)
                                            .padding(15)
                                            .background(.gray)
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                }
                                .padding(.trailing, 8)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(finalEmail)
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.primary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .sheet(isPresented: $showingChangeAccount) {
                            changeAccount()
                                .presentationDetents([.medium, .large])
                        }
                    }
                }
                .listRowBackground(Color("bgColorTab2"))
                
                if companionpremiumMode {
                    Section(header: HStack {
                        Image(systemName: "message")
                        Text("Messaging Display Name")
                    }, footer: Text("This will only affect messages sent after you changed your display name.")) {
                        VStack {
                            TextField("Enter a Display Name", text: $finalDN)
                                .padding(10)
                                .padding(.vertical, 5)
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                }
                Section(header: HStack {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Recalls")
                }, footer: Text("Automatically delete Recalls that are past its due date.")) {
                    Toggle(isOn: $autoDeleteRecalls, label: {
                        Text("Automatically Delete Recalls")
                    })
                }
                .listRowBackground(Color("bgColorTab2"))

                
                if finalEmail == "tristanchay123@gmail.com" {
                    Section(header: HStack {
                        Image(systemName: "hammer")
                        Text("Developer")
                    }) {
                        Button {
                            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
                                for request in requests {
    //                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                                    print(request.identifier)
                                }
                            })
                        } label: {
                            Text("Check All Pending Notifs")
                        }
//                        Toggle(isOn: $companionpremiumMode, label: {
//                            Text("Simulate Premium Mode")
//                        })
                    }
                    .listRowBackground(Color("bgColorTab2"))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(Color("bgColorTab"))
            .scrollContentBackground(.hidden)
            .formStyle(GroupedFormStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                        generator.impactOccurred(intensity: 0.7)
                    } label: {
                        Text("Disconnect")
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .alert("Disconnect", isPresented: $showingSignOutAlert, actions: {
                        Button("No", role: .cancel, action: {
                            
                        })
                        Button(role: .destructive) {
                            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                Firestore.firestore().collection("users").document(finalUID).updateData([
                                    "companions-uuid": FieldValue.arrayRemove([uuid]),
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                        generator2.notificationOccurred(.error)
                                    } else {
                                        print("Document successfully updated")
                                        
                                        finalEmail = ""
                                        finalPassword = ""
                                        //finalUID = ""
                                        finalDN = ""
                                        isCompLogged = false
                                    }
                                }
                            }
                        } label: {
                            Text("Yes")
                        }
                    }, message: {
                        Text("Would you like to disconnect from the account \(finalEmail)? You can reconnect by scanning/entering the code again.")
                    })
                }
            }
            .onChange(of: autoDeleteRecalls) { newValue in
                if autoDeleteRecalls == true {
                    Firestore.firestore().collection("users").document(finalUID).updateData([
                        "autodelete": "true",
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    Firestore.firestore().collection("users").document(finalUID).updateData([
                        "autodelete": "false",
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        }
    }
}

struct changeAccount: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Account 2")) {
                        VStack {
                            Text("Not Connected")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                VStack {
                                    ZStack {
                                        Image(systemName: "person.fill")
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40, alignment: .center)
                                            .foregroundColor(Color.white)
                                            .padding(15)
                                            .background(.gray)
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                }
                                .padding(.trailing, 8)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Tap to connect account")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.primary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                    
                    Section(header: Text("Account 3")) {
                        VStack {
                            Text("Not Connected")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                VStack {
                                    ZStack {
                                        Image(systemName: "person.fill")
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40, alignment: .center)
                                            .foregroundColor(Color.white)
                                            .padding(15)
                                            .background(.gray)
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                }
                                .padding(.trailing, 8)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Tap to connect account")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.primary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                }
            }
            .toolbar {
                /*
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                 */
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Change accounts")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct companionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        companionSettingsView()
    }
}
