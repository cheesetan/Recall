//
//  SettingsSwiftUI.swift
//  Recall
//
//  Created by Tristan on 9/7/22.
//

import SwiftUI
import CoreData
import UIKit
import AVFoundation
import FirebaseAuth
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
import LocalAuthentication

struct SettingsSwiftUI: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
        
    @State private var showModal = false
    
    @State private var CurloadedImageURL = ""
    
    @State private var image = UIImage()
    @State private var showSheet = false
    @State private var showSheet2 = false
    @State private var showSheet3 = false
    @State private var showSheet4 = false
    
    @State private var actList = 0
    
    @State private var isShowingABP: Bool = false
    @State private var isShowingsignUpView: Bool = false
    @State private var isShowingAccountInfoView: Bool = false
    @State private var isShowingAccountQRView: Bool = false
    
    @State var SettingsloadedImageURL = ""
    @State var SettingsloadedSuccess = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingAlert = false
    @State private var showingDevAlert = false
    @State private var showingSignOutAlert = false
    @State private var showingRestoreAccAlert = false
    @State private var showingTableListView = false
    @State private var showingWatchConnectivity = false
    @State private var showingDBUpload = false
    
    @State var showBanner: Bool = false
    @State var showBanner2: Bool = false
    
    @State var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "Notification Title", detail: "Notification text for the action you were trying to perform.", type: .Warning)
    @State var successLoggingInbanner: BannerModifier.BannerData = BannerModifier.BannerData(title: "Success!", detail: "You have successfully logged your account!", type: .Success)
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    @AppStorage("appendToTop", store: .standard) var appendToTop = true
    @AppStorage("notificationsAllowed", store: .standard) var notificationsAllowed = false
    @AppStorage("cameraAllowed", store: .standard) var cameraAllowed = false
    @AppStorage("segmentToTop", store: .standard) var segmentToTop = 0
    @AppStorage("allowFFC", store: .standard) var allowFFC = false
    @AppStorage("allowAutoBackMIV", store: .standard) var allowAutoBackMIV = true
    @AppStorage("devMode", store: .standard) var devMode = false
    @AppStorage("isCamAllowed", store: .standard) var isCamAllowed = false
    @AppStorage("camPrompt", store: .standard) var camPrompt = false
    @AppStorage("notifPrompt", store: .standard) var notifPrompt = false
    @AppStorage("showSummonNotifs", store: .standard) var showSummonNotifs = false
    @AppStorage("allowNotifToggle", store: .standard) var allowNotifToggle = true
    @AppStorage("isBannerOn", store: .standard) var isBannerOn = true
    
    @AppStorage("isWebsiteAlert", store: .standard) var isWebsiteAlert = true
    @AppStorage("isWebsiteAllowed", store: .standard) var isWebsiteAllowed = true
    
    @AppStorage("showAccQR", store: .standard) var showAccQR = false
    @AppStorage("showQRLogIn", store: .standard) var showQRLogIn = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("internalPermsChange", store: .standard) private var internalPermsChange = false
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = true
    @AppStorage("permsReviewed", store: .standard) private var permsReviewed = false
    @AppStorage("noViewAct", store: .standard) private var noViewAct = 0
    
    @AppStorage("sendOneWeekExpireNotif", store: .standard) private var sendOneWeekExpireNotif = true
    @AppStorage("sendExpireNotif", store: .standard) private var sendExpireNotif = true
    
    @AppStorage("bioAvailable", store: .standard) private var bioAvailable = ""
    @AppStorage("faceIDaccount", store: .standard) private var faceIDaccount = false
    
    @AppStorage("searchPostExpire", store: .standard) private var searchPostExpire = false
    
    @AppStorage("premiumMode", store: .standard) private var premiumMode = false
    
    @AppStorage("locationTracking", store: .standard) private var locationTracking = false
    
    @AppStorage("isDark", store: .standard) var isDark: Bool = false
        
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Login View
                Form {
                    Section(header: HStack {
                        Image(systemName: "person")
                        Text("Account")
                    }) {
                        if isLoggedIn == false {
                            Button {
                                isShowingsignUpView = true
                            } label: {
                                accountLogIn()
                            }
                            .fullScreenCover(isPresented: $isShowingsignUpView) {
                                signUpViewSwiftUI()
                            }
                        } else {
                            Button {
                                //isShowingAccountInfoView = true
                            } label: {
                                VStack {
                                    if actList == 0 {
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
                                                        .background(.secondary)
                                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                                }
                                            }
                                            .padding(.trailing, 8)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(finalEmail)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.primary)
                                            }
                                            Spacer()
                                        }
                                    } else if actList == 1 {
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
                                                        .background(.secondary)
                                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                                }
                                            }
                                            .padding(.trailing, 8)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(finalEmail)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.primary)
                                            }
                                            Spacer()
                                        }
                                    } else {
                                        HStack {
                                            VStack {
                                                ZStack {
                                                    WebImage(url: URL(string: CurloadedImageURL))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 70, height: 70, alignment: .center)
                                                        .foregroundColor(Color.white)
                                                        .background(.clear)
                                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 17, height: 17)))
                                                }
                                            }
                                            .padding(.trailing, 8)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(finalEmail)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.primary)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .fullScreenCover(isPresented: $isShowingAccountInfoView) {
                                accountInfoSwiftUI()
                            }
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                    
                    // MARK: - App Appearance
                    Section(header: HStack {
                        if isDark {
                            Image(systemName: "light.beacon.min")
                            Text("App Appearance")
                        } else {
                            Image(systemName: "light.beacon.max.fill")
                            Text("App Appearance")
                        }
                    }) {
                        Picker("Change App Appearance", selection: $isDark, content: {
                            Text("Light Mode").tag(false)
                            Text("Dark Mode").tag(true)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        
                        /*
                        Toggle(isOn: $isDark) {
                            Text("Enable Dark Mode")
                        }
                         */
                        .onChange(of: isDark) { newValue in
                            generator.impactOccurred(intensity: 0.7)
                            if isDark {
                                UITabBar.appearance().barTintColor = UIColor(Color("bgColorTab"))
                                SceneDelegate.shared?.window!.overrideUserInterfaceStyle = .dark
                            } else {
                                UITabBar.appearance().barTintColor = UIColor(Color("bgColorTab"))
                                SceneDelegate.shared?.window!.overrideUserInterfaceStyle = .light
                            }
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                    
                    /*
                    // MARK: - Biometrics Settings
                    if bioAvailable != "Biometrics Unavailable" || bioAvailable != "Unknown Biometrics Type" {
                        if bioAvailable == "FaceID" {
                            Section(header: HStack {
                                Image(systemName: "faceid")
                                Text("Face ID Lock")
                            }) {
                                Toggle(isOn: $faceIDaccount, label: {
                                    Text("Use Face ID to access Account Information")
                                })
                                .onChange(of: faceIDaccount) { newValue in
                                    if faceIDaccount == true {
                                        let context = LAContext()
                                        var error: NSError?
                                        
                                        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                                            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authentication is required to enabled the use of Face ID") { success, authenticationError in
                                                if success {
                                                    faceIDaccount = true
                                                } else {
                                                    faceIDaccount = false
                                                }
                                            }
                                        } else {
                                            faceIDaccount = false
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color("bgColorTab2"))
                        }
                        
                        if bioAvailable == "TouchID" {
                            Section(header: HStack {
                                Image(systemName: "touchid")
                                Text("Touch ID Lock")
                            }) {
                                Toggle(isOn: $faceIDaccount, label: {
                                    Text("Use Touch ID to access Account Information")
                                })
                                .onChange(of: faceIDaccount) { newValue in
                                    if faceIDaccount == true {
                                        let context = LAContext()
                                        var error: NSError?
                                        
                                        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                                            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authentication is required to enabled the use of Touch ID") { success, authenticationError in
                                                if success {
                                                    faceIDaccount = true
                                                } else {
                                                    faceIDaccount = false
                                                }
                                            }
                                        } else {
                                            faceIDaccount = false
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color("bgColorTab2"))
                        }
                    }
                    */
                     
                    /*
                    // MARK: - Search Settings
                    Section(header: HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search Posts")
                    }) {
                        Toggle(isOn: $searchPostExpire, label: {
                            Text("Show Expired Posts")
                        })
                    }
                    .listRowBackground(Color("bgColorTab2"))
                     */
                    /*
                    // MARK: - List Settings
                    Section(header: Text("List"),
                            footer: Text("New items will be appended to the \((segmentToTop == 0) ? "top" : "bottom").")
                        .frame(maxWidth: .infinity, alignment: .center)
                    ) {
                        /*
                         Toggle(isOn: $appendToTop, label: {
                         Text(appendToTop ? "Append To Top" : "Append To Bottom")
                         })
                         */
                        Picker("Add", selection: $segmentToTop, content: {
                            Text("Append To Top").tag(0)
                            Text("Append To Bottom").tag(1)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(3)
                    }
                     */
                    // rmb to work on this (FIXED: now sorts by expires first)
                    /*
                    // MARK: - Product Info View
                    Section(header: Text("Product Info View"), footer: Text("When enabled \"Product Info View\" will automatically go back to \"Your Foods\" if you go to another tab and come back.")) {
                        Toggle(isOn: $allowAutoBackMIV, label: {
                            Text("Automatically go back to \"Your Foods\"")
                        })
                    }
                     */
                    /*
                    // MARK: - QR Settings
                    Section(header: Text("QR Scanner"), footer: Text("This option must be enabled for Mac's built-in camera to work.")) {
                        Toggle(isOn: $allowFFC, label: {
                            Text("Allow Front Facing Camera")
                        })
                        .disabled(isCamAllowed == false)
                    }
                     */
                    /*
                    // MARK: - App Notifications
                    Section(header: HStack {
                        Image(systemName: "app.badge")
                        Text("Notifications")
                    }) {
                        Toggle(isOn: $sendOneWeekExpireNotif, label: {
                            Text("Notify when Recall is almost due")
                        })
                        Toggle(isOn: $sendExpireNotif, label: {
                            Text("Notify when Recall is due")
                        })
                    }
                    .listRowBackground(Color("bgColorTab2"))
                     */
                    /*
                    // MARK: - Visiting Websites
                    Section(header: HStack {
                        Image(systemName: "globe")
                        Text("Websites")
                    }, footer: Text("Confirms with the user every time they want to go to a website via a hyperlink in Recall.")) {
                        Toggle(isOn: $isWebsiteAllowed, label: {
                            Text("Allow Website Hyperlinks")
                        })
                        Toggle(isOn: $isWebsiteAlert, label: {
                            Text("Show Confirmation Alert")
                        })
                    }
                    .listRowBackground(Color("bgColorTab2"))
                     */
                    /*
                     // MARK: - Privacy Settings
                    Section(header: Text("Privacy"), footer: Text("The prompts may not be available if they had been requested before. In the case that you did not allow \"Recall\" to access these permissions, please go to Settings > \"Recall \", or click the button above to enable them.")) {
                        Button("\"Allow Camera\" Prompt") {
                            generator.impactOccurred(intensity: 0.7)
                            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                                isCamAllowed = true
                            } else {
                                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                                    if granted {
                                        camPrompt = true
                                        isCamAllowed = true
                                    } else {
                                        if let url = URL(string:UIApplication.openSettingsURLString) {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                        camPrompt = true
                                    }
                                })
                            }
                        }
                        .disabled(cameraAllowed || camPrompt)
                        Button("\"Allow Notifications\" Prompt") {
                            generator.impactOccurred(intensity: 0.7)
                            let center = UNUserNotificationCenter.current()
                            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                                
                                if let error = error {
                                    print(error)
                                }
                                
                                // Enable or disable features based on the authorization.
                            }
                            notifPrompt = true
                            allowNotifToggle = true
                        }
                        .disabled(notifPrompt)
                        
                        Button("Go to Settings > \"Recall\"") {
                            generator.impactOccurred(intensity: 0.7)
                            if let url = URL(string:UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    }
                     */
                    // MARK: - Restore To Defaults
                    Section(header: HStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Reset")
                    }) {
                        Button("Restore To Defaults") {
                            generator.impactOccurred(intensity: 0.7)
                            //tempDevMode += 1
                            print(tempDevMode)
                            if tempDevMode % 5 == 0 {
                                tempDevMode = 0
                                if devMode == false {
                                    showingDevAlert = true
                                    generator2.notificationOccurred(.success)
                                }
                            }
                            showingAlert = true
                        }
                        .foregroundColor(Color.red)
                        .alert("Warning", isPresented: $showingAlert, actions: {
                            Button("Cancel", role: .cancel, action: {
                            })
                            Button("Restore", role: .destructive, action: {
                                appendToTop = true
                                segmentToTop = 0
                                allowFFC = false
                                allowNotifToggle = true
                                isBannerOn = true
                                allowAutoBackMIV = true
                                isWebsiteAlert = true
                                sendOneWeekExpireNotif = true
                                sendExpireNotif = true
                                searchPostExpire = false
                                faceIDaccount = false
                            })
                        }, message: {
                            Text("Would you like to restore everything to its default settings? This action cannot be undone.")
                            
                        })
                        .alert("Developer Mode", isPresented: $showingDevAlert, actions: {
                            Button("OK", role: .cancel, action: {
                                devMode = true
                                generator.impactOccurred(intensity: 0.7)
                            })
                        }, message: {
                            Text("Developer Mode has been enabled!")
                        })
                    }
                    .listRowBackground(Color("bgColorTab2"))

                    // MARK: - Developer Mode
                    if finalEmail == "tristanchay123@gmail.com" {
                        Section(header: HStack {
                            Image(systemName: "hammer")
                            Text("Developer")
                        }) {
                            Toggle(isOn: $premiumMode, label: {
                                Text("Simulate Premium Mode")
                            })
                            Toggle(isOn: $locationTracking, label: {
                                Text("Location Tracking")
                            })
                            Button {
                                let content = UNMutableNotificationContent()
                                content.title = "Recall Due"
                                content.body = "item has reached its deadline."
                                content.sound = UNNotificationSound.default
                                content.interruptionLevel = .critical
                                                                                
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                                let request = UNNotificationRequest(identifier: "notif-simulate", content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().add(request)
                            } label: {
                                Text("Send notif (5 secs)")
                            }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    // MARK: - Remaining Code
                }
                .background(Color("bgColorTab"))
                .scrollContentBackground(.hidden)
                .formStyle(GroupedFormStyle())
            }
            .onChange(of: premiumMode) { newValue in
                if premiumMode == true {
                    Firestore.firestore().collection("users").document(finalUID).updateData([
                        "premium": "true",
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    Firestore.firestore().collection("users").document(finalUID).updateData([
                        "premium": "false",
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
            // .banner(data: $bannerData, show: $showBanner)
            // .banner(data: $successLoggingInbanner, show: $showBanner2)
            .background(Color("bgColorTab"))
            .navigationBarTitle("Settings", displayMode: .large)
            .navigationBarItems(
                trailing:
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                        generator.impactOccurred(intensity: 0.7)
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                            .foregroundColor(.red)
                    }
                    .alert("Sign Out", isPresented: $showingSignOutAlert, actions: {
                        Button("No", role: .cancel, action: {
                            
                        })
                        Button(role: .destructive) {
                            do {
                                try FirebaseAuth.Auth.auth().signOut()
                                isLoggedIn = false
                                finalUsername = ""
                                finalPassword = ""
                                finalEmail = ""
                                //finalUID = ""
                                //print("firebase cur auth: \(String(describing: FirebaseAuth.Auth.auth().currentUser))")
                                //UIView.setAnimationsEnabled(false)
                                showingTableListView = true
                            } catch {
                                print("An error has occurred while trying to sign out.")
                            }
                        } label: {
                            Text("Yes")
                        }
                    }, message: {
                        Text("Would you like to sign out of your account?")
                        
                    })
                    .disabled(isLoggedIn == false)
                    .fullScreenCover(isPresented: $showingTableListView) {
                        signInViewSwiftUI()
                            .onAppear {
                                UIView.setAnimationsEnabled(true)
                            }
                    }
            )
            .navigationBarItems(
                leading:
                    Button {
                        isShowingAccountQRView = true
                        generator.impactOccurred(intensity: 0.7)
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    .sheet(isPresented: $isShowingAccountQRView) {
                        connectView()
                    }
            )
            /*
             .navigationBarItems(
             trailing:
             Button(action: {
             presentationMode.wrappedValue.dismiss()
             generator.impactOccurred(intensity: 0.7)
             }) {
             Image(systemName: "xmark")
             })
             */
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(0)
        .onAppear {
            
            reloadPFP()
            tempDevMode = 0
            
            bioAvailable = getBiometricsName()
            
        }
        // .banner(data: $bannerData, show: $showBanner)
    }
    
    func reloadPFP() {
        actList = 0
        
        FirebaseStorageManager().loadUserPFP(userUID: finalUID) { (isSuccess, url) in
            print("loadImageFromFirebase: \(isSuccess), \(url)")
            if isSuccess {
                print("success getting pfp url")
                actList = 2
                CurloadedImageURL = "\(url!)"
            } else {
                actList = 1
                CurloadedImageURL = ""
            }
        }
    }
    
    func getBiometricsType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
        
    func getBiometricsName() -> String {
        switch getBiometricsType() {
        case .faceID:
            return "FaceID"
        case .touchID:
            return "TouchID"
        case .none:
            return "Biometrics Unavailable"
        @unknown default:
            return "Unknown Biometrics Type"
        }
    }
}

struct SettingsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUI()
    }
}
