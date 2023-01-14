//
//  chatMessageVM.swift
//  Food Friend
//
//  Created by Tristan on 31/10/22.
//

import SwiftUI
import Foundation
import Firebase

struct Message: Codable, Identifiable {
    var id: String?
    var isUser: String
    var displayName: String
    var content: String
}

class chatMessageVM: ObservableObject {
    @Published var message = [Message]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
        
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    func fetchData() {
        db.collection("users").document(finalUID).collection("messages").order(by: "addedAt", descending: false).addSnapshotListener({(snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            
            self.message = documents.map { docSnapshot -> Message in
                
                let data = docSnapshot.data()
                let docId = docSnapshot.documentID
                let isUser = data["isUser"] as? String ?? ""
                let displayName = data["displayName"] as? String ?? ""
                let content = data["content"] as? String ?? ""

                return Message(id: docId, isUser: isUser, displayName: displayName, content: content)
            }
        })
    }
    
    func sendMessage(isUser: String, displayName: String, content: String) {
        db.collection("users").document(finalUID).collection("messages").addDocument(data: [
            "addedAt": Date(),
            "isUser": isUser,
            "displayName": displayName,
            "content": content])
    }
}

