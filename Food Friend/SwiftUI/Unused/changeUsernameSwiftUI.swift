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

struct changeUsernameSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - User Input
    @State private var username = ""
    @State private var newUsername = ""
    
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
    
    // MARK: - User information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - Banner Information
    @State var usernameFieldIsEmpty: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements Not Fulfilled", detail: "Please ensure that you entered your Current Email and a New Email", type: .Error)
    @State var currentUsernameIncorrect: BannerModifier.BannerData = BannerModifier.BannerData(title: "Current Email is Incorrect", detail: "Please ensure that the \"Current Email\" field has been filled out correctly.", type: .Error)
    @State var buttonWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Error Changing Email", detail: "Sorry, that is either not a valid Email or it has already been registered.", type: .Error)
    @State var successUsernameChanged: BannerModifier.BannerData = BannerModifier.BannerData(title: "Email Successfully Changed", detail: "Success! Your Email has successfully been changed. Please use this new Email to log in to your account from now on.", type: .Success)
    @State var usernameAlreadyYours: BannerModifier.BannerData = BannerModifier.BannerData(title: "Cant change Email to current one", detail: "You cannot change your Email to the Email you already have!", type: .Error)
    
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    @State var showBanner3: Bool = false
    @State var showBanner4: Bool = false
    @State var showBanner5: Bool = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 125)
                Spacer()
                Group {
                    TextField("Current Email", text: $username)
                        .padding(20)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .padding(.top, 37)
                        .disabled(isLoggedIn == false)
                    TextField("New Email", text: $newUsername)
                        .padding(20)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .disabled(isLoggedIn == false)
                }
                Button(action: {
                    if username != "" && newUsername != "" {
                        if username == finalEmail {
                            if newUsername == finalEmail {
                                self.usernameAlreadyYours.type = .Error
                                self.showBanner5 = true
                                generator2.notificationOccurred(.error)
                            } else {
                                let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: finalPassword)
                                let user = Auth.auth().currentUser

                                user?.reauthenticate(with: credential, completion: { (result, error) in
                                   if let err = error {
                                      print("error while trying to reauthenticate, error: \(err)")
                                       generator2.notificationOccurred(.error)
                                   } else {
                                       print("successfully reauthenticated")
                                       Auth.auth().currentUser?.updateEmail(to: newUsername) { error in
                                           if let error = error {
                                               print("error while updating email address, error code: \(error)")
                                               generator2.notificationOccurred(.error)
                                               self.buttonWarnbanner.type = .Error
                                               self.showBanner3 = true
                                           } else {
                                               print("email successfully updated")
                                               
                                               finalEmail = (Auth.auth().currentUser?.email!)!
                                               
                                               Firestore.firestore().collection("users").document(finalUID).updateData([
                                                   "email": finalEmail,
                                               ]) { err in
                                                   if let err = err {
                                                       print("Error updating document: \(err)")
                                                       generator2.notificationOccurred(.error)
                                                   } else {
                                                       print("Document successfully updated")
                                                       generator2.notificationOccurred(.success)
                                                       presentationMode.wrappedValue.dismiss()
                                                   }
                                               }
                                           }
                                       }
                                   }
                                })
                            }
                        } else {
                            self.currentUsernameIncorrect.type = .Error
                            self.showBanner2 = true
                            generator2.notificationOccurred(.error)
                        }
                    } else {
                        self.usernameFieldIsEmpty.type = .Error
                        self.showBanner = true
                        generator2.notificationOccurred(.error)
                    }

                    /*
                    if username == finalUsername {
                        if username != "" && newUsername != "" {
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
                                arrayOfUsernames.indices.forEach {
                                    if arrayOfUsernames[$0] != "" {
                                        print(arrayOfUsernames[$0])
                                    }
                                }
                                print("end")
                                
                                if arrayOfUsernames.contains(newUsername) {
                                    if isBannerOn {
                                        self.buttonWarnbanner.type = .Error
                                        self.showBanner3 = true
                                    }
                                    generator2.notificationOccurred(.error)
                                } else {
                                    deleteRecords()
                                    
                                    var currentID = arrayOfUsernames.firstIndex{$0 == username}
                                    currentID = currentID!
                                    
                                    let currentAccPassword = arrayOfPasswords[currentID!]
                                    
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
                                    
                                    newAccount.id = currentUsernames.count as NSNumber
                                    newAccount.username = newUsername
                                    newAccount.password = currentAccPassword
                                    finalUsername = newUsername
                                    
                                    print(newAccount)
                                    
                                    do {
                                        try context.save()
                                        print("done 2")
                                        
                                        // self.successUsernameChanged.type = .Success
                                        // self.showBanner4 = true
                                        
                                        generator2.notificationOccurred(.success)
                                        presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        print("Failed to save 2")
                                    }
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
                        } else {
                            if isBannerOn {
                                self.usernameFieldIsEmpty.type = .Error
                                self.showBanner = true
                            }
                            generator2.notificationOccurred(.error)
                        }
                    } else {
                        if username != "" && username != finalUsername {
                            if isBannerOn {
                                self.currentUsernameIncorrect.type = .Error
                                self.showBanner2 = true
                            }
                            generator2.notificationOccurred(.error)
                        } else if newUsername == finalUsername {
                            if isBannerOn {
                                self.usernameAlreadyYours.type = .Error
                                self.showBanner5 = true
                            }
                            generator2.notificationOccurred(.error)
                        } else {
                            if isBannerOn {
                                self.usernameFieldIsEmpty.type = .Error
                                self.showBanner = true
                            }
                            generator2.notificationOccurred(.error)
                        }
                    }
                    */
                }) {
                    Text("Change Email")
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
            .navigationBarTitle(Text("Change Email"), displayMode: .inline)
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
            //// .banner(data: $signUpWarnbanner, show: $showBanner)
            //// .banner(data: $buttonWarnbanner, show: $showBanner2)
            //// .banner(data: $buttonWarnbanner, show: $showBanner3)
            //// .banner(data: $successUsernameChanged, show: $
            //// .banner(data: $usernameAlreadyYours, show: $showBanner5)


        }
        .navigationViewStyle(StackNavigationViewStyle())
        // .banner(data: $usernameFieldIsEmpty, show: $showBanner)
        // .banner(data: $currentUsernameIncorrect, show: $showBanner2)
        // .banner(data: $buttonWarnbanner, show: $showBanner3)
        // .banner(data: $successUsernameChanged, show: $showBanner4)
        // .banner(data: $usernameAlreadyYours, show: $showBanner5)
    }
}

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

struct changeUsernameSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        changeUsernameSwiftUI()
    }
}
