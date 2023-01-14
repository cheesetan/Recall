//
//  SocialPostPicker.swift
//  Recall
//
//  Created by Tristan on 26/8/22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct SocialPostPicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var searchMode = false
    
    @State private var showingAddToListView = false
    @State private var showingQRScannerView = false
    
    @AppStorage("showSidebar", store: .standard) private var showSidebar = false

    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    let foods: Foods
    @ObservedObject var viewModel = FoodsViewModel()
    @ObservedObject var postModel = SocialViewModel()
    
    @AppStorage("socialPickerCloser", store: .standard) private var socialPickerCloser = false
    
    @AppStorage("curUserFoods", store: .standard) private var curUserFoods = ""
    @AppStorage("curUserExpires", store: .standard) private var curUserExpires = ""
    
    @AppStorage("expiredListCount", store: .standard) private var expiredListCount = 0
    //@State private var expiredListCount = 0
    
    @State private var curFoodsCount = 0
    
    @State private var showingAlert = false
    @State private var showingAlert2 = false
    @State private var showingAlert3 = false
    
    @State private var foodsArr = [""]
    @State private var expires = [""]
    
    let dateFormatter = DateFormatter()
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var showingSignInUpView = false
    @State private var curDelFood = ""
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if curFoodsCount == 1 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Your list is empty!")
                            Spacer()
                        }
                        .padding(.bottom, 3)
                        HStack {
                            Spacer()
                            Text("Add items to your list by scanning any product's QR Code or adding them manually.")
                            Spacer()
                        }
                    }
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15))
                    .padding(.horizontal)
                    .fontWeight(.bold)
                } else {
                    List {
                        Section(header: Text("Current Foods").fontWeight(.bold).font(.title3)) {
                            ForEach(viewModel.foods) { food in
                                if dateFormatter.date(from: "\(food.expire)") ?? Date() > Date() {
                                    NavigationLink(destination: SocialPostDesigner(foods: food)) {
                                        HStack {
                                            /*
                                             Image(systemName: "circle.fill")
                                             .foregroundColor(.green)
                                             */
                                            VStack {
                                                HStack {
                                                    Text("\(food.title)")
                                                        .font(.title2)
                                                        .fontWeight(.semibold)
                                                        .multilineTextAlignment(.leading)
                                                    if food.verified == "true" {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                    }
                                                    Spacer()
                                                }
                                                HStack {
                                                    Text("Expires on: \(food.expire)")
                                                        .font(.caption)
                                                        .multilineTextAlignment(.leading)
                                                    Spacer()
                                                }
                                            }
                                            .padding(.vertical, 5)
                                        }
                                    }
                                } else {
                                    
                                }
                            }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    //.searchable(text: $searchText)
                    /*
                     .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                     */
                    .listRowBackground(Color("bgColorTab2"))
                    .background(Color("bgColorTab"))
                    .scrollContentBackground(.hidden)
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Choose a Food to post", displayMode: .inline)
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
        .onAppear {
            print(curUserFoods)
            if isLoggedIn {
                if curUserFoods == "" {
                    curUserFoods = "Apples,. Bananas,. Watermelons"
                }
                foodsArr = curUserFoods.components(separatedBy: ",. ")
                
                if curUserExpires == "" {
                    curUserExpires = "12/2/23,. 24/9/22,. 09/12/22"
                }
                expires = curUserExpires.components(separatedBy: ",. ")
            }
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            self.viewModel.fetchData()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SocialPostPicker_Previews: PreviewProvider {
    static var previews: some View {
        SocialPostPicker(foods: Foods(expire: "12/04/23", title: "Apples", verified: "true"))
    }
}
