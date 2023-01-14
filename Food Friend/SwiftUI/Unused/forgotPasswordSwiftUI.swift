//
//  forgotPasswordSwiftUI.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import SwiftUI
import FirebaseAuth

struct forgotPasswordSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - User Input
    @State private var username = ""
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""

    var body: some View {
        NavigationView {
            VStack {
                Group {
                    Spacer()
                    Image(systemName: "person.badge.key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.top, 75)
                        .padding(.top, 30)
                    Text("Please enter your email address, and a Reset Password Email will be sent to your inbox. Please check your spam folder if you cannot find the email.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Spacer()
                    ZStack(alignment: .trailing) {
                        TextField("Email", text: $username)
                            .padding(20)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                        if isLoggedIn {
                            Button(action: {
                                username = finalEmail
                            }) {
                                Text("Use Current Email")
                                    .padding(7)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .background(.thinMaterial)
                                    .foregroundColor(.blue)
                                    .cornerRadius(7)
                                    .padding(2)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    Button(action: {
                        if username != "" {
                            if username.contains("@") {
                                Auth.auth().sendPasswordReset(withEmail: username) { error in
                                    guard error == nil else {
                                        print("error while trying to send reset password email")
                                        generator2.notificationOccurred(.success)
                                        presentationMode.wrappedValue.dismiss()
                                        return
                                    }
                                    generator2.notificationOccurred(.success)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                generator2.notificationOccurred(.error)
                            }
                        } else {
                            generator2.notificationOccurred(.error)
                        }
                    }) {
                        Text("Send Forgot Password Request")
                            .bold()
                            .frame(width: 360, height: 50)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Forgot Password", displayMode: .inline)
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
        }
        .onLoad {
            generator.impactOccurred(intensity: 0.7)
        }
    }
}

struct forgotPasswordSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        forgotPasswordSwiftUI()
    }
}
