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

/*
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
*/

struct signInViewSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Lists of accounts registered
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    @State var currentPasswords = ""
    
    // MARK: - User Input
    @State var username = ""
    @State var password = ""
    
    // MARK: - Showing Alerts
    @State private var signUpAlert = false
    
    // MARK: - Showing Views
    @State private var isShowingsignInView: Bool = false
    @State private var isShowingForgotView: Bool = false
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    
    // MARK: - Temporary Developer Mode Reset
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0

    // MARK: - Segmented Control for View switching
    @AppStorage("signInUpSegment", store: .standard) private var signInUpSegment = 0
    
    // MARK: - List and Count of all registered Usernames
    @AppStorage("usernameCountInt", store: .standard) private var usernameCountInt = 0
    @AppStorage("usernameArray", store: .standard) private var usernameArray = ""
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - Banner Information
    @State var signUpWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements Not Fulfilled", detail: "Please ensure that you entered an Email and Password", type: .Error)
    @State var errorLoggingInWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Could Not Log In", detail: "This account does not exist, or you have entered the wrong Email and/or Password. Do note that Passwords are case sensitive.", type: .Error)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    // MARK: - Checking if just logged in with QR Code
    @AppStorage("justQRSignIn", store: .standard) var justQRSignIn = false
    
    @AppStorage("showQRLogIn", store: .standard) var showQRLogIn = false
    
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = false
    
    @AppStorage("companionmode", store: .standard) private var companionmode = false

    var body: some View {
        if companionmode {
            companionView()
        } else {
            if signInUpSegment == 1 {
                NavigationView {
                    VStack(spacing: 15) {
                        /*
                         Spacer()
                         Image(systemName: "person.crop.square.filled.and.at.rectangle")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 125, height: 125)
                         */
                        Spacer()
                        Spacer()
                        Spacer()
                        HStack {
                            Text("Welcome back to\nRecall!")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        Group {
                            /*
                             HStack {
                             Text("Email")
                             .fontWeight(.bold)
                             .font(.subheadline)
                             .padding(.top, 37)
                             Spacer()
                             }
                             */
                            TextField("Enter Email", text: $username)
                                .padding(20)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                            /*
                             Divider()
                             .padding(.vertical, 10)
                             */
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
                                        SecureField("Enter Password", text: $password)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                    } else {
                                        TextField("Enter Password", text: $password)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
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
                        }
                        
                        HStack {
                            Spacer()
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color.blue)
                                .opacity(0.8)
                                .onTapGesture {
                                    isShowingForgotView = true
                                }
                                .sheet(isPresented: $isShowingForgotView) {
                                    forgotPasswordSwiftUI()
                                }
                        }
                        
                        Spacer()
                        Button {
                            if username != "" && password != "" {
                                
                                print("button in")
                                
                                FirebaseAuth.Auth.auth().signIn(withEmail: username, password: password, completion: { result, error in
                                    guard error == nil else {
                                        print("could not find account")
                                        generator2.notificationOccurred(.error)
                                        self.errorLoggingInWarnbanner.type = .Error
                                        self.showBanner2 = true
                                        return
                                    }
                                    
                                    finalEmail = (Auth.auth().currentUser?.email!)!
                                    finalPassword = password
                                    isLoggedIn = true
                                    finalUID = Auth.auth().currentUser!.uid
                                    print("successfully signed in")
                                    
                                    if (Auth.auth().currentUser != nil) {
                                        let query = Firestore.firestore().collection("users").whereField("email", isEqualTo: finalEmail)
                                        query.getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    finalUsername = "\(document.get("username") ?? "UNKNOWNS")"
                                                    generator2.notificationOccurred(.success)
                                                    showingOnboarding = false
                                                    presentationMode.wrappedValue.dismiss()
                                                }
                                            }
                                        }
                                    }
                                    print("firebase cur auth: \(String(describing: FirebaseAuth.Auth.auth().currentUser))")
                                })
                            } else {
                                if isBannerOn {
                                    self.signUpWarnbanner.type = .Error
                                    self.showBanner = true
                                }
                                generator2.notificationOccurred(.error)
                            }
                        } label: {
                            HStack {
                                Text("Log In")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                                    .fontWeight(.bold)
                            }
                            .frame(width: 175, height: 60)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(150)
                        }
                        .disabled(username == "" || password == "")
                        Spacer()
                        Button {
                            signInUpSegment = 0
                        } label: {
                            HStack {
                                Text("New to Recall?")
                                    .foregroundColor(.primary)
                                Text("Sign Up!")
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
                            Text("Log In")
                                .fontWeight(.bold)
                        }
                    }
                    .background(NavigationConfigurator { nc in
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
                    //// .banner(data: $signUpWarnbanner, show: $showBanner)
                    //// .banner(data: $errorLoggingInWarnbanner, show: $showBanner2)
                    
                }
                .onAppear {
                    if isLoggedIn {
                        if justQRSignIn {
                            signInUpSegment = 2
                            justQRSignIn = false
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    generator.impactOccurred(intensity: 0.7)
                    tempDevMode = 0
                }
                // .banner(data: $signUpWarnbanner, show: $showBanner)
                // .banner(data: $errorLoggingInWarnbanner, show: $showBanner2)
                .navigationViewStyle(StackNavigationViewStyle())
                .padding(0)
            } else if signInUpSegment == 0 {
                signUpViewSwiftUI()
            } else if signInUpSegment == 2 {
                qrSignInViewSwiftUI()
            }
        }
    }
}

/*
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
*/

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        signInViewSwiftUI()
    }
}

/*
struct LogoView: View {
    var body: some View {
        Image("FFIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .padding(.bottom, 65)
            .padding(.top, 75)
    }
}

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}
*/

