//
//  productsVM.swift
//  Food Friend
//
//  Created by Tristan on 7/11/22.
//

import SwiftUI
import Foundation
import Firebase

struct Products: Codable, Identifiable {
    var id: String?
    var title: String
    var description: String
    var price: String
    var imageURL: String
}

class productsVM: ObservableObject {
    @Published var products = [Products]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    func fetchData() {
        db.collection("products").order(by: "addedAt", descending: false).addSnapshotListener({(snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            
            self.products = documents.map { docSnapshot -> Products in
                
                let data = docSnapshot.data()
                let docId = docSnapshot.documentID
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let price = data["price"] as? String ?? ""
                let imageURL = data["imageURL"] as? String ?? ""
                                
                return Products(id: docSnapshot.documentID, title: title, description: description, price: price, imageURL: imageURL)
            }
        })
    }
}
