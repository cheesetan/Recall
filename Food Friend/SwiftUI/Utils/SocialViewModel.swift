//
//  SocialViewModel.swift
//  Recall
//
//  Created by Tristan on 26/8/22.
//

import SwiftUI
import Foundation
import Firebase

struct Posts: Codable, Identifiable {
    var id: String?
    
    var title: String
    var expire: String
    var verified: String
    
    var user: String
    var userID: String
    
    var postTime: String
    var postImageURL: String
    
    var randomInt: String
    var postedFoodsID: String
}

class SocialViewModel: ObservableObject {
    @Published var posts = [Posts]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    var estateUser = ""
    
    let dateFormatter = DateFormatter()
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
        
    func fetchData() {
        if (user != nil) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            db.collection("posts").order(by: "serverTime", descending: true).addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no documents")
                    return
                }
                
                self.posts = documents.map { docSnapshot -> Posts in
                    
                    let data = docSnapshot.data()
                    let docId = docSnapshot.documentID
                    
                    let title = data["title"] as? String ?? ""
                    let expire = data["expire"] as? String ?? ""
                    let verified = data["verified"] as? String ?? ""
                    
                    let username = data["username"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    
                    let postTime = data["postTime"] as? String ?? ""
                    let postImageURL = data["postImageURL"] as? String ?? ""
                    
                    let randomInt = data["imageInt"] as? String ?? ""
                    
                    let postedFoodsID = data["postedFoodsID"] as? String ?? ""

                    return Posts(id: docId, title: title, expire: expire, verified: verified, user: username, userID: userID, postTime: postTime, postImageURL: postImageURL, randomInt: randomInt, postedFoodsID: postedFoodsID)
                }
            })
        }
    }
    
    func postFoods(title: String, expire: String, verified: String, postTime: String, postImageURL: String, imageInt: String, postedFoodsID: String) {
        if (user != nil) {
            db.collection("posts").addDocument(data: [
                "title": title,
                "expire": expire,
                "verified": verified,
                "username": finalUsername,
                "userID": user!.uid,
                "serverTime": Date(),
                "postTime": postTime,
                "postImageURL": postImageURL,
                "imageInt": imageInt,
                "postedFoodsID": postedFoodsID])
        }
    }
}
