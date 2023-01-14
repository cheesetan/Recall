//
//  chatRequestView.swift
//  Recall
//
//  Created by Tristan on 1/9/22.
//

import SwiftUI
import Firebase

struct chatRequestView: View {
    
    let accountName: String
    let docID: String
    let joinCode: Int
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        HStack {
            /*
            Image(systemName: "person.fill")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(Color.white)
                .padding(20)
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .padding(.trailing, 8)
            */
            VStack(alignment: .leading, spacing: 5) {
                Text("\(accountName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                Text("\(accountName) has invited you to chat with them!")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            .padding(.trailing)
            VStack {
                Button {
                    generator.impactOccurred(intensity: 0.7)
                    Firestore.firestore().collection("chatrooms").whereField("joinCode", isEqualTo: Int(joinCode)).getDocuments() { (snapshot, error) in
                        if let error = error {
                            print("error getting documents! \(error)")
                            generator2.notificationOccurred(.error)
                            Firestore.firestore().collection("requests").document(docID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                }
                            }
                        } else {
                            for document in snapshot!.documents {
                                Firestore.firestore().collection("chatrooms").document(document.documentID).updateData([
                                    "users": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])])
                                print("enterCode: \(joinCode)")
                                generator2.notificationOccurred(.success)
                                Firestore.firestore().collection("requests").document(docID).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed!")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Join")
                    }
                    .frame(width: 100)
                    .padding(8)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                Button {
                    generator.impactOccurred(intensity: 0.7)
                    Firestore.firestore().collection("requests").document(docID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete")
                        Spacer()
                    }
                    .frame(width: 100)
                    .padding(8)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            /*
            Image(systemName: "chevron.right")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13, alignment: .center)
                .foregroundColor(Color.gray)
             */
            
        } //: HSTACK
        .padding(4)
        .background(Color("bgColorTab"))
    }
}

struct chatRequestView_Previews: PreviewProvider {
    static var previews: some View {
        chatRequestView(accountName: "cheesetan_", docID: "placeholder", joinCode: 123456)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
