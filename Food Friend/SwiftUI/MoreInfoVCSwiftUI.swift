//
//  MoreInfoVCSwiftUI.swift
//  Recall
//
//  Created by Tristan on 6/8/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI
import FirebaseStorage

struct MoreInfoVCSwiftUI: View {
    
    @State private var actList = 0
    
    @State private var image = UIImage()
    @State private var showSheet = false
    @State private var showSheet2 = false
    
    @State private var loadedImageURL = ""
    @State private var loadedSuccess = false
    
    let food: Foods
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var itemTitle = ""
    @State private var itemExpire = ""
    @State private var itemPlaceholder = ""
    @State private var expireInput = Date()
    
    @State private var editingMode = false
    @State private var showingInfoView = false
    
    @State private var showingDeleteAlert = false
    
    @State private var bgText = "Add an image using the buttons below!"
    
    @State private var expireInputConverted = ""
    
    @State private var isDateTextFieldDisabled = true
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("showingAddButton", store: .standard) private var showingAddButton = true
    
    let dateFormatter = DateFormatter()
    
    @State private var duedate = String()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    HStack{Spacer()}
                    
                    Section(header: HStack {
                        Text("Title")
                            .fontWeight(.bold)
                            .padding(.leading)
                            .padding(.top)
                        Spacer()
                    }) {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: UIScreen.main.bounds.width - 25, height: 60)
                            .foregroundColor(Color("bgColorTab2"))
                            .overlay(
                                Text(food.title)
                                    .padding(.horizontal)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                            )
                    }
                    
                    Section(header: HStack {
                        Text("Due Date and Time")
                            .fontWeight(.bold)
                            .padding(.leading)
                            .padding(.top)
                        Spacer()
                    }) {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: UIScreen.main.bounds.width - 25, height: 60)
                            .foregroundColor(Color("bgColorTab2"))
                            .overlay(
                                Text(duedate)
                                    .padding(.horizontal)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                            )
                    }
                    
                    Section(header: HStack {
                        Text("Description")
                            .fontWeight(.bold)
                            .padding(.leading)
                            .padding(.top)
                        Spacer()
                    }) {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: UIScreen.main.bounds.width - 25)
                            .frame(maxHeight: .infinity)
                            .foregroundColor(Color("bgColorTab2"))
                            .overlay(
                                Text(food.description)
                                    .padding(.top, 20)
                                    .padding(.horizontal)
                                , alignment: .topLeading
                            )
                    }
                    
                    HStack{Spacer()}
                        .padding(.top, 10)
                }
                .onAppear {
                    showingAddButton = false
                    
                    dateFormatter.dateStyle = .long
                    dateFormatter.timeStyle = .short
                    
                    duedate = dateFormatter.string(from: food.dueTime)
                }
                .onDisappear {
                    showingAddButton = true
                }
                .navigationTitle("More Information")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingAddButton = true
                            generator.impactOccurred(intensity: 0.7)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct MoreInfoVCSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoVCSwiftUI(food: Foods(description: "12/03/24", title: "Ham Sandwich", due: "duedate", dueTime: Date()))
    }
}

