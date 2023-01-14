//
//  FoodsViewModel.swift
//  Recall
//
//  Created by Tristan on 7/8/22.
//

import SwiftUI
import Foundation
import Firebase

struct Foods: Codable, Identifiable {
    var id: String?
    var description: String
    var title: String
    var due: String
    var dueTime: Date
}

class FoodsViewModel: ObservableObject {
    @Published var foods = [Foods]()
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
        dateFormatter.dateFormat = "dd/MM/yyyy"
        db.collection("users").document(finalUID).collection("recalls").order(by: "due", descending: false).addSnapshotListener({(snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            
            self.foods = documents.map { docSnapshot -> Foods in
                
                let data = docSnapshot.data()
                let docId = docSnapshot.documentID
                let description = data["description"] as? String ?? ""
                let title = data["title"] as? String ?? ""
                let due = data["due"] as? Timestamp ?? Timestamp(date: Date())
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let dueUpdate = dateFormatter.string(from: due.dateValue())
                                
                return Foods(id: docId, description: description, title: title, due: dueUpdate, dueTime: due.dateValue())
            }
        })
    }
}
