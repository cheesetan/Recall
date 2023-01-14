//
//  MaininitSwiftUI.swift
//  Recall
//
//  Created by Tristan on 7/8/22.
//

import SwiftUI
import CodeScanner
import Firebase
import FirebaseAuth
import CorePermissionsSwiftUI
import PermissionsSwiftUIPhoto
import PermissionsSwiftUICamera
import PermissionsSwiftUINotification
import PermissionsSwiftUI

struct MaininitSwiftUI: View {
    
    @ObservedObject var viewModel = FoodsViewModel()
    
    let dateFormatter = DateFormatter()
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - User Input
    @State private var titleInput = ""
    @State private var expireInput = Date()
    @State private var expireInputConverted = ""
    @State private var placeholderInput = ""
    
    // MARK: - QR Code Generation
    @State private var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @State private var selectedView = 1
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @State private var foodTitleLabel = ""
    @State private var foodExpireLabel = ""
    
    @State private var isTorchOn = false
    
    @State private var showingAddToListView = false
    
    
    @State private var activeTabIndex = 0
    
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = true
    @AppStorage("expiredListCount", store: .standard) private var expiredListCount = 0
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("isDark", store: .standard) var isDark = false
    
    @AppStorage("hideCustomTabBar", store: .standard) var hideCustomTabBar = false
    
    @AppStorage("companionmode", store: .standard) var companionmode = false
    
    @AppStorage("premiumMode", store: .standard) private var premiumMode = false
    
    @AppStorage("autoDeleteRecalls", store: .standard) private var autoDeleteRecalls = true
    
    @State private var isDateTextFieldDisabled = true
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var selectedTab: Tab = .checklist
    
    
    /*
     init() {
     UITabBar.appearance().isHidden = true
     }
     */
    
