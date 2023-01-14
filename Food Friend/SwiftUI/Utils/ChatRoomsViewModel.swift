//
//  ChatRoomsViewModel.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import Foundation
import Firebase
import SwiftUI

struct Chatroom: Codable, Identifiable {
    var id: String
    var title: String
    var joinCode: Int
    var isSecret: String
}


class ChatroomsViewModel: ObservableObject {
    
    @Published var chatrooms = [Chatroom]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func fetchData() {
        
        @AppStorage("userChatTitles", store: .standard) var userChatTitles = ""
        @AppStorage("userChatJoinCodes", store: .standard) var userChatJoinCodes = 0

        if (user != nil) {
            db.collection("chatrooms").whereField("users", arrayContains: user!.uid).addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print ("no docs returned!")
                    return
                }
                
                self.chatrooms = documents.map({docSnapshot -> Chatroom in
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let title = data["title"] as? String ?? ""
                    let joinCode = data["joinCode"] as? Int ?? -1
                    let secretChat = data["isSecret"] as? String ?? ""
                    
                    userChatTitles = data["title"] as? String ?? ""
                    userChatJoinCodes = data["joinCode"] as? Int ?? -1

                    return Chatroom(id: docId, title: title, joinCode: joinCode, isSecret: secretChat)
                })
            })   
        }
    }
    
    func createChatroom(title: String, isSecret: Bool, handler: @escaping () -> Void) {
        if (user != nil) {
            db.collection("chatrooms").addDocument(data: [
                                                    "title": title,
                                                    "joinCode": Int.random(in: 10000..<99999),
                                                    "users": [user!.uid],
                                                    "isSecret": "false"]) { err in
                if let err = err {
                    print("error adding document! \(err)")
                } else {
                    handler()
                }
                
            }
        }
    }
    
    func joinChatroom(code: String, handler: @escaping () -> Void) {
        if (user != nil) {
            db.collection("chatrooms").whereField("joinCode", isEqualTo: Int(code)).getDocuments() { (snapshot, error) in
                if let error = error {
                    print("error getting documents! \(error)")
                } else {
                    for document in snapshot!.documents {
                        self.db.collection("chatrooms").document(document.documentID).updateData([
                                                                                                    "users": FieldValue.arrayUnion([self.user!.uid])])
                        handler()
                    }
                }
                
            }
        }
    }
}
