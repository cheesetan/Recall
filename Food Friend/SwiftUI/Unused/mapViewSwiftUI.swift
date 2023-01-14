//
//  mapViewSwiftUI.swift
//  Recall
//
//  Created by Tristan on 30/7/22.
//

import SwiftUI

struct mapViewSwiftUI: View {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var isShowingNGOs = false
    @State private var isShowingFD = false
    @State private var isShowingFF = false
    
    @State private var isShowingSuggest = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("NGOs")) {
                        HStack {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                isShowingNGOs = true
                            } label: {
                                Text("NGOs in Singapore")
                                    .foregroundColor(Color.orange)
                            }
                            .fullScreenCover(isPresented: $isShowingNGOs) {
                                ngoMapSwiftUI()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    Section(header: Text("Food Drives")) {
                        HStack {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                isShowingFD = true
                            } label: {
                                Text("Food Drives in Singapore")
                                    .foregroundColor(Color.blue)
                            }
                            .fullScreenCover(isPresented: $isShowingFD) {
                                foodDriveSwiftUI()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    /*
                    Section(header: Text("Food Fridges")) {
                        HStack {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                isShowingFF = true
                            } label: {
                                Text("Food Fridges in Singapore")
                                    .foregroundColor(Color.green)
                            }
                            .fullScreenCover(isPresented: $isShowingFF) {
                                foodFridgesSwiftUI()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                     */
                }
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Donate", displayMode: .large)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        isShowingSuggest = true
                    }) {
                        Image(systemName: "plus.circle")
                    })
            .disabled(isLoggedIn == false)
            .sheet(isPresented: $isShowingSuggest) {
                suggestNewLocationSwiftUI()
            }
        }
    }
}

struct mapViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        mapViewSwiftUI()
    }
}