    var body: some View {
        if !showingOnboarding {
            if isLoggedIn {
                ZStack {
                    KSMapView()
                    VStack {
                        TabView(selection: $selectedView) {
                            //if selectedTab.rawValue == "checklist" {
                            TableListViewSwiftUI(foods: Foods(description: "corn", title: "Corn", due: "duedate", dueTime: Date()))
                                .tabItem {
                                    Label("Recalls", systemImage: "list.bullet.clipboard.fill")
                                }
                                .tag(1)
//                            KSMapView()
//                                .tabItem {
//                                    Label("Locate", systemImage: "map.fill")
//                                }
//                                .tag(2)
                            //} else if selectedTab.rawValue == "person" {
                            if premiumMode {
                                commselectView()
                                    .tabItem {
                                        Label("Contact", systemImage: "person.2.wave.2.fill")
                                        
                                    }
                                    .tag(3)
                                
//                                purchaseView()
//                                    .tabItem {
//                                        Label("Medication", systemImage: "pills.fill")
//                                        
//                                    }
//                                    .tag(4)
                            }
                            //.badge(16)
                            //.badge(999999999999999999)
                            // } else if selectedTab.rawValue == "gearshape" {
                            SettingsSwiftUI()
                                .tabItem {
                                    Label("Settings", systemImage: "gearshape.fill")
                                    
                                }
                                .tag(5)
                            //}
                        }
                    }
                    .onAppear {
                        db.collection("users").document("\(finalUID)")
                            .addSnapshotListener { documentSnapshot, error in
                                guard let document = documentSnapshot else {
                                    print("Error fetching document: \(error!)")
                                    return
                                }
                                guard let data = document.data() else {
                                    print("Document data was empty.")
                                    return
                                }
                                if document.get("autodelete") as? String ?? "true" == "true" {
                                    autoDeleteRecalls = true
                                } else {
                                    autoDeleteRecalls = false
                                }
                            }
                    }
                    
                    VStack {
                        Spacer()
                        //CustomTabBar(selectedTab: $selectedTab)
                    }
                }
                .onAppear {
                    if isDark {
                        UITabBar.appearance().barTintColor = UIColor(Color("bgColorTab"))
                        SceneDelegate.shared?.window!.overrideUserInterfaceStyle = .dark
                    } else {
                        UITabBar.appearance().barTintColor = UIColor(Color("bgColorTab"))
                        SceneDelegate.shared?.window!.overrideUserInterfaceStyle = .light
                    }
                    
                    hideCustomTabBar = false
                    selectedView = 1
                    selectedTab = .checklist
                }
            } else {
                if !companionmode {
                    signInViewSwiftUI()
                } else {
                    companionView()
                }
            }
        } else {
            OnboardingView()
        }
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "foodFriendGenerated\(titleInput)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func handleScanResult(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let qrValue = result.string
            if qrValue.contains("foodFriendApproved") {
                let qrValueNew = qrValue.replacingOccurrences(of: "foodFriendApproved", with: "", options: NSString.CompareOptions.literal, range: nil)
                let details = qrValueNew.components(separatedBy: "\n")
                
                if details.count == 0 {
                    foodTitleLabel = "Unknown"
                    foodExpireLabel = "Unknown"
                } else if details.count == 1 {
                    foodTitleLabel = String("\(details[0])")
                    foodExpireLabel = "Unknown"
                } else {
                    foodTitleLabel = String("\(details[0])")
                    foodExpireLabel = String("\(details[1])")
                }
                
                if (user != nil) {
                    db.collection("users").document(finalUID).collection("foods").addDocument(data: [
                        "addedAt": Date(),
                        "title": foodTitleLabel,
                        "expire": foodExpireLabel,
                        "verified": "true"])
                }
                
                print(foodTitleLabel)
                print(foodExpireLabel)
                
                generator2.notificationOccurred(.success)
                
                selectedView = 1
            } else if qrValue.contains("foodFriendGenerated") {
                let qrValueNew = qrValue.replacingOccurrences(of: "foodFriendGenerated", with: "", options: NSString.CompareOptions.literal, range: nil)
                let details = qrValueNew.components(separatedBy: "\n")
                
                if details.count == 0 {
                    foodTitleLabel = "Unknown"
                    foodExpireLabel = "Unknown"
                } else {
                    foodTitleLabel = String("\(details[0])")
                    foodExpireLabel = "[Date not set]"
                }
                
                if (user != nil) {
                    db.collection("users").document(finalUID).collection("foods").addDocument(data: [
                        "addedAt": Date(),
                        "title": foodTitleLabel,
                        "expire": foodExpireLabel,
                        "verified": "false"])
                }
                
                print(foodTitleLabel)
                print(foodExpireLabel)
                
                generator2.notificationOccurred(.success)
                
                selectedView = 1
            } else {
                generator2.notificationOccurred(.error)
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct OnboardingView: View {
    
    @AppStorage("internalPermsChange", store: .standard) private var internalPermsChange = false
    
    @AppStorage("permsReviewed", store: .standard) private var permsReviewed = false
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = true
    
    @AppStorage("noViewAct", store: .standard) private var noViewAct = 0
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("companionmode", store: .standard) var companionmode = false
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var offset: CGFloat = 0
    @AppStorage("pageValue2", store: .standard) private var pageValue2 = 0
    
    var colors : [Color] = [.red, .blue, .pink, .indigo]
    
    var body: some View {
        if permsReviewed {
            if noViewAct == 0 {
                signUpViewSwiftUI()
            } else if noViewAct == 1 {
                PageView(title: "You're all set!", subtitle: "You have already logged in to Recall with the account username: \(finalUsername).\nWelcome back to Recall!", imageName: "checkmark.circle", showDismissButton: true, showPermButton: false, pageValue: 0)
            }
        } else {
            ScrollView(.init()) {
                ZStack {
                    TabView {
                        /*
                         ForEach(colors.indices, id: \.self) { index in
                         if index == 0 {
                         colors[index]
                         .overlay(
                         GeometryReader { proxy -> Color in
                         
                         let minX = proxy.frame(in: .global).minX
                         
                         print(-minX)
                         
                         DispatchQueue.main.async {
                         withAnimation(.default) {
                         self.offset = -minX
                         }
                         }
                         
                         return Color.clear
                         }
                         .frame(width: 0, height: 0)
                         
                         ,alignment: .leading
                         )
                         } else {
                         colors[index]
                         }
                         }
                         */
                        PageView(title: "List", subtitle: "Keep track of all your Recalls!", imageName: "list.bullet.clipboard.fill", showDismissButton: false, showPermButton: false, pageValue: 1)
                            .onAppear {
                                //pageValue2 = 1
                            }
                        PageView(title: "Syncing", subtitle: "Sync all your Recalls between all of your devices in real time with a single account!", imageName: "arrow.triangle.2.circlepath.circle", showDismissButton: false, showPermButton: false, pageValue: 3)
                            .onAppear {
                                //pageValue2 = 3
                            }
                        PageView(title: "In-app messaging", subtitle: "Message others using Recall's messaging functionality", imageName: "ellipsis.message", showDismissButton: false, showPermButton: false, pageValue: 5)
                            .onAppear {
                                //pageValue2 = 5
                            }
                        PageView(title: "App Permissions", subtitle: "Permissions are required for features in the app to work properly.", imageName: internalPermsChange ? "lock.open.iphone" : "lock.iphone", showDismissButton: false, showPermButton: true, pageValue: 7)
                            .onAppear {
                                //pageValue2 = 7
                            }
                    }
                    //.indexViewStyle(.page(backgroundDisplayMode: .always))
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .background(Color("bgColorTab"))
                    .tabViewStyle(PageTabViewStyle())
                    
                    /*
                     VStack {
                     Spacer()
                     Text("\(pageValue2)")
                     HStack(spacing: 12) {
                     ForEach((1...7), id: \.self) { index in
                     withAnimation(.default) {
                     Capsule()
                     .fill(Color.primary)
                     .frame(width: pageValue2 == index ? 20 : 7, height: 7)
                     }
                     }
                     }
                     .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                     }
                     */
                }
                /*
                 .overlay(
                 HStack(spacing: 15) {
                 ForEach(colors.indices, id: \.self) { index in
                 Capsule()
                 .fill(Color.primary)
                 .frame(width: getIndex() == index ? 20 : 7, height: 7)
                 }
                 }
                 .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                 ,alignment: .bottom
                 )
                 */
            }
            .ignoresSafeArea()
        }
    }
    
    func getIndex() -> Int {
        let index = Int(round(Double(offset / getWidth())))
        print(index)
        return index
    }
}

extension View {
    func getWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
}

struct PageView: View {
    
    let title: String
    let subtitle: String
    let imageName: String
    let showDismissButton: Bool
    let showPermButton: Bool
    let pageValue: Int
    
    @State private var showPermsModal = false
    
    @AppStorage("noViewAct", store: .standard) private var noViewAct = 0
    
    @AppStorage("internalPermsChange", store: .standard) private var internalPermsChange = false
    @AppStorage("permsReviewed", store: .standard) private var permsReviewed = false
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = true
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("companionmode", store: .standard) private var companionmode = false
    
    @AppStorage("pageValue2", store: .standard) private var pageValue2 = 0
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            Color("bgColorTab")
            VStack {
                if !showDismissButton && !showPermButton {
                    Spacer()
                }
                
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                
                Text(title)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                Text(subtitle)
                    .fontWeight(.medium)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.bottom)
                    .padding(.horizontal)
                
                
                if !showDismissButton && !showPermButton {
                    Spacer()
                    HStack {
                        Text("Swipe")
                        Image(systemName: "arrow.right")
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
                }
                
                
                if showDismissButton {
                    Button {
                        generator2.notificationOccurred(.success)
                        showingOnboarding = false
                    } label: {
                        Text("Continue to Recall")
                            .fontWeight(.bold)
                            .bold()
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                }
                
                if showPermButton {
                    if internalPermsChange {
                        Text("How are you using this app?")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            permsReviewed = true
                            showingOnboarding = false
                            companionmode = true
                        } label: {
                            Text("I'm reminding others! (Companion Mode)")
                                .fontWeight(.bold)
                                .bold()
                                .foregroundColor(Color.white)
                                .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                    }
                    Button {
                        if !internalPermsChange {
                            generator.impactOccurred(intensity: 0.7)
                            showPermsModal = true
                            //internalPermsChange = true
                        } else {
                            if !isLoggedIn {
                                generator.impactOccurred(intensity: 0.7)
                                permsReviewed = true
                                noViewAct = 0
                                companionmode = false
                            } else {
                                generator.impactOccurred(intensity: 0.7)
                                permsReviewed = true
                                noViewAct = 1
                                companionmode = false
                            }
                        }
                    } label: {
                        if !internalPermsChange {
                            VStack {
                                Text("Review App Permissions")
                                    .fontWeight(.bold)
                                    .bold()
                                    .foregroundColor(Color.white)
                                    .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                Text("App Permissions have NOT been reviewed yet.")
                                    .fontWeight(.bold)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        } else {
                            VStack {
                                if isLoggedIn {
                                    Text("Sign Up/Log In")
                                        .fontWeight(.bold)
                                        .bold()
                                        .foregroundColor(Color.white)
                                        .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                    Text("App Permissions have been reviewed.")
                                        .fontWeight(.bold)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("Others are reminding me! (User Mode)")
                                        .fontWeight(.bold)
                                        .bold()
                                        .foregroundColor(Color.white)
                                        .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                    Text("App Permissions have been reviewed.")
                                        .fontWeight(.bold)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .disabled(permsReviewed)
                    .JMModal(showModal: $showPermsModal,
                             for: [.camera, .location, .notification],
                             autoDismiss: true,
                             onDisappear: {internalPermsChange = true})
                    .setPermissionComponent(for: .camera,
                                            image: AnyView(Image(systemName: "camera.fill")),
                                            title: "Camera",
                                            description: "Recall needs to use the camera to scan Connect Codes.")
                    .setPermissionComponent(for: .location,
                                            image: AnyView(Image(systemName: "location.fill.viewfinder")),
                                            title: "Location Services",
                                            description: "Recall needs to use Location Services so companions can check your location.")
                    .setPermissionComponent(for: .notification,
                                            image: AnyView(Image(systemName: "bell.badge.fill")),
                                            title: "Notifications",
                                            description: "Allow Recall to send notifications when your Recalls are going to expire.")
                    .changeHeaderTo("Permissions Request")
                    .changeHeaderDescriptionTo("Recall needs certain permissions in order for all the features to work.")
                    .changeBottomDescriptionTo("If you deny these permissions, you can only enable them again in the Settings app.\n\nYou can dismiss this prompt once you have explicitly allowed or denied all of the permission requests.")
                    .setAccentColor(toPrimary: Color(.sRGB, red: 56/255, green: 173/255,
                                                     blue: 169/255, opacity: 1),
                                    toTertiary: Color(.systemPink))
                }
            }
            .background(Color("bgColorTab"))
        }
        .onAppear {
            pageValue2 = pageValue
        }
        .background(Color("bgColorTab"))
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct MaininitSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
