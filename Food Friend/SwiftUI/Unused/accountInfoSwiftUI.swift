//
//  accountInfoSwiftUI.swift
//  Recall
//
//  Created by Tristan on 14/7/22.
//

import SwiftUI
import CoreData
import UIKit
import Firebase
import LocalAuthentication

struct accountInfoSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Image Picker
    @State private var image = UIImage()
    @State private var image2: UIImage?
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    
    // MARK: - Password Section
    @State private var isPasswordShowing = false
    
    // MARK: - Temporary Developer Mode Reset
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    
    // MARK: - Showing Alerts
    @State private var showingShowPasswordAlert = false
    @State private var showingChangeUserAlert = false
    @State private var showingChangePWAlert = false
    @State private var showingChangeUserAlert2 = false
    @State private var showingChangePWAlert2 = false

    
    // MARK: - Showing Views
    @State private var showingChangeUser = false
    @State private var showingChangeUser2 = false
    @State private var showingChangePassword = false
    @State private var showingDeleteFields = false
    @State private var showingUserChoice = false
    @State private var isShowingForgotView = false
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    @State var currentPasswords = ""
    @State private var currentUsersCountInt = 0
    @State private var newUserList = ""
    @State private var newPasswordList = ""
    
    // MARK: - User Input
    @State private var username = ""
    @State private var password = ""
    @State private var justShowed = true
    
    @State private var getCurPW = ""
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    @State private var isSecured2 = true
    
    // MARK: - User information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - Banner Information
    @State var fieldIsEmpty: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements Not Fulfilled", detail: "Please ensure that you entered your Email and Password.", type: .Error)
    @State var userOrPWIncorrect: BannerModifier.BannerData = BannerModifier.BannerData(title: "Could Not Delete Account", detail: "This account does not exist, or you have entered the wrong Email and/or Password. Do note that Passwords are case sensitive.", type: .Error)
    @State var cldntVerify: BannerModifier.BannerData = BannerModifier.BannerData(title: "Could Not Authenticate", detail: "The Password you entered is incorrect. Do note that Passwords are case sensitive.", type: .Error)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    @State var showBanner3: Bool = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    @State private var curShowUser = ""
    
    @AppStorage("bioAvailable", store: .standard) private var bioAvailable = ""
    @AppStorage("faceIDaccount", store: .standard) private var faceIDaccount = false
    
    // MARK: - Initialises imageData to saved image in UserDefaults
    init() {
        if let imageData = UserDefaults.standard.data(forKey: "image") {
            self._image2 = State(wrappedValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if showingUserChoice {
                    Form {
                        // MARK: - Email Change
                        Section(header: Text("Email Address")) {
                            HStack {
                                Text("Email: ")
                                Spacer()
                                Text("\(finalEmail)")
                            }
                            .padding(2)
                            HStack {
                                Spacer()
                                Button {
                                    showingChangeUser = true
                                    generator.impactOccurred(intensity: 0.7)
                                } label: {
                                    Text("Change Email")
                                }
                                .padding(10.5)
                                .foregroundColor(.white)
                                .sheet(isPresented: $showingChangeUser) {
                                    changeUsernameSwiftUI()
                                }
                                Spacer()
                            }
                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .listRowBackground(Color("bgColorTab2"))

                        // MARK: - Password Change
                        Section(header: Text("Password")) {
                            HStack {
                                Button {
                                    if isPasswordShowing == false {
                                        showingShowPasswordAlert = true
                                        generator.impactOccurred(intensity: 0.7)
                                    } else {
                                        isPasswordShowing = false
                                        generator.impactOccurred(intensity: 0.7)
                                    }
                                } label: {
                                    if isPasswordShowing == false {
                                        Text("Show Password")
                                            .padding(7)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .background(.thinMaterial)
                                            .foregroundColor(.blue)
                                            .cornerRadius(7)
                                            .padding(2)
                                    } else {
                                        Text("Hide Password")
                                            .padding(7)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .background(.ultraThinMaterial)
                                            .foregroundColor(.blue)
                                            .cornerRadius(7)
                                            .padding(2)
                                    }
                                }
                                .alert("Show Password", isPresented: $showingShowPasswordAlert, actions: {
                                    Button("No", role: .cancel, action: {
                                        
                                    })
                                    Button("Yes", role: .destructive, action: {
                                        isPasswordShowing = true
                                    })
                                }, message: {
                                    Text("Are you sure you want to show your password?")
                                    
                                })
                                Spacer()
                                if isPasswordShowing {
                                    Text("\(finalPassword)")
                                } else {
                                    Text("\(finalPassword)")
                                        .redacted(reason: .placeholder)
                                }
                            }
                            HStack {
                                Spacer()
                                Button {
                                    showingChangePassword = true
                                    // showingChangePWAlert = true
                                    generator.impactOccurred(intensity: 0.7)
                                } label: {
                                    Text("Change password")
                                }
                                .padding(10.5)
                                .foregroundColor(.white)
                                /*
                                 .alert("Send \"Change Password\" request", isPresented: $showingChangePWAlert, actions: {
                                 Button("No", role: .cancel, action: {
                                 generator.impactOccurred(intensity: 0.7)
                                 })
                                 Button(role: .destructive) {
                                 do {
                                 showingChangePWAlert2 = true
                                 FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: finalUsername)
                                 generator2.notificationOccurred(.success)
                                 
                                 try FirebaseAuth.Auth.auth().signOut()
                                 isLoggedIn = false
                                 finalUsername = ""
                                 finalPassword = ""
                                 print("firebase cur auth: \(String(describing: FirebaseAuth.Auth.auth().currentUser))")
                                 
                                 presentationMode.wrappedValue.dismiss()
                                 } catch {
                                 print("An error has occurred while trying to sign out.")
                                 }
                                 } label: {
                                 Text("Yes")
                                 }
                                 }, message: {
                                 Text("Are you sure you want to send a \"Change Password\" request? You will be signed out and will have to log in again after changing your password.")
                                 
                                 })
                                 .alert("Request Sent", isPresented: $showingChangePWAlert2, actions: {
                                 Button("OK", role: .cancel, action: {
                                 generator.impactOccurred(intensity: 0.7)
                                 })
                                 }, message: {
                                 Text("Please check the email tied to this account for your \"Change Password\" reuqest. Do remember to check your spam folder if you cannot find the request.")
                                 })
                                 */
                                
                                .sheet(isPresented: $showingChangePassword) {
                                    changePasswordSwiftUI()
                                }
                                
                                Spacer()
                            }
                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .listRowBackground(Color("bgColorTab2"))

                        // MARK: - Delete Accounts
                        Section(header: Text("Delete Your Account")) {
                            if showingDeleteFields {
                                Group {
                                    Text("Please enter your Email and Password to delete your account:")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .padding(5)
                                    TextField("Current Email", text: $username)
                                        .padding(17)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                        .textInputAutocapitalization(.never)
                                        .disabled(isLoggedIn == false)
                                    ZStack(alignment: .trailing) {
                                        if isSecured {
                                            SecureField("Current Password", text: $password)
                                                .padding(17)
                                                .background(.thinMaterial)
                                                .cornerRadius(10)
                                                .disabled(isLoggedIn == false)
                                        } else {
                                            TextField("Current Password", text: $password)
                                                .padding(17)
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
                                .transition(.scale)
                            }
                            HStack {
                                Spacer()
                                Button {
                                    showingDeleteFields = true
                                    
                                    if justShowed == false {
                                        if username != "" && password != "" {
                                            if username == (Auth.auth().currentUser?.email!)! && password == finalPassword {
                                                
                                                let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: finalPassword)
                                                let user = Auth.auth().currentUser
                                                
                                                user?.reauthenticate(with: credential, completion: { (result, error) in
                                                    if let err = error {
                                                        print("error while trying to reauthenticate, error: \(err)")
                                                        generator2.notificationOccurred(.error)
                                                    } else {
                                                        print("successfully reauthenticated")
                                                        let user = Auth.auth().currentUser
                                                        
                                                        user?.delete { error in
                                                            if let error = error {
                                                                print("error while deleting user account, error code: \(error)")
                                                            } else {
                                                                Firestore.firestore().collection("users").document(finalUID).delete() { err in
                                                                    if let err = err {
                                                                        print("Error removing document: \(err)")
                                                                        generator2.notificationOccurred(.error)
                                                                    } else {
                                                                        print("Document successfully removed!")
                                                                        generator2.notificationOccurred(.success)
                                                                    }
                                                                }
                                                                
                                                                isLoggedIn = false
                                                                finalUsername = ""
                                                                finalPassword = ""
                                                                finalEmail = ""
                                                                
                                                                showingUserChoice = false
                                                                presentationMode.wrappedValue.dismiss()
                                                            }
                                                        }
                                                    }
                                                })
                                                
                                                
                                                /*
                                                 generator.impactOccurred(intensity: 0.7)
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
                                                 
                                                 var currentID = arrayOfUsernames.firstIndex{$0 == username}
                                                 print(currentID)
                                                 currentID = currentID!
                                                 
                                                 arrayOfPasswords.remove(at: currentID!)
                                                 print(arrayOfPasswords)
                                                 arrayOfUsernames.remove(at: currentID!)
                                                 print(arrayOfUsernames)
                                                 
                                                 deleteRecords()
                                                 
                                                 print("start2")
                                                 arrayOfPasswords.indices.forEach {
                                                 if arrayOfPasswords[$0] != "" {
                                                 print("gde456")
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
                                                 
                                                 isLoggedIn = false
                                                 finalUsername = ""
                                                 finalPassword = ""
                                                 
                                                 generator2.notificationOccurred(.success)
                                                 presentationMode.wrappedValue.dismiss()
                                                 } catch {
                                                 print("Failed to save")
                                                 }
                                                 } else {
                                                 print(newAccount)
                                                 print("done2")
                                                 
                                                 isLoggedIn = false
                                                 finalUsername = ""
                                                 finalPassword = ""
                                                 
                                                 generator2.notificationOccurred(.success)
                                                 presentationMode.wrappedValue.dismiss()
                                                 }
                                                 }
                                                 print("end2")
                                                 print(newAccount)
                                                 print("done2")
                                                 
                                                 isLoggedIn = false
                                                 finalUsername = ""
                                                 finalPassword = ""
                                                 
                                                 generator2.notificationOccurred(.success)
                                                 presentationMode.wrappedValue.dismiss()
                                                 
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
                                                    self.userOrPWIncorrect.type = .Error
                                                    self.showBanner2 = true
                                                }
                                                generator2.notificationOccurred(.error)
                                            }
                                        } else {
                                            if isBannerOn {
                                                self.fieldIsEmpty.type = .Error
                                                self.showBanner = true
                                            }
                                            generator2.notificationOccurred(.error)
                                        }
                                    } else {
                                        generator.impactOccurred(intensity: 0.7)
                                        withAnimation {
                                            justShowed = false
                                        }
                                    }
                                    
                                } label: {
                                    if showingDeleteFields {
                                        Text("Confirm Delete Account")
                                    } else {
                                        Text("Delete Account")
                                    }
                                }
                                .padding(12)
                                .foregroundColor(.white)
                                Spacer()
                            }
                            .background(.red)
                            .cornerRadius(10)
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    // MARK: - Prompt User to input Email and Password
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 30)
                        Text("To view your Account's information, please enter your Email and Password.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Section() {
                            TextField("Current Email", text: $finalEmail)
                                .padding(20)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .padding(.top, 37)
                                .padding(.bottom, 5)
                                .disabled(true)
                            ZStack(alignment: .trailing) {
                                Group {
                                    if isSecured2 {
                                        SecureField("Password", text: $getCurPW)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                    } else {
                                        TextField("Password", text: $getCurPW)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
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
                            .padding(.bottom, 10)
                            HStack {
                                Spacer()
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .opacity(0.8)
                                    .foregroundColor(Color.blue)
                                    .onTapGesture {
                                        isShowingForgotView = true
                                    }
                                    .sheet(isPresented: $isShowingForgotView) {
                                        forgotPasswordSwiftUI()
                                    }
                            }
                            HStack {
                                if faceIDaccount {
                                    if bioAvailable != "Biometrics Unavailable" || bioAvailable != "Unknown Biometrics Type" {
                                        Button(action: {
                                            if getCurPW != "" {
                                                let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: getCurPW)
                                                let user = Auth.auth().currentUser
                                                
                                                user?.reauthenticate(with: credential, completion: { (result, error) in
                                                    if let err = error {
                                                        print("error while trying to reauthenticate, error: \(err)")
                                                        self.cldntVerify.type = .Error
                                                        self.showBanner3 = true
                                                        generator2.notificationOccurred(.error)
                                                    } else {
                                                        print("successfully reauthenticated")
                                                        generator2.notificationOccurred(.success)
                                                        showingUserChoice = true
                                                        curShowUser = finalUsername
                                                    }
                                                })
                                            } else {
                                                self.fieldIsEmpty.type = .Error
                                                self.showBanner = true
                                                generator2.notificationOccurred(.error)
                                            }
                                        }) {
                                            Text("Authenticate")
                                                .bold()
                                                .frame(width: 320, height: 50)
                                                .background(.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .padding(.vertical, 15)
                                        }
                                    }
                                }
                                
                                if !faceIDaccount {
                                    Button(action: {
                                        if getCurPW != "" {
                                            let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: getCurPW)
                                            let user = Auth.auth().currentUser
                                            
                                            user?.reauthenticate(with: credential, completion: { (result, error) in
                                                if let err = error {
                                                    print("error while trying to reauthenticate, error: \(err)")
                                                    self.cldntVerify.type = .Error
                                                    self.showBanner3 = true
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    print("successfully reauthenticated")
                                                    generator2.notificationOccurred(.success)
                                                    showingUserChoice = true
                                                    curShowUser = finalUsername
                                                }
                                            })
                                        } else {
                                            self.fieldIsEmpty.type = .Error
                                            self.showBanner = true
                                            generator2.notificationOccurred(.error)
                                        }
                                    }) {
                                        Text("Authenticate")
                                            .bold()
                                            .frame(width: 360, height: 50)
                                            .background(.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .padding(.vertical, 15)
                                    }
                                }
                                if faceIDaccount {
                                    if bioAvailable != "Biometrics Unavailable" || bioAvailable != "Unknown Biometrics Type" {
                                        Button {
                                            authenticate()
                                        } label: {
                                            if bioAvailable == "FaceID" {
                                                HStack {
                                                    Image(systemName: "faceid")
                                                        .font(.title3)
                                                        .bold()
                                                        .frame(width: 50, height: 50)
                                                        .background(.blue)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(100)
                                                }
                                                .fontWeight(.bold)
                                            } else if bioAvailable == "TouchID" {
                                                HStack {
                                                    Image(systemName: "touchid")
                                                        .font(.title3)
                                                        .bold()
                                                        .frame(width: 50, height: 50)
                                                        .background(.blue)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(100)
                                                }
                                                .fontWeight(.bold)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                // MARK: - Image Picker
                /*
                HStack {
                    Image(uiImage: self.image)
                        .resizable()
                        .cornerRadius(50)
                        .padding(.all, 4)
                        .frame(width: 100, height: 100)
                        .background(Color.secondary.opacity(0.5))
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .padding(8)
                        .onChange(of: image, perform: { newImage in // <-- Here
                            UserDefaults.standard.setValue(newImage.pngData(), forKey: "image")
                        })
                    VStack {
                        Button {
                            showCameraPicker = true
                        } label: {
                            Text("Change photo")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(16)
                                .foregroundColor(.white)
                        }
                        .sheet(isPresented: $showCameraPicker) {
                            ImagePicker(sourceType: .camera, selectedImage: self.$image)
                        }
                        Button {
                            showImagePicker = true
                        } label: {
                            Text("Change photo")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(16)
                                .foregroundColor(.white)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                        }
                    }
                }
                */
            }
            .listRowBackground(Color("bgColorTab2")) 
            .background(Color("bgColorTab"))
            .navigationBarTitle(Text("\(finalUsername)"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        showingUserChoice = false
                        presentationMode.wrappedValue.dismiss()
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "xmark")
                    })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // .banner(data: $fieldIsEmpty, show: $showBanner)
        // .banner(data: $userOrPWIncorrect, show: $showBanner2)
        // .banner(data: $cldntVerify, show: $showBanner3)
        .onAppear {
            curShowUser = ""
            justShowed = true
            generator.impactOccurred(intensity: 0.7)
            tempDevMode = 0
            print("tempDevMode count: \(tempDevMode)")
        }
        .onDisappear {
            curShowUser = ""
            showingUserChoice = false
        }
    }
    
    func authenticate() {
        
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication is required to view Account Information") { success, authenticationError in
                
                if success {
                    let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: finalPassword)
                    let user = Auth.auth().currentUser
                    
                    user?.reauthenticate(with: credential, completion: { (result, error) in
                        if let err = error {
                            print("error while trying to reauthenticate, error: \(err)")
                            self.cldntVerify.type = .Error
                            self.showBanner3 = true
                            generator2.notificationOccurred(.error)
                        } else {
                            print("successfully reauthenticated")
                            generator2.notificationOccurred(.success)
                            showingUserChoice = true
                            curShowUser = finalUsername
                        }
                    })
                } else {

                }

            }
        } else {

        }
    }
}

struct accountInfoSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        accountInfoSwiftUI()
    }
}
