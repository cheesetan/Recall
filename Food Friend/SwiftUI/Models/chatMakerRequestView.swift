//
//  chatMakerRequestVoew.swift
//  Recall
//
//  Created by Tristan on 2/9/22.
//

import SwiftUI
import Firebase

struct chatMakerRequestView: View {
    
    let sendToUser: String
    let sendToUserUID: String
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @ObservedObject var viewModel = RequestsViewModel()
    
    @State private var chatTitle = ""
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        VStack {
            TextField("Create Chat Name", text: $chatTitle)
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.top, 10)
            Button {
                if chatTitle != "" && chatTitle != " " {
                    viewModel.sendNewChatRequest(title: chatTitle, username: sendToUser, userUID: sendToUserUID)
                    generator2.notificationOccurred(.success)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    generator2.notificationOccurred(.error)
                }
            } label: {
                Text("Create and Send Chat Request")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
    }
}

struct chatMakerRequestView_Previews: PreviewProvider {
    static var previews: some View {
        chatMakerRequestView(sendToUser: "cheesetan_", sendToUserUID: "placeholder")
    }
}
