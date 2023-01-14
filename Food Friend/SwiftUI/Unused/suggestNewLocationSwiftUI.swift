//
//  suggestNewLocationSwiftUI.swift
//  Recall
//
//  Created by Tristan on 31/7/22.
//

import SwiftUI
import Firebase

struct suggestNewLocationSwiftUI: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var catType = 0
    @State private var orgLocationInput = 0
    
    @State private var orgName = ""
    @State private var orgAddress = ""
    @State private var orgPostal = ""
    @State private var orgCat = ""
    
    @State private var finalOrgLocation = ""
    @State private var finalOrgCatType = ""
        
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 125)
                Spacer()
                TextField("Organisation Name", text: $orgName)
                    .padding(20)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding(.vertical, 3)
                if orgLocationInput == 0 {
                    TextField("Organisation Address", text: $orgAddress)
                        .padding(20)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.vertical, 3)
                } else {
                    TextField("Organisation Postal Code", text: $orgPostal)
                        .padding(20)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.vertical, 3)
                        .keyboardType(.numberPad)
                }
                Picker("Organisation Location", selection: $orgLocationInput) {
                    Text("Address").tag(0)
                    Text("Postal Code").tag(1)
                }
                .padding(.vertical, 3)
                .pickerStyle(.segmented)
                HStack {
                    Text("Organisation Category:")
                        .multilineTextAlignment(.center)
                    Spacer()
                    ZStack {
                        Spacer()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                        Picker("Food Drive Category", selection: $catType) {
                            Text("NGOs").tag(0)
                            Text("Food Drives").tag(1)
                            Text("Food Fridges").tag(2)
                            Text("Others").tag(3)
                        }
                        .onTapGesture {
                            generator.impactOccurred(intensity: 0.7)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 3)
                if catType == 3 {
                    TextField("Organisation Category", text: $orgCat)
                        .padding(20)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.vertical, 3)
                }
                Button {
                    // if not empty fields
                    
                    if orgLocationInput == 0 {
                        finalOrgLocation = orgAddress
                    } else {
                        finalOrgLocation = String(orgPostal)
                    }
                    
                    if catType == 3 {
                        finalOrgCatType = orgCat
                    } else if catType == 0 {
                        finalOrgCatType = "NGOs"
                    } else if catType == 1 {
                        finalOrgCatType = "Food Drives"
                    } else if catType == 2 {
                        finalOrgCatType = "Food Fridges"
                    }
                    
                    if orgName != "" && finalOrgCatType != "" && finalOrgLocation != "" {
                    
                    if (Auth.auth().currentUser != nil) {
                        Firestore.firestore().collection("org suggestions").addDocument(data: [
                            "sentAt": Date(),
                            "displayName": finalUsername,
                            "orgName": orgName,
                            "orgLocation": finalOrgLocation,
                            "orgCat": finalOrgCatType,
                            "sender":  Auth.auth().currentUser!.uid])
                    }
                    
                    generator2.notificationOccurred(.success)
                    presentationMode.wrappedValue.dismiss()
                    
                    } else {
                        generator2.notificationOccurred(.error)
                    }
                } label: {
                    Text("Submit")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                }
                .padding(.vertical, 3)
            }
            .padding(.horizontal)
            .background(Color("bgColorTab"))
            .navigationBarTitle("Suggest New Location", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    })
        }
    }
}

struct suggestNewLocationSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        suggestNewLocationSwiftUI()
    }
}
