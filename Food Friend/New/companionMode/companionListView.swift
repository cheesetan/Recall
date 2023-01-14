//
//  companionListView.swift
//  Food Friend
//
//  Created by Tristan on 27/10/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct companionListView: View {
    
    @AppStorage("showingSocialPostPicker", store: .standard) private var showingSocialPostPicker = false
    
    @State private var searchText = ""
    @State private var searchMode = false
    
    @State private var showingAddToListView = false
    @State private var showingQRScannerView = false
    
    @AppStorage("showSidebar", store: .standard) private var showSidebar = false

    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    let foods: Foods
    @ObservedObject var viewModel = FoodsViewModel()
    
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
    
    @AppStorage("showingAddButton", store: .standard) private var showingAddButton = true
    
    @AppStorage("sendOneWeekExpireNotif", store: .standard) private var sendOneWeekExpireNotif = true
    @AppStorage("sendExpireNotif", store: .standard) private var sendExpireNotif = true
    
    @AppStorage("autoDeleteRecalls", store: .standard) private var autoDeleteRecalls = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ZStack {
                    Color("bgColorTab")
                        .ignoresSafeArea()
                    VStack {
                        List {
                            Section(header:
                                        HStack{
                                Text("Recalls")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                Spacer()
                                Button {
                                    showingAlert3 = true
                                    generator2.notificationOccurred(.warning)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .fontWeight(.bold)
                                .font(.title3)
                                .alert("Warning", isPresented: $showingAlert3, actions: {
                                    Button("Cancel", role: .cancel, action: {
                                    })
                                    Button("Delete", role: .destructive, action: {
                                        viewModel.foods.forEach { food in
                                            db.collection("users").document(finalUID).collection("recalls").document(food.id!).delete() { err in
                                                if let err = err {
                                                    print("Error removing document: \(err)")
                                                } else {
                                                    print("Document successfully removed!")
                                                }
                                            }
                                        }
                                    })
                                }, message: {
                                    Text("Are you sure you want to delete all of your Recalls? This action cannot be undone.")
                                })
                                .textCase(nil)
                            }, footer: Text("").padding(.bottom, 50)) {
                                ForEach(viewModel.foods) { food in
                                    NavigationLink(destination: MoreInfoVCSwiftUI(food: food)) {
                                        VStack {
                                            HStack {
                                                Text(food.title)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                            HStack {
                                                Text(food.description)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                            HStack {
                                                Text("Due: \(food.due)")
                                                    .font(.caption2)
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                        }
                                        .padding(.vertical)
                                        .swipeActions() {
                                            Button(role: .destructive) {
                                                db.collection("users").document(finalUID).collection("recalls").document(food.id!).delete() { err in
                                                    if let err = err {
                                                        print("Error removing document: \(err)")
                                                    } else {
                                                        print("Document successfully removed!")
                                                    }
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                        }
                                        .onAppear {
                                            let imageName = "AppIcon"
                                            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
                                            
                                            //                                                let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
                                            
                                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])  {
                                                success, error in
                                                if success {
                                                    print("authorisation granted")
                                                } else if let error = error {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            
                                            let hourarray = food.dueTime.formatted(.dateTime.hour()).components(separatedBy: " ")
                                            
                                            let content = UNMutableNotificationContent()
                                            content.title = "\(finalEmail)"
                                            content.subtitle = "\"Recall Due\" Notification Sent"
                                            content.body = "\(food.title) has reached its deadline."
                                            content.sound = UNNotificationSound.default
                                            
                                            var dateComponents = DateComponents()
                                            dateComponents.minute = Int(food.dueTime.formatted(.dateTime.minute()))
                                            dateComponents.hour = Int(hourarray[0])
                                            dateComponents.day = Int(food.dueTime.formatted(.dateTime.day()))
                                            dateComponents.month = Int(food.dueTime.formatted(.dateTime.month()))
                                            dateComponents.year = Int(food.dueTime.formatted(.dateTime.year()))
                                            
                                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                                            
                                            let request = UNNotificationRequest(identifier: food.id!, content: content, trigger: trigger)
                                            
                                            UNUserNotificationCenter.current().add(request)
                                            
                                            
                                            let fifteenminbfr = food.dueTime - 900
                                            print(fifteenminbfr)
                                            let hourarray2 = fifteenminbfr.formatted(.dateTime.hour()).components(separatedBy: " ")
                                            
                                            let content2 = UNMutableNotificationContent()
                                            content2.title = "\(finalEmail)"
                                            content2.subtitle = "\"Recall Due Soon\" Notification Sent"
                                            content2.body = "\(food.title) will be due in 15 minutes."
                                            content2.sound = UNNotificationSound.default
                                            
                                            var dateComponents2 = DateComponents()
                                            dateComponents2.minute = Int(fifteenminbfr.formatted(.dateTime.minute()))
                                            dateComponents2.hour = Int(hourarray2[0])
                                            dateComponents2.day = Int(fifteenminbfr.formatted(.dateTime.day()))
                                            dateComponents2.month = Int(fifteenminbfr.formatted(.dateTime.month()))
                                            dateComponents2.year = Int(fifteenminbfr.formatted(.dateTime.year()))
                                            
                                            let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: false)
                                            
                                            let request2 = UNNotificationRequest(identifier: "\(food.id!)15", content: content2, trigger: trigger2)
                                            
                                            UNUserNotificationCenter.current().add(request2)
                                            
                                            print("oogly \(food.dueTime.formatted(.dateTime.hour()))")
                                        }
                                    }
                                }
                                .onDelete(perform: delete)
                                .listRowBackground(Color("bgColorTab2"))
                            }
                        }
                        .background(Color("bgColorTab"))
                        .listStyle(InsetGroupedListStyle())
                        .listRowBackground(Color("bgColorTab2"))
                        .scrollContentBackground(.hidden)
                    }
                    .background(Color("bgColorTab"))
                }
                .background(Color("bgColorTab"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("\(finalEmail)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .background(Color("bgColorTab"))

            
            Button {
                generator.impactOccurred(intensity: 0.7)
                self.showingAddToListView.toggle()
            } label: {
                if showingAddButton {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .frame(width: 58, height: 58, alignment: .center)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
            .padding(.trailing, 20)
            .fullScreenCover(isPresented: $showingAddToListView) {
                addToListSwiftUI()
            }
        }
        .onAppear {
            viewModel.fetchData()
            
            viewModel.foods.forEach { food in
                if food.dueTime <= Date() && autoDeleteRecalls {
                    db.collection("users").document(finalUID).collection("recalls").document(food.id!).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        generator.impactOccurred(intensity: 0.7)
        foodsArr.remove(atOffsets: offsets)
        curUserFoods = foodsArr.joined(separator:",. ")
    }
}

struct companionListView_Previews: PreviewProvider {
    static var previews: some View {
        companionListView(foods: Foods(description: "corn", title: "corn", due: "duedate", dueTime: Date()))
    }
}
