//
//  connectView.swift
//  Food Friend
//
//  Created by Tristan on 26/10/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct connectView: View {
    
    @FocusState private var focusedField: Bool
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - User Input
    @State private var titleInput = "12345678"
    @State private var expireInput = Date()
    @State private var expireInputConverted = ""
    @State private var placeholderInput = ""
    
    @State private var isDateTextFieldDisabled = true
    
    // MARK: - QR Code Generation
    @State private var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.aztecCodeGenerator()
    
    // MARK: - User Settings
    @AppStorage("appendToTop", store: .standard) var appendToTop = true
    @AppStorage("segmentToTop", store: .standard) var segmentToTop = 0
    
    // MARK: - Banner Information
    @State var titelLabelFieldIsEmpty: BannerModifier.BannerData = BannerModifier.BannerData(title: "Requirements Not Fulfilled", detail: "Please ensure that you have entered a Product Label and Expiration Date.", type: .Error)
    
    // MARK: - Showing Banners
    @State var showBanner: Bool = false
    
    // MARK: - Checks if you just came from Manual Product Adding
    @AppStorage("justFromAddManual", store: .standard) var justFromAddManual = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var showQR = false
    
    @State private var connectedAccounts = Int()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    if connectedAccounts > 0 {
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 12)
                            Text("Companions connected: \(connectedAccounts)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    } else {
                        HStack {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 12)
                            Text("Companions connected: \(connectedAccounts)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    Spacer()
                    if showQR {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width - 150, height: UIScreen.main.bounds.width - 150)

                            Image(uiImage: qrCode)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
//                                .cornerRadius(15)
                                .frame(width: UIScreen.main.bounds.width - 175, height: UIScreen.main.bounds.width - 175)
                                .background(Color("bgColorTab"))
                        }
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(.blue))
                        
                        Text(titleInput)
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Image(uiImage: qrCode)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .cornerRadius(15)
                            .frame(width: UIScreen.main.bounds.width - 150, height: UIScreen.main.bounds.width - 150)
                            .background(Color("bgColorTab"))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 5).foregroundColor(.blue))
                            .redacted(reason: .placeholder)
                        
                        Text(titleInput)
                            .font(.title)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    HStack {
                        Button {
                            showQR.toggle()
                            generator.impactOccurred(intensity: 0.7)
                            
                            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                print("uuid: \(uuid)")
                            }
                            
                            if showQR {
                                titleInput = String(Int.random(in: 10000000..<99999999))
                                
                                updateCode()
                            } else {
                                db.collection("users").document(finalUID).updateData([
                                    "connectCode": FieldValue.delete(),
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            }
                        } label: {
                            if showQR {
                                Text("Hide Connect Code")
                                    .padding(15)
                                    .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                    .background(.blue)
                                    .foregroundColor(.white)
                            } else {
                                Text("Show Connect Code")
                                    .padding(15)
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                                    .background(Color("bgColorTab2"))
                                    .foregroundColor(.blue)
                            }
                        }
                        .fontWeight(.bold)
                        .font(.headline)
                        .buttonStyle(.plain)
                        .cornerRadius(16)
                        .padding(.bottom)
                        
                        if showQR {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                titleInput = String(Int.random(in: 10000000..<99999999))
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .padding(15)
                                    .frame(height: 60)
                                
                            }
                            .foregroundColor(.white)
                            .background(.blue)
                            .fontWeight(.bold)
                            .cornerRadius(16)
                            .font(.headline)
                            .buttonStyle(.plain)
                            .padding(.bottom)
                        }
                    }
                }
                .navigationBarTitle(Text("Connect Code"), displayMode: .inline)
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
                            let tempArr = document.get("companions-uuid") as! [Any]

                            connectedAccounts = tempArr.count
                        }
                }
                .onDisappear {
                    db.collection("users").document(finalUID).updateData([
                        "connectCode": FieldValue.delete(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
                .onChange(of: titleInput) { _ in updateCode() }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "reCallApproved\(titleInput)")
        
        if (user != nil) {
            Firestore.firestore().collection("users").document(finalUID).updateData([
                "connectCode": titleInput,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    generator2.notificationOccurred(.error)
                } else {
                    print("Document successfully updated")
                }
            }
        }
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
}

struct connectView_Previews: PreviewProvider {
    static var previews: some View {
        connectView()
    }
}
