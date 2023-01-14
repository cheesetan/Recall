//
//  loginViewSwiftUI.swift
//  Recall
//
//  Created by Tristan on 13/7/22.
//

import SwiftUI
import CoreData
import UIKit
import Firebase
import FirebaseAuth
import Introspect
import SDWebImageSwiftUI

struct ViewDidLoadModifier: ViewModifier {
    
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

struct signUpViewSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Lists of accounts registered
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    
    // MARK: - User Input
    @State var realUsername = ""
    @State var username = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    // MARK: - Showing Alerts
    @State private var signUpAlert = false
    
    // MARK: - Showing Views
    @State private var isShowingsignInView: Bool = false
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    @State private var isSecured2 = true
    
    // MARK: - Temporary Developer Mode Reset
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    
    // MARK: - Segmented Control for View switching
    @AppStorage("signInUpSegment", store: .standard) private var signInUpSegment = 0
    
    // MARK: - List and Count of all registered Usernames
    @AppStorage("usernameCountInt", store: .standard) private var usernameCountInt = 0
    @AppStorage("usernameArray", store: .standard) private var usernameArray = ""
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("companionmode", store: .standard) private var companionmode = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - Banner Information
    @State var signUpWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements not fulfilled", detail: "Please ensure that you entered an Email and Password, and that the two Passwords match.", type: .Error)
    @State var buttonWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Account Creation Failed", detail: "Please ensure that you have entered a valid Email Address that has not been used and that your Password is at least 6 characters long.", type: .Error)
    @State var usertakenwarn: BannerModifier.BannerData = BannerModifier.BannerData(title: "Account Creation Failed", detail: "This Username has already been taken, please choose another one", type: .Error)
    @State var successDoneBanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Success!", detail: "Your account has been successfully registered! Please log in to your account in the \"Sign In\" page.", type: .Success)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    @State var showBanner3: Bool = false
    @State var showBanner4: Bool = false
        
    @State private var usernameCheck = false
    @State private var showNext = false
    @State private var showNext2 = true
    
    @State private var accFailed = false
    
    @State private var usernameIsFocused = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    @AppStorage("showQRLogIn", store: .standard) var showQRLogIn = false
    
    @AppStorage("currUsernames", store: .standard) var currUsernames = ""
    
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = false
    
    @State private var actList = 0
    
    @State private var CurloadedImageURL = "https://firebasestorage.googleapis.com/v0/b/food-friend-sst.appspot.com/o/139369246-vector-empty-transparent-background-vector-transparency-grid-seamless-pattern-.jpg?alt=media&token=86a053bf-3b4b-4c8a-ae06-835a553363b0"
    
    @State private var CurloadedSuccess = false
    
    @State private var showSheet = false
    @State private var showSheet4 = false
    
    var body: some View {
        if companionmode {
            companionView()
        } else {
            if signInUpSegment == 0 {
                NavigationView {
                    VStack(spacing: 15) {
                        /*
                         Spacer()
                         Image(systemName: "person.crop.circle.badge.plus")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 125, height: 125)
                         */
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        HStack {
                            Text("Welcome to Recall!")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        
                        Group {
                            /*
                             HStack {
                             Text("Username")
                             .fontWeight(.bold)
                             .font(.subheadline)
                             Spacer()
                             }
                             */
                            
                            /*
                             HStack {
                             Text("Email")
                             .fontWeight(.bold)
                             .font(.subheadline)
                             Spacer()
                             }
                             */
                            
                            TextField("Enter an Email", text: $username)
                                .padding(20)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                            
                            /*
                             HStack {
                             Text("Password")
                             .fontWeight(.bold)
                             .font(.subheadline)
                             Spacer()
                             }
                             */
                            
                            ZStack(alignment: .trailing) {
                                Group {
                                    if isSecured {
                                        SecureField("Enter a Password", text: $password)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: password.count < 6 && password.count > 0 ? 2 : 0).foregroundColor(.red))
                                    } else {
                                        TextField("Enter a Password", text: $password)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: password.count < 6 && password.count > 0 ? 2 : 0).foregroundColor(.red))
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
                            
                            if password != "" {
                                if password.count < 6 {
                                    Text("Passwords have to contain at least 6 characters")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundColor(Color.red)
                                }
                            }
                            /*
                             Divider()
                             .padding(.vertical, 10)
                             */
                            
                            /*
                             HStack {
                             Text("Confirm Password")
                             .fontWeight(.bold)
                             .font(.subheadline)
                             Spacer()
                             }
                             */
                            
                            ZStack(alignment: .trailing) {
                                Group {
                                    if isSecured2 {
                                        SecureField("Confirm your Password", text: $passwordConfirmation)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: passwordConfirmation != password ? 2 : 0).foregroundColor(.red))
                                    } else {
                                        TextField("Confirm your Password", text: $passwordConfirmation)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: passwordConfirmation != password ? 2 : 0).foregroundColor(.red))
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
                            if passwordConfirmation != password {
                                Text("The two passwords dont match.")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        Spacer()
                        Button {
                            FirebaseAuth.Auth.auth().createUser(withEmail: username, password: password, completion: { result, error in
                                guard error == nil else {
                                    accFailed = true
                                    print("account creation failed")
                                    generator2.notificationOccurred(.error)
                                    self.buttonWarnbanner.type = .Error
                                    self.showBanner2 = true
                                    return
                                }
                                print("sign up successful")
                                generator2.notificationOccurred(.success)
                                
                                finalEmail = (Auth.auth().currentUser?.email!)!
                                finalPassword = password
                                finalUID = Auth.auth().currentUser!.uid
                                isLoggedIn = true
                                
                                MessagesViewModel().setNewAccount(username: realUsername, password: password, docId: finalUID, UID: finalUID)
                                
                                showingOnboarding = false
                                presentationMode.wrappedValue.dismiss()
                                //showNext2 = false
                            })
                        } label: {
                            HStack {
                                Text("Create Account")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                                    .fontWeight(.bold)
                            }
                            .frame(width: 200, height: 60)
                            .background(.thinMaterial)
                            .cornerRadius(150)
                        }
                        .disabled(username == "" || username == " " || password == "" || password == " " || passwordConfirmation != password || password.count < 6)
                        
                        Spacer()
                        Button {
                            signInUpSegment = 1
                        } label: {
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.primary)
                                Text("Log In!")
                                    .foregroundColor(.blue)
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        
                        /*
                         HStack {
                         Picker("Change View", selection: $signInUpSegment, content: {
                         Text("Sign Up").tag(0)
                         Text("Log In").tag(1)
                         if showQRLogIn {
                         Text("QR Log In").tag(2)
                         }
                         })
                         .pickerStyle(SegmentedPickerStyle())
                         .padding(.horizontal, 25)
                         }
                         */
                    }
                    .padding()
                    .background(Color("bgColorTab"))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                        }
                    }                .background(NavigationConfigurator { nc in
                        nc.navigationBar.barTintColor = .systemBackground
                        nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.label]
                    })
                    .navigationBarItems(
                        trailing:
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                companionmode.toggle()
                            } label: {
                                Text("Switch to Companion Mode")
                            }
                    )
                    // .banner(data: $signUpWarnbanner, show: $showBanner)
                    // .banner(data: $buttonWarnbanner, show: $showBanner2)
                    // .banner(data: $buttonWarnbanner, show: $showBanner3)
                    
                }
                // .banner(data: $signUpWarnbanner, show: $showBanner)
                // .banner(data: $buttonWarnbanner, show: $showBanner2)
                // .banner(data: $successDoneBanner, show: $showBanner3)
                // .banner(data: $usertakenwarn, show: $showBanner4)
                .navigationViewStyle(StackNavigationViewStyle())
                .onLoad {
                    if isLoggedIn {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    generator.impactOccurred(intensity: 0.7)
                    
                    tempDevMode = 0
                    
                    /*
                     let appDelegate = UIApplication.shared.delegate as! AppDelegate
                     let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                     let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
                     
                     do {
                     let results = try context.fetch(request)
                     for results in results {
                     let accounts = results as! Accounts
                     noOfAccounts += 1
                     if currentUsernames == "" || currentUsernames == " " {
                     currentUsernames = "\(accounts.username)"
                     } else {
                     currentUsernames = "\(currentUsernames)\(accounts.username)"
                     }
                     }
                     
                     currentUsernames = currentUsernames.replacingOccurrences(of: ",,", with: ",")
                     
                     currentUsernames = currentUsernames.replacingOccurrences(of: "Optional(\"", with: "")
                     
                     currentUsernames = currentUsernames.replacingOccurrences(of: "nil", with: "")
                     
                     if currentUsernames != "" {
                     let rs = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count - 1)
                     let re = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count)
                     currentUsernames.replaceSubrange(rs..<re, with: "")
                     
                     let ra = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count - 1)
                     let rb = currentUsernames.index(currentUsernames.startIndex, offsetBy: currentUsernames.count)
                     currentUsernames.replaceSubrange(ra..<rb, with: "")
                     }
                     usernameCountInt = noOfAccounts
                     print(noOfAccounts)
                     usernameArray = currentUsernames
                     print(currentUsernames)
                     
                     let arrayOfUsernames = currentUsernames.components(separatedBy: "\")")
                     print(arrayOfUsernames)
                     
                     currentUsernames = ""
                     noOfAccounts = 0
                     } catch {
                     print("Fetch failed")
                     }
                     */
                }
                .onAppear {
                    currUsernames = ""
                }
            } else if signInUpSegment == 1 {
                signInViewSwiftUI()
            } else if signInUpSegment == 2 {
                qrSignInViewSwiftUI()
            }
        }
    }
}

extension UINavigationBar {
    static func changeAppearance() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
    
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        signUpViewSwiftUI()
    }
}

struct LogoView: View {
    var body: some View {
        Image("FFIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 175, height: 175)
            .padding(.bottom, 65)
            .padding(.top, 75)
    }
}

extension View {
    
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
}


