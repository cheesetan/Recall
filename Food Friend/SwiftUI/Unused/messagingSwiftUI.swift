//
//  messagingSwiftUI.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import SwiftUI
import Firebase

struct messagingSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Showing Views
    @State private var isShowingchatroom = false
    @State var joinModal = false
    
    @AppStorage("showingMessageView", store: .standard) private var showingMessageView = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var showingRequestView = false
    
    @State var viewID = 0
    @AppStorage("currUserz2", store: .standard) private var currUserz2 = ""
    @AppStorage("countarrayOfcurrUsernames", store: .standard) private var countarrayOfcurrUsernames = 0

    @ObservedObject var viewModel = ChatroomsViewModel()
    
    @AppStorage("hideCustomTabBar", store: .standard) private var hideCustomTabBar = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if isLoggedIn {
                        List {
                            //Section(header: Text("Current Chat").font(.title3)) {
                                ForEach(viewModel.chatrooms) { chatroom in
                                    NavigationLink(destination: Messages(chatroom: chatroom)) {
                                        HStack {
                                            VStack {
                                                if chatroom.isSecret == "true" {
                                                    HStack {
                                                        Image(systemName: "message.circle")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 40, height: 40)
                                                        HStack {
                                                            Text(chatroom.title)
                                                                .padding(.vertical)
                                                                .padding(.leading, 10)
                                                            Image(systemName: "lock.fill")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: 10, height: 10)
                                                        }
                                                    }
                                                } else {
                                                    HStack {
                                                        Image(systemName: "message.circle")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 40, height: 40)
                                                        Text(chatroom.title)
                                                            .padding(.vertical)
                                                            .padding(.trailing)
                                                            .padding(.leading, 10)
                                                    }
                                                }
                                            }
                                            .onAppear {
                                                print("chatroom: \(chatroom)")
                                            }
                                            Spacer()
                                        }
                                    }
                                    .swipeActions {
                                        Button(role: .destructive, action: {
                                            generator.impactOccurred(intensity: 0.7)
                                            Firestore.firestore().collection("chatrooms").document(chatroom.id).updateData([
                                                "users": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                                            ]) { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    print("Document successfully updated")
                                                    generator2.notificationOccurred(.success)
                                                }
                                            }
                                        }) {
                                            Text("Leave")
                                        }
                                    }
                                }
                                .listRowBackground(Color("bgColorTab2"))
                            //}
                            /*
                             .refreshable {
                             viewModel.fetchData()
                             }
                             */
                        }
                        .listRowBackground(Color("bgColorTab2"))
                        .background(Color("bgColorTab"))
                        .scrollContentBackground(.hidden)
                    }
                    if isLoggedIn == false {
                        Text("Please Log In to an existing account or Sign Up for an account to use the Messaging feature.")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.background)
                            .fontWeight(.bold)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Chats")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        isShowingchatroom = true
                    }) {
                        Image(systemName: "plus")
                    })
            .disabled(isLoggedIn == false)
            .sheet(isPresented: $isShowingchatroom) {
                chatroomSwiftUI()
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        showingRequestView = true
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                    })
            .disabled(isLoggedIn == false)
            .sheet(isPresented: $showingRequestView) {
                messageRequestSwiftUI(requests: Requests(id: "placeholder", title: "placeholder", joinCode: 123456, user: "placeholder", userID: "placeholder", sentToUser: "placeholder", sentToUserUID: "placeholder"))
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    })
            /*
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                VStack {
                    Text("Hello, World!")
                }
                .navigationBarTitle("Messages", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            generator.impactOccurred(intensity: 0.7)
                            isShowingchatroom = true
                        }) {
                            Image(systemName: "plus")
                        })
                .sheet(isPresented: $isShowingchatroom) {
                    chatroomSwiftUI()
                }
                .navigationBarItems(
                    leading:
                        Button(action: {
                            generator.impactOccurred(intensity: 0.7)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                    })
            }
            */
            
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            hideCustomTabBar = true
            
            currUserz2 = ""
            countarrayOfcurrUsernames = 0
            if Auth.auth().currentUser != nil {
                Firestore.firestore().collection("chatrooms").whereField("users", arrayContains: Auth.auth().currentUser!.uid)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                if currUserz2 == "" {
                                    currUserz2 = ", \(document.get("title") ?? "")"
                                } else {
                                    currUserz2 = "\(currUserz2), \(document.get("title") ?? "")"
                                }
                                print("amogus \(currUserz2)")
                            }
                        }
                        let arrayOfcurrUsernames = currUserz2.components(separatedBy: ", ")
                        print("amogus2 \(arrayOfcurrUsernames)")
                        
                        print("amogus3 \(arrayOfcurrUsernames.count)")
                        print("amogus4 \(arrayOfcurrUsernames.count - 1)")
                        
                        countarrayOfcurrUsernames = arrayOfcurrUsernames.count - 1
                    }
            } else {
                countarrayOfcurrUsernames = 0
            }

            if isLoggedIn == false {
                presentationMode.wrappedValue.dismiss()
            }
            prefinalUID = finalUID
            viewID += 1
            print("viewID: \(viewID)")
            
            self.viewModel.fetchData()
        }
            
        
        .onDisappear {
            hideCustomTabBar = false
            viewModel.fetchData()
        }
         
    }
}

struct messagingSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        messagingSwiftUI()
    }
}
