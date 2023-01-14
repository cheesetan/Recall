//
//  MessagesViewModel.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import SwiftUI
import Foundation
import Firebase

struct oldMessage: Codable, Identifiable {
    var id: String?
    var content: String
    var name: String
    var msg: String
    var isSS: String
    var senderID: String
}

class MessagesViewModel: ObservableObject {
    @Published var messages = [oldMessage]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    var estateUser = ""
    
    func sendMessage(messageContent: String, docId: String, displayName: String) {
        if (user != nil) {
            db.collection("chatrooms").document(docId).collection("messages").addDocument(data: [
                                                                                            "sentAt": Date(),
                                                                                            "displayName": displayName,
                                                                                            "content": messageContent,
                                                                                            "sender": user!.uid,
                                                                                            "isMsg": "true",
                                                                                            "isSS": "false"])
        }
    }
    
    func changeChatName(messageContent: String, docId: String, displayName: String) {
        if (user != nil) {
            db.collection("chatrooms").document(docId).collection("messages").addDocument(data: [
                                                                                            "sentAt": Date(),
                                                                                            "displayName": displayName,
                                                                                            "content": messageContent,
                                                                                            "sender": user!.uid,
                                                                                            "isMsg": "false",
                                                                                            "isSS": "false"])
        }
    }
    
    func SSSend(messageContent: String, docId: String, displayName: String) {
        if (user != nil) {
            db.collection("chatrooms").document(docId).collection("messages").addDocument(data: [
                                                                                            "sentAt": Date(),
                                                                                            "displayName": displayName,
                                                                                            "content": messageContent,
                                                                                            "sender": user!.uid,
                                                                                            "isMsg": "true",
                                                                                            "isSS": "true"])
        }
    }
    
    func setNewAccount(username: String, password: String, docId: String, UID: String) {
        if (user != nil) {
            db.collection("users").document(docId).setData([
                "email": user!.email,
                "password": password,
                "UID": UID,
                "cart": [],
                "liked": [],
                "seekApproval": "false",
                "companions-uuid": [],
                "premium": "false",
                "autodelete": "true"
            ])
        }
    }
    
    func fetchData(docId: String) {
        
        @AppStorage("dpName", store: .standard) var dpName = ""
        
        if (user != nil) {
            db.collection("chatrooms").document(docId).collection("messages").order(by: "sentAt", descending: true).addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no documents")
                    return
                }
                
                self.messages = documents.map { docSnapshot -> oldMessage in
                    
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    let content = data["content"] as? String ?? ""
                    let dpName = data["displayName"] as? String ?? ""
                    // let displayName = data["displayName"] as? String ?? ""
                    let isMsg = data["isMsg"] as? String ?? ""
                    let isSS = data["isSS"] as? String ?? ""
                    let senderID = data["sender"] as? String ?? ""
                           
                    /*
                    if (self.user != nil) {
                        let query = self.db.collection("users").whereField("UID", isEqualTo: senderID)
                        query.getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("cucumbers \(document.get("username") ?? "UNKNOWNS"), \(content)")
                                    dpName = "\(document.get("username") ?? "UNKNOWNS")"
                                }
                            }
                        }
                    }
                     */
                    
                    print("cucumbers2 \(dpName)")
                    return oldMessage(id: docId, content: content, name: dpName, msg: isMsg, isSS: isSS, senderID: senderID)
                }
            })
        }
    }
    
    func fetchUsername(email: String) {
        @AppStorage("finalUsername", store: .standard) var finalUsername = ""
        if (user != nil) {
            let query = db.collection("users").whereField("email", isEqualTo: email)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        finalUsername = "\(document.get("username") ?? "UNKNOWNS")"
                    }
                }
            }
        }
    }
    
    func getUser2(UID: String) -> String {
        if (user != nil) {
            let query = db.collection("users").whereField("UID", isEqualTo: UID)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("cheese2 \(document.get("username"))")
                        self.estateUser = (document.get("username") as? String)!
                    }
                }
            }
        }
        print("cheese \(estateUser)")
        return estateUser
    }
}
