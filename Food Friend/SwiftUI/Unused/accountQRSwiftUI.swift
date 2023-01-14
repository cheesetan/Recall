//
//  accountQRSwiftUI.swift
//  Recall
//
//  Created by Tristan on 16/7/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct accountQRSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - For QR Code Generation
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    // MARK: - User information
    @State private var showQRToggle = false
    
    // MARK: - User information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Section() {
                    Spacer()
                    let image = Image(uiImage: generateQRCode(from: "fFASignIn\(finalUsername)\n\(finalPassword)"))
                        .interpolation(.none)
                        .resizable()
                        .background(.red)
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .cornerRadius(16)
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(lineWidth: 5).foregroundColor(.blue))
                        .frame(maxWidth: .infinity, maxHeight: 800, alignment: .center)
                    if showQRToggle {
                        image
                    } else {
                        image.redacted(reason: .placeholder)
                    }
                }
                .contextMenu {
                    Button {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: generateQRCode(from: "fFASignIn\(finalUsername)\n\(finalPassword)"))
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                    }
                }
                Spacer()
                VStack {
                    Spacer()
                    Text("Scan this QR Code under the \"QR Sign In\" section to immediately log in without needing to enter your Username and Password!")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Text("DO NOT share your QR Code with others as they will be able to log in to your account without your knowledge.")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                        .foregroundColor(.red)
                    Text("If your QR Code has been leaked, please change your Password immediately.")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 12)
                Spacer()
                Button {
                    generator.impactOccurred(intensity: 0.7)
                    if showQRToggle == true {
                        showQRToggle = false
                    } else if showQRToggle == false {
                        showQRToggle = true
                    }
                } label: {
                    if showQRToggle != true {
                        Text("Show QR Code")
                            .bold()
                            .frame(width: 360, height: 50)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    } else {
                        Text("Hide QR Code")
                            .bold()
                            .frame(width: 360, height: 50)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    }
                }
            }
            .padding()
            .background(Color("bgColorTab"))
            .navigationBarTitle(Text("\(finalUsername)'s QR Code"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "xmark")
                    })
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

struct accountQRSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        accountQRSwiftUI()
    }
}
