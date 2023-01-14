//
//  messageRequestSwiftUI.swift
//  Recall
//
//  Created by Tristan on 31/8/22.
//

import SwiftUI
import Firebase

struct messageRequestSwiftUI: View {
    
    let requests: Requests
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
        
    @AppStorage("showingRequestView", store: .standard) private var showingRequestView = false
    
    @ObservedObject var viewModel = RequestsViewModel()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    init(requests: Requests) {
        self.requests = requests
        viewModel.fetchData()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { value in
                        LazyVStack {
                            Section(footer: Text("Chat requests may not work if the Chat's Join Code has been regenerated")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)) {
                                ForEach(viewModel.requests) { request in
                                    if request.sentToUserUID == user!.uid {
                                        chatRequestView(accountName: request.user, docID: request.id!, joinCode: request.joinCode)
                                            .padding(.vertical)
                                        Divider()
                                    }
                                }
                            }
                                .listRowBackground(Color("bgColorTab2"))
                                .scrollContentBackground(.hidden)
                                .background(Color("bgColorTab"))
                        }
                    }
                }
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Chat Requests", displayMode: .large)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                        showingRequestView = false
                    }) {
                        Image(systemName: "xmark")
                    })
        }
        .onAppear {
            viewModel.fetchData()
            print("dog: \(viewModel.requests)")
            //viewModel.sendNewChatRequest(title: "abcTest", username: finalUsername, userUID: user!.uid)
        }
    }
}

struct messageRequestSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        messageRequestSwiftUI(requests: Requests(id: "placeholder", title: "placeholder", joinCode: 123456, user: "placeholder", userID: "placeholder", sentToUser: "placeholder", sentToUserUID: "placeholder"))
    }
}
