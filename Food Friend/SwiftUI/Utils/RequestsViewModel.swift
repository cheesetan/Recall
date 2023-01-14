//
//  RequestsViewModel.swift
//  Recall
//
//  Created by Tristan on 31/8/22.
//

import Foundation
import Firebase
import SwiftUI

struct Requests: Codable, Identifiable {
    var id: String?
    
    var title: String
    var joinCode: Int
    
    var user: String
    var userID: String
    
    var sentToUser: String
    var sentToUserUID: String
}

class RequestsViewModel: ObservableObject {
    
    @Published var requests = [Requests]()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    func fetchData() {
        if (isLoggedIn != false) {
            db.collection("requests").order(by: "serverTime", descending: true).addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no documents")
                    return
                }
                
                self.requests = documents.map { docSnapshot -> Requests in
                    
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    
                    let title = data["title"] as? String ?? ""
                    let joinCode = data["joinCode"] as? Int ?? -1
                    
                    let user = data["users"] as? String ?? ""
                    let userUID = data["userUID"] as? String ?? ""
                    
                    let sentToUser = data["sentToUser"] as? String ?? ""
                    let sentToUserUID = data["sentToUserUID"] as? String ?? ""
                    
                    return Requests(id: docId, title: title, joinCode: joinCode, user: user, userID: userUID, sentToUser: sentToUser, sentToUserUID: sentToUserUID)
                }
            })
        }
    }
    
    func sendNewChatRequest(title: String, username: String, userUID: String) {
        if (user != nil) {
            
            let joinCode = Int.random(in: 100000..<999999)
            
            db.collection("chatrooms").addDocument(data: [
                                                    "title": title,
                                                    "joinCode": joinCode,
                                                    "users": [user!.uid],
                                                    "isSecret": "false"]) { err in
                if let err = err {
                    print("error adding document! \(err)")
                } else {
                    self.db.collection("requests").addDocument(data: [
                                                            "title": title,
                                                            "joinCode": joinCode,
                                                            "users": self.finalUsername,
                                                            "userUID": self.user!.uid,
                                                            "sentToUser": username,
                                                            "sentToUserUID": userUID,
                                                            "serverTime": Date()]) { err in
                        if let err = err {
                            print("error adding document! \(err)")
                        } else {
                        }
                    }
                }
            }
        }
    }
}
