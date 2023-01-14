//
//  QRCodeScannerSwiftUI.swift
//  Recall
//
//  Created by Tristan on 5/8/22.
//

import SwiftUI
import CodeScanner
import Firebase
import FirebaseAuth

struct QRCodeScannerSwiftUI: View {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    @State private var isTorchOn = false
    
    @State private var showingAddToListView = false
    @State private var isDateTextFieldDisabled = true
    
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
    
    @AppStorage("selectedView", store: .standard) private var selectedView = 1
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @State private var foodTitleLabel = ""
    @State private var foodExpireLabel = ""
        
    @State private var activeTabIndex = 0
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, simulatedData: "foodFriendApprovedCorn\n12/2/23", shouldVibrateOnSuccess: false, isTorchOn: isTorchOn, completion: handleScanResult)
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("QR Scanner", displayMode: .inline)
            /*
            .navigationBarItems(
                leading:
                    Button {
                        showingAddToListView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .fullScreenCover(isPresented: $showingAddToListView) {
                        NavigationView {
                            VStack(spacing: 15) {
                                
                                /*
                                Spacer()
                                Image(systemName: "doc.fill.badge.plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 125, height: 125)
                                Spacer()
                                */
                                
                                Form {
                                    Section(footer: Text("Press and hold the QR Code to save it to your photos!").frame(maxWidth: .infinity, alignment: .center)) {
                                        Image(uiImage: qrCode)
                                            .resizable()
                                            .interpolation(.none)
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)
                                            .contextMenu {
                                                Button {
                                                    let imageSaver = ImageSaver()
                                                    imageSaver.writeToPhotoAlbum(image: qrCode)
                                                } label: {
                                                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                                                }
                                            }
                                            .padding(.vertical, 40)
                                    }
                                }
                                
                                Group {
                                    TextField("Product Label", text: $titleInput)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                    ZStack(alignment: .trailing) {
                                        TextField("Product Expiry Date", text: $placeholderInput)
                                            .padding(20)
                                            .background(.thinMaterial)
                                            .cornerRadius(10)
                                            .textContentType(.name)
                                            .disabled(isDateTextFieldDisabled)
                                        Spacer()
                                        DatePicker(selection: $expireInput, in: Date.now..., displayedComponents: .date) {
                                        }
                                        .padding(.trailing, 15)
                                    }
                                    .padding(.bottom, 15)

                                    
                                    /*
                                    Text("Birth date is \(expireInput, formatter: dateFormatter)")
                                     */
                                    
                                    Button {
                                        if titleInput != "" && titleInput != " " {
                                            if (user != nil) {
                                                
                                                let df = DateFormatter()
                                                df.dateFormat = "dd/MM/yyyy"
                                                let newText = df.string(from: expireInput)
                                                expireInputConverted = newText
                                                
                                                db.collection("users").document(finalUID).collection("foods").addDocument(data: [
                                                    "addedAt": Date(),
                                                    "title": titleInput,
                                                    "expire": expireInputConverted,
                                                    "verified": "false"])
                                                                                                    
                                                titleInput = ""
                                                
                                                generator2.notificationOccurred(.success)
                                                presentationMode.wrappedValue.dismiss()
                                                showingAddToListView = false
                                                
                                                selectedView = 1
                                            }
                                        } else {
                                            generator2.notificationOccurred(.error)
                                        }
                                    } label:  {
                                        Text("Add To List")
                                            .bold()
                                            .frame(width: 360, height: 50)
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .cornerRadius(10)
                                            .padding(.bottom, 15)
                                    }
                                    .padding(.bottom)
                                }
                                .padding(.horizontal)
                            }
                            .navigationBarTitle(Text("Add Product"), displayMode: .inline)
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                        generator.impactOccurred(intensity: 0.7)
                                        showingAddToListView = false
                                    }) {
                                        Image(systemName: "xmark")
                                    })
                            .onAppear() {
                                generator.impactOccurred(intensity: 0.7)
                                updateCode()
                            }
                            .onChange(of: titleInput) { _ in updateCode() }
                            .onChange(of: expireInput) { _ in updateCode() }
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
            )
            */
            .navigationBarItems(
                leading:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        isTorchOn.toggle()
                    } label: {
                        if isTorchOn {
                            Image(systemName: "flashlight.on.fill")
                        } else {
                            Image(systemName: "flashlight.off.fill")
                        }
                    }
                )
            .navigationBarItems(
                trailing:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
                
                presentationMode.wrappedValue.dismiss()
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
                
                presentationMode.wrappedValue.dismiss()
                selectedView = 1
            } else {
                generator2.notificationOccurred(.error)
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct QRCodeScannerSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerSwiftUI()
    }
}
