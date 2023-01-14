//
//  changeUsernameSwiftUI.swift
//  Recall
//
//  Created by Tristan on 14/7/22.
//

import SwiftUI
import UIKit
import CoreData
import FirebaseAuth
import Firebase

struct changePasswordSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - User Input
    @State private var password = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    @State var currentPasswords = ""
    @State private var currentUsersCountInt = 0
    @State private var newUserList = ""
    @State private var newPasswordList = ""
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    @State private var isSecured2 = true
    @State private var isSecured3 = true
    
    // MARK: - User information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - Banner Information
    @State var usernameFieldIsEmpty: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements Not Fulfilled", detail: "Please ensure that you entered your Current Password, a New Password, and properly Confirmed your New Password.", type: .Error)
    @State var currentUsernameIncorrect: BannerModifier.BannerData = BannerModifier.BannerData(title: "Current Password is Incorrect", detail: "Please ensure that the \"Current Password\" field has been filled out correctly. Do note that Passwords are case sensitive.", type: .Error)
    @State var buttonWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Error Changing Password", detail: "Sorry, there was an error changing your Password, please ensure that your Password is at least 6 characters long.", type: .Error)
    @State var successPasswordChanged: BannerModifier.BannerData = BannerModifier.BannerData(title: "Password Successfully Changed", detail: "Success! Your password has successfully been changed. Please use the new password to log in to this account from now on.", type: .Success)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    @State var showBanner3: Bool = false
    @State var showBanner4: Bool = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                Image(systemName: "person.badge.key.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 125)
                Spacer()
                Group {
                    ZStack(alignment: .trailing) {
                        Group {
                            if isSecured {
                                SecureField("Current Password", text: $password)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                            } else {
                                TextField("Current Password", text: $password)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                            }
                            Spacer()
                            Button(action: {
                                isSecured.toggle()
                                generator.impactOccurred(intensity: 0.5)
                            }) {
                                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 23, height: 23)
                                    .accentColor(.gray)
                                    .padding()
                                    .padding(.trailing, 3)
                            }
                        }
                    }
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if isSecured2 {
                                SecureField("New Password", text: $newPassword)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                            } else {
                                TextField("New Password", text: $newPassword)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                            }
                            Spacer()
                            Button(action: {
                                isSecured2.toggle()
                                generator.impactOccurred(intensity: 0.5)
                            }) {
                                Image(systemName: self.isSecured2 ? "eye.slash" : "eye")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 23, height: 23)
                                    .accentColor(.gray)
                                    .padding()
                                    .padding(.trailing, 3)
                            }
                        }
                    }
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if isSecured3 {
                                SecureField("Confirm New Password", text: $confirmNewPassword)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: confirmNewPassword != newPassword ? 2 : 0).foregroundColor(.red))
                                    .disabled(isLoggedIn == false)
                            } else {
                                TextField("Confirm New Password", text: $confirmNewPassword)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .disabled(isLoggedIn == false)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: confirmNewPassword != newPassword ? 2 : 0).foregroundColor(.red))
                                    .disabled(isLoggedIn == false)
                            }
                            
                            Spacer()
                            Button(action: {
                                isSecured3.toggle()
                                generator.impactOccurred(intensity: 0.5)
                            }) {
                                Image(systemName: self.isSecured3 ? "eye.slash" : "eye")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 23, height: 23)
                                    .accentColor(.gray)
                                    .padding()
                                    .padding(.trailing, 3)
                            }
                        }
                    }
                    if confirmNewPassword != newPassword {
                        Text("The two passwords dont match.")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .disabled(isLoggedIn == false)
                    }

                }
                Button(action: {
                    if password == finalPassword {
                        if password != "" && newPassword != "" && confirmNewPassword != "" && newPassword == confirmNewPassword {
                            
                            let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: finalPassword)
                            let user = Auth.auth().currentUser

                            user?.reauthenticate(with: credential, completion: { (result, error) in
                               if let err = error {
                                  print("error while trying to reauthenticate, error: \(err)")
                                   generator2.notificationOccurred(.error)
                               } else {
                                   print("successfully reauthenticated")
                                   Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                                       if let error = error {
                                           print("error while updating password, error code: \(error)")
                                           generator2.notificationOccurred(.error)
                                           self.buttonWarnbanner.type = .Error
                                           self.showBanner3 = true
                                       } else {
                                           print("password successfully updated")
                                           
                                           Firestore.firestore().collection("users").document(finalUID).updateData([
                                               "password": newPassword,
                                           ]) { err in
                                               if let err = err {
                                                   print("Error updating document: \(err)")
                                                   generator2.notificationOccurred(.error)
                                               } else {
                                                   print("Document successfully updated")
                                               }
                                           }
                                           
                                           finalPassword = newPassword
                                           print("successfully: \(newPassword)")
                                           generator2.notificationOccurred(.success)
                                           presentationMode.wrappedValue.dismiss()
                                       }
                                   }
                               }
                            })
                            
                            /*
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
                            let entity = NSEntityDescription.entity (forEntityName: "Accounts", in: context)
                            let newAccount = Account(entity: entity!, insertInto: context)
                            
                            do {
                                print("starting to fetch")
                                let results = try context.fetch(request)
                                for results in results {
                                    let accounts = results as! Accounts
                                    noOfAccounts += 1
                                    
                                    if currentUsernames == "" || currentUsernames == " " {
                                        currentUsernames = "\(accounts.username)"
                                    } else {
                                        currentUsernames = "\(currentUsernames)\(accounts.username)"
                                    }
                                    
                                    if currentPasswords == "" || currentPasswords == " " {
                                        currentPasswords = "\(accounts.password)"
                                    } else {
                                        currentPasswords = "\(currentPasswords)\(accounts.password)"
                                    }
                                    
                                    print("fetching")
                                }
                                
                                currentUsernames = currentUsernames.replacingOccurrences(of: ",,", with: ",")
                                currentPasswords = currentPasswords.replacingOccurrences(of: ",,", with: ",")
                                
                                currentUsernames = currentUsernames.replacingOccurrences(of: "Optional(\"", with: "")
                                currentPasswords = currentPasswords.replacingOccurrences(of: "Optional(\"", with: "")
                                
                                currentUsernames = currentUsernames.replacingOccurrences(of: "nil", with: "")
                                currentPasswords = currentPasswords.replacingOccurrences(of: "nil", with: "")
                                
                                if currentUsernames != "" {
                                    let rs = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count - 1)
                                    let re = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count)
                                    currentUsernames.replaceSubrange(rs..<re, with: "")
                                    
                                    let ra = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count - 1)
                                    let rb = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count)
                                    currentUsernames.replaceSubrange(ra..<rb, with: "")
                                }
                                
                                if currentPasswords != "" {
                                    let rx = currentPasswords.index(currentPasswords.startIndex, offsetBy: currentPasswords.count - 1)
                                    let rg = currentPasswords.index(currentPasswords.startIndex, offsetBy: currentPasswords.count)
                                    currentPasswords.replaceSubrange(rx..<rg, with: "")
                                    
                                    let rc = currentPasswords.index(currentPasswords.startIndex, offsetBy: currentPasswords.count - 1)
                                    let rd = currentPasswords.index(currentPasswords.startIndex, offsetBy: currentPasswords.count - 0)
                                    currentPasswords.replaceSubrange(rc..<rd, with: "")
                                }

                                print(currentUsernames)
                                print(currentPasswords)
                                
                                var arrayOfUsernames = currentUsernames.components(separatedBy: "\")")
                                print(arrayOfUsernames)
                                
                                var arrayOfPasswords = currentPasswords.components(separatedBy: "\")")
                                print(arrayOfPasswords)
                                
                                print("start")
                                arrayOfPasswords.indices.forEach {
                                    if arrayOfUsernames[$0] != "" {
                                        print(arrayOfUsernames[$0])
                                    }
                                }
                                print("end")
                                
                                deleteRecords()
                                
                                var currentID = arrayOfPasswords.firstIndex{$0 == password}
                                currentID = currentID!
                                
                                let currentAccUsername = arrayOfUsernames[currentID!]
                                
                                arrayOfPasswords.remove(at: currentID!)
                                print(arrayOfPasswords)
                                arrayOfUsernames.remove(at: currentID!)
                                print(arrayOfUsernames)
                                
                                print("start2")
                                arrayOfPasswords.indices.forEach {
                                    if arrayOfPasswords[$0] != "" {
                                        print("Username: \(arrayOfUsernames[$0])")
                                        print("Password \(arrayOfPasswords[$0])\n")
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                                        let entity = NSEntityDescription.entity (forEntityName: "Accounts", in: context)
                                        let newAccount = Account(entity: entity!, insertInto: context)

                                        newAccount.id = $0 as NSNumber
                                        newAccount.username = String(arrayOfUsernames[$0])
                                        newAccount.password = String(arrayOfPasswords[$0])
                                        
                                        do {
                                            try context.save()
                                            print(newAccount)
                                            print("done")
                                        } catch {
                                            print("Failed to save")
                                        }
                                    }
                                }
                                print("end2")
                                
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                                let entity = NSEntityDescription.entity (forEntityName: "Accounts", in: context)
                                let newAccount = Account(entity: entity!, insertInto: context)
                                
                                newAccount.id = currentPasswords.count as NSNumber
                                newAccount.username = currentAccUsername
                                newAccount.password = newPassword
                                finalPassword = newPassword
                                
                                print(newAccount)
                                
                                do {
                                    try context.save()
                                    print("done 2")
                                    
                                    // self.successPasswordChanged.type = .Success
                                    // self.showBanner4 = true
                                    
                                    generator2.notificationOccurred(.success)
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print("Failed to save 2")
                                }
                                
                                
                                currentPasswords = ""
                                currentUsernames = ""
                                arrayOfUsernames = []
                                arrayOfPasswords = []
                                noOfAccounts = 0
                                /*
                                 print(currentUsernames)
                                 
                                 let str = currentUsernames
                                 var arrayOfUsernames = str.components(separatedBy: ",")
                                 print(arrayOfUsernames)
                                 
                                 print("got arr of user")
                                 
                                 currentUsernames = ""
                                 
                                 if let i = arrayOfUsernames.firstIndex(of: username) {
                                 arrayOfUsernames[i] = newUsername
                                 finalUsername = newUsername
                                 }
                                 */
                            } catch {
                                print("Fetch failed")
                            }
                            */
                        } else {
                            if isBannerOn {
                                self.usernameFieldIsEmpty.type = .Error
                                self.showBanner = true
                            }
                            generator2.notificationOccurred(.error)
                        }
                    } else if password == "" || newPassword == "" || confirmNewPassword == "" || confirmNewPassword != newPassword {
                        if isBannerOn {
                            self.usernameFieldIsEmpty.type = .Error
                            self.showBanner = true
                        }
                        generator2.notificationOccurred(.error)
                    } else if password != currentPasswords {
                        if isBannerOn {
                            self.currentUsernameIncorrect.type = .Error
                            self.showBanner2 = true
                        }
                        generator2.notificationOccurred(.error)
                    }
                }) {
                    Text("Change Password")
                        .bold()
                        .frame(width: 360, height: 50)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 15)
                }
                .padding(.top)
            }
            .padding()
            .background(Color("bgColorTab"))
            .navigationBarTitle(Text("Change Password"), displayMode: .inline)
            .background(NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = .systemBackground
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.label]
            })
            .navigationBarItems(
                trailing:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "xmark")
                    })
            // // .banner(data: $usernameFieldIsEmpty, show: $showBanner)
            // // .banner(data: $currentUsernameIncorrect, show: $showBanner2)
            // // .banner(data: $buttonWarnbanner, show: $showBanner3)
            // // .banner(data: $successPasswordChanged, show: $showBanner4)


        }
        .navigationViewStyle(StackNavigationViewStyle())
        // .banner(data: $usernameFieldIsEmpty, show: $showBanner)
        // .banner(data: $currentUsernameIncorrect, show: $showBanner2)
        // .banner(data: $buttonWarnbanner, show: $showBanner3)
        // .banner(data: $successPasswordChanged, show: $showBanner4)
    }
}

/*
func deleteRecords() {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.persistentContainer.viewContext

    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

    print(deleteRequest)
    print(deleteFetch.description)
    
    do {
        try context.execute(deleteRequest)
        try context.save()
    } catch {
        print ("There was an error")
    }
}
*/

struct changePasswordSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        changePasswordSwiftUI()
    }
}
