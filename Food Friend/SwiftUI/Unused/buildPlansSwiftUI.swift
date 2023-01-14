//
//  buildPlansSwiftUi.swift
//  Recall
//
//  Created by Tristan on 12/7/22.
//

import SwiftUI

struct buildPlansSwiftUI: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationView() {
            VStack() {
                Form {
                    // MARK: - Current Features
                    Section(header: Text("Features")) {
                        Text("Current Features:")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)

                        Text("- QR Code Scanner\n- Ability to use front facing camera for QR Scan\n- Added a Toggle() for enabling front facing camera\n- Disabling of Toggle() for enabling front facing camera when permission is not given to use camera\n- Table View\n- Add products to Table View via QR Scanner\n- Made personalised QR Scanner catchphrase to be approve valid QRs\n- Edit and delete Table View\n- Move positions of contents on Table View\n- Settings to add new QR Scans to either top or bottom\n- Settings Page with Camera and Notification (currently useless) prompts\n- Settings Page with restore to defaults button\n- Optimised for iOS Dark and Light Modes\n- More info section for each Table View Cell (currently useless)\n- Added Haptic Feedback to improve User Experience\n- Added hidden Developer Mode and Toggle() to turn off Developer Mode\n- Disabling of Button(){} for enabling notification and camera prompt when already requested in the past\n- Added a Button(){} that brings you to Settings > \"Recall\"\n- Optimised for iPadOS and macOS\n- Added a new Sign Up and Sign in screen\n- Added accounts (no use for it at the moment)\n- Added banner notifications\n- Added ability to change account Username\n- Added ability to change account Password\n- Added ability to delete account\n- Added ability to delete everything from TableView() at once\n- Added custom QR Code for each account to Sign In with\n- Added ability to Sign In with QR Code\n- Added ability to manually add product information\n- Added ability to save QR Codes in Manual Adding and Account QR\n- Connected App Log In and Sign Up to Google Firebase and FirebaseAuth\n- Email is now used instead of Username\n- Authentication is now required to change Email and Password\n- Sign In has been changed to Log In\n- QR Log In has been disabled because we switched from CoreData Log In to Firebase Log In")
                            .padding(.vertical, 8)
                    }
                    // MARK: - Proposed Features
                    Section() {
                        Text("Proposed Features:")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("- More Settings for user's control (if necessary)\n- Tap anywhere to Scan QR when list is empty\n- Start work on the \"Socials\" tab (Last thing to do as it is the hardest)\n- Multiple Table Views so users can organise (just a gimmick idea for now)\n- Make working widgets for the app")
                        .padding(.vertical, 8)
                    }
                    // MARK: - Known Bugs and Issues
                    Section(header: Text("Known Bugs and Issues")) {
                        Text("Known Bugs and Issues:")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("- After moving items in List and restarting the app, the List will restore to the original position where it was saved.\n- Username for accounts cant be changed as Messages.swift will display the usernames wrongly.")
                        .padding(.vertical, 8)
                    }
                    // MARK: - Developer Notes
                    Section(header: Text("Developer Notes")) {
                        Text("Developer Notes")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("No notes to developer at the moment")
                        .padding(.vertical, 8)
                    }
                    // MARK: - Language and User Interfaces used
                    Section(header: Text("Language and User Interfaces used")) {
                        Text("Languages and User Interfaces:")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("- Swift\n- UIKit\n- SwiftUI")
                        .padding(.vertical, 8)
                    }
                    Section() {
                        Text("UIKit")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("Used in:\nStoryboards:\n- Main.storyboard\n- Launchscreen.storyboard\n\nMain Views:\n- AppDelegate.swift\n- SceneDelegate.swift\n- QRCodeScannerViewController.swift\n- TableCell.swift\n- TableTableView.swift\n- Foods.swift\n- Accounts.swift\n- MoreInfoVC.swift\n- SettingsViewController.swift\n- SocialVC.swift\n- addToListVC.swift\n- ImageSaver.swift\n- ImagePicker.swift")
                        .padding(.vertical, 8)
                    }
                    Section() {
                        Text("SwiftUI")
                            .fontWeight(.bold)
                            .padding(.vertical, 4.2)
                            .multilineTextAlignment(.center)
                        
                        Text("Used in:\nMain Views:\n- SettingsSwiftUI.swift\n- buildPlansSwiftUI.swift\n- signUpViewSwiftUI.swift\n- signInViewSwiftUI.swift\n- qrSignInViewSwiftUI.swift\n- accountInfoSwiftUI.swift\n- accountQRSwiftUI.swift\n- changeUsernameSwiftUI.swift\n- changePasswordSwiftUI.swift\n- addToListSwiftUI.swift\n\nSub Views:\n-Banner.swift\n- accountLogIn.swift\n- accountLoggedIn.swift")
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color("bgColorTab"))
            .navigationTitle(Text("App's Summary"))
            .navigationBarItems(
                trailing:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "xmark")
                    }
            )
        }
    }
}

struct buildPlansSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        buildPlansSwiftUI()
    }
}
