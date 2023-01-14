//
//  contactsVM.swift
//  Food Friend
//
//  Created by Tristan on 27/11/22.
//

import SwiftUI
import Foundation
import Firebase

struct Contacts: Codable, Identifiable {
    var id: String?
    var name: String
    var number: String
}

class contactsVM: ObservableObject {
    @Published var contacts = [Contacts]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    func fetchData() {
        db.collection("users").document(finalUID).collection("contacts").order(by: "addedAt", descending: true).addSnapshotListener({(snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            
            self.contacts = documents.map { docSnapshot -> Contacts in
                
                let data = docSnapshot.data()
                let docId = docSnapshot.documentID
                let name = data["name"] as? String ?? ""
                let number = data["number"] as? String ?? ""
                                
                return Contacts(id: docId, name: name, number: number)
            }
        })
    }
}
