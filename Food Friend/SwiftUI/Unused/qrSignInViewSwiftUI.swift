//
//  loginViewSwiftUI.swift
//  Recall
//
//  Created by Tristan on 13/7/22.
//

import SwiftUI
import CoreData
import UIKit
import CodeScanner

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

struct qrSignInViewSwiftUI: View {
    
    init() {
        UINavigationBar.changeAppearance()
    }
    
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
    
    // MARK: - Showing Alerts
    @State private var signUpAlert = false
    
    // MARK: - Showing Views
    @State private var isShowingsignInView: Bool = false
    @State private var isShowingScanner = false
    
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
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    // MARK: - User Information
    @AppStorage("saveUserQR", store: .standard) private var saveUserQR = ""
    @AppStorage("savePassQR", store: .standard) private var savePassQR = ""
    
    // MARK: - Banner Information
    @State var signUpWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Code Not Valid", detail: "That code is not a valid Recall Log In QR Code.", type: .Error)
    @State var errorLoggingInWarnbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Could Not Log In", detail: "This account does not exist, or the Username and/or Password is wrong.", type: .Error)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    
    // MARK: - Checking if banners are allowed
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    // MARK: - Checking if just logged in with QR Code
    @AppStorage("justQRSignIn", store: .standard) var justQRSignIn = false

    var body: some View {
        if signInUpSegment == 2 {
            NavigationView {
                VStack(spacing: 15) {
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 65)
                        .padding(.top, 75)
                    
                    Spacer()
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        isShowingScanner = true
                    }) {
                        Text("Scan QR to Log In")
                            .bold()
                            .frame(width: 360, height: 50)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    }
                    .sheet(isPresented: $isShowingScanner) {
                        NavigationView {
                            CodeScannerView(codeTypes: [.qr], simulatedData: "fFASignIncheesetan_\nPassword123", shouldVibrateOnSuccess: false, completion: handleScan)
                        }
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    .disabled(isLoggedIn)

                    HStack {
                        Picker("Change View", selection: $signInUpSegment, content: {
                            Text("Sign Up").tag(0)
                            Text("Log In").tag(1)
                            Text("QR Log In").tag(2)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 25)
                        
                        /*
                         Text("Already have an account?")
                         Button {
                         isShowingsignInView = true
                         } label: {
                         Text("Log In!")
                         }
                         .fullScreenCover(isPresented: $isShowingsignInView) {
                         signInViewSwiftUI()
                         }
                         */
                    }
                }
                .padding()
                .background(Color("bgColorTab"))
                .navigationBarTitle(Text("QR Log In"), displayMode: .inline)
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
                //// .banner(data: $errorLoggingInWarnbanner, show: $showBanner2)

            }
            .onLoad {
                print("just loaded")
                if isLoggedIn {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onAppear {
                generator.impactOccurred(intensity: 0.7)
                tempDevMode = 0
                print("just appeared")
            }
            // .banner(data: $signUpWarnbanner, show: $showBanner)
            // .banner(data: $errorLoggingInWarnbanner, show: $showBanner2)
            .navigationViewStyle(StackNavigationViewStyle())
            .padding(0)
            
        } else if signInUpSegment == 0 {
            signUpViewSwiftUI()
        } else if signInUpSegment == 1 {
            signInViewSwiftUI()
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let qrValue = result.string
            if qrValue.contains("fFASignIn") {
                let qrValueNew = qrValue.replacingOccurrences(of: "fFASignIn", with: "", options: NSString.CompareOptions.literal, range: nil)
                let details = qrValueNew.components(separatedBy: "\n")
                guard details.count == 2 else { return }
                
                saveUserQR = details[0]
                savePassQR = details[1]
                
                print(saveUserQR)
                print(savePassQR)
                
                /*
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
                
                do {
                    print("starting to fetch")
                    let results = try context.fetch(request)
                    for results in results {
                        let accounts = results as! Accounts
                        
                        if accounts.username != nil || accounts.password != nil {
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
                        }
                        print("fetching")
                    }
                    
                    currentUsernames = currentUsernames.replacingOccurrences(of: ",,", with: ",")
                    currentPasswords = currentPasswords.replacingOccurrences(of: ",,", with: ",")
                    
                    currentUsernames = currentUsernames.replacingOccurrences(of: "Optional(\"", with: "")
                    currentPasswords = currentPasswords.replacingOccurrences(of: "Optional(\"", with: "")
                    
                    currentUsernames = currentUsernames.replacingOccurrences(of: "nil", with: "")
                    currentPasswords = currentPasswords.replacingOccurrences(of: "nil", with: "")
                    
                    /*
                    currentUsernames = currentUsernames.replacingOccurrences(of: ",,", with: ",")
                    currentPasswords = currentPasswords.replacingOccurrences(of: ",,", with: ",")
                    */
                    
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
                    
                    print("got arr of user")
                    
                    var arrayOfPasswords = currentPasswords.components(separatedBy: "\")")
                    print(arrayOfPasswords)
                    
                    print("got arr of pw")
                    
                    let indexOfUser = arrayOfUsernames.firstIndex{$0 == saveUserQR}
                    if indexOfUser == nil {
                        if isBannerOn {
                            self.errorLoggingInWarnbanner.type = .Error
                            self.showBanner2 = true
                        }
                        generator2.notificationOccurred(.error)
                    } else {
                        print(indexOfUser!)
                        
                        let userLoggingInPW = arrayOfPasswords[indexOfUser!]
                        print(userLoggingInPW)
                        
                        if savePassQR == userLoggingInPW {
                            isLoggedIn = true
                            finalUsername = saveUserQR
                            finalPassword = savePassQR
                            generator2.notificationOccurred(.success)
                            isShowingScanner = false
                            justQRSignIn = true
                            signInUpSegment = 1
                        } else {
                            isShowingScanner = false
                            justQRSignIn = true
                            signInUpSegment = 1
                            if isBannerOn {
                                self.errorLoggingInWarnbanner.type = .Error
                                self.showBanner2 = true
                            }
                            generator2.notificationOccurred(.error)
                        }
                        
                    }
                    
                    currentPasswords = ""
                    currentUsernames = ""
                    arrayOfUsernames = []
                    arrayOfPasswords = []
                    noOfAccounts = 0
                } catch {
                    print("Fetch failed")
                }
                */
            } else {
                isShowingScanner = false
                justQRSignIn = true
                signInUpSegment = 1
                if isBannerOn {
                    self.signUpWarnbanner.type = .Error
                    self.showBanner = true
                }
                generator2.notificationOccurred(.error)
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
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

struct qrSignInViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        qrSignInViewSwiftUI()
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

