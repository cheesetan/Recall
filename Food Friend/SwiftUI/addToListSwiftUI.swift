//
//  MeView.swift
//  HotProspects
//
//  Created by Paul Hudson on 03/01/2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import CoreData
import UIKit
import Foundation
import Firebase
import FirebaseAuth

struct addToListSwiftUI: View {
    
    @FocusState private var focusedField: Bool
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - User Input
    @State private var titleInput = ""
    @State private var descriptionInput = ""
    @State private var expireInputConverted = ""
    @State private var placeholderInput = ""
    
    @State private var dueDate = Date()
    @State private var dueDate2 = String()
    
    @State private var isDateTextFieldDisabled = true
    
    // MARK: - QR Code Generation
    @State private var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
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
    
    @State private var showDatePicker = false
    
    let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Group {
                    Section(header:
                                Text("Preview")
                        .font(.title3)
                        .fontWeight(.bold)
                    ) {
                        List {
                            VStack {
                                HStack {
                                    Text(titleInput.isEmpty ? "Example Title" : titleInput)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                HStack {
                                    Text(descriptionInput.isEmpty ? "Example Description. This layer should be descriptive to give more information." : descriptionInput)
                                        .font(.subheadline )
                                        .lineLimit(1)
                                    Spacer()
                                }
                                HStack {
                                    Text("Due: \(dueDate2)")
                                        .font(.caption2)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .onAppear {
                                    dateFormatter.dateStyle = .short
                                    dateFormatter.timeStyle = .short
                                    
                                    dueDate2 = dateFormatter.string(from: dueDate)
                                }
                                .onChange(of: dueDate) { newValue in
                                    dueDate2 = dateFormatter.string(from: dueDate)
                                }
                            }
                            .padding(.vertical)
                        }
                        .listRowBackground(Color("bgColorTab2"))
                        .background(Color("bgColorTab"))
                        .scrollContentBackground(.hidden)
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                    }
                    
                    TextField("Recall Title", text: $titleInput, axis: .vertical)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 60)
                        .padding(.leading)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .focused($focusedField)
                    
                    TextField("Recall Description", text: $descriptionInput, axis: .vertical)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 150)
                        .padding(.leading)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .focused($focusedField)
                    
                    DatePicker("Due Date:", selection: $dueDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal)
                        .datePickerStyle(.compact)
                        .frame(width: UIScreen.main.bounds.width - 25, height: 60)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 15)

                    
                    Button {
                        UIApplication.shared.dismissKeyboard()
                        if titleInput != "" && titleInput != " " && descriptionInput != "" && descriptionInput != " " {
                            db.collection("users").document(finalUID).collection("recalls").addDocument(data: [
                                "addedAt": Date(),
                                "title": titleInput,
                                "description": descriptionInput,
                                "due": dueDate])
                            
                            justFromAddManual = true
                            
                            generator2.notificationOccurred(.success)
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            generator2.notificationOccurred(.error)
                        }
                    } label:  {
                        Text("Add To Recalls")
                            .bold()
                            .frame(width: UIScreen.main.bounds.width - 25, height: 60)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle(Text("Add Recall"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        UIApplication.shared.dismissKeyboard()
                        presentationMode.wrappedValue.dismiss()
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "xmark")
                    })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // .banner(data: $titelLabelFieldIsEmpty, show: $showBanner)
    }
}

struct addToListSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        addToListSwiftUI()
    }
}
