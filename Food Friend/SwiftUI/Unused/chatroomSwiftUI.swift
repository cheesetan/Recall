//
//  chatroomSwiftUI.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import SwiftUI
import Firebase

struct chatroomSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - User Input
    @State private var enterCode = ""
    @State private var createRoomName = ""
    @State private var createSecret = false
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Form {
                    VStack(alignment: .center) {
                        Section {
                            Group {
                                TextField("Enter Chat Join Code", text: $enterCode)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .textInputAutocapitalization(.never)
                                    .disabled(isLoggedIn == false)
                                    .keyboardType(.numberPad)
                            }
                            .padding(.bottom)
                            Button(action: {
                                if enterCode != "" {
                                    generator.impactOccurred(intensity: 0.7)
                                    if (Auth.auth().currentUser != nil) {
                                        Firestore.firestore().collection("chatrooms").whereField("joinCode", isEqualTo: Int(enterCode)).getDocuments() { (snapshot, error) in
                                            if let error = error {
                                                print("error getting documents! \(error)")
                                                generator2.notificationOccurred(.error)
                                            } else {
                                                for document in snapshot!.documents {
                                                    Firestore.firestore().collection("chatrooms").document(document.documentID).updateData([
                                                        "users": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])])
                                                    print("enterCode: \(enterCode)")
                                                    generator2.notificationOccurred(.success)
                                                    presentationMode.wrappedValue.dismiss()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    generator2.notificationOccurred(.error)
                                }
                            }) {
                                Text("Join Chat")
                                    .bold()
                                    .frame(width: 360, height: 50)
                                    .background(.blue)
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                                    .padding(.bottom, 15)
                            }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                        Divider()
                        Section {
                            Group {
                                TextField("Enter Chat Name", text: $createRoomName)
                                    .padding(20)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                    .textInputAutocapitalization(.never)
                                    .disabled(isLoggedIn == false)
                                /*
                                Toggle(isOn: $createSecret, label: {
                                    Text("Create as Secret Chat")
                                })
                                 */
                            }
                            .padding(.bottom)
                            Button(action: {
                                generator.impactOccurred(intensity: 0.7)
                                if createRoomName != "" {
                                    if (Auth.auth().currentUser != nil) {
                                        Firestore.firestore().collection("chatrooms").addDocument(data: [
                                            "title": createRoomName,
                                            "joinCode": Int.random(in: 100000..<999999),
                                            "users": [Auth.auth().currentUser!.uid],
                                            "isSecret": "\(createSecret)"]) { err in
                                                if let err = err {
                                                    print("error adding document! \(err)")
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    generator2.notificationOccurred(.success)
                                                    presentationMode.wrappedValue.dismiss()
                                                }
                                            }
                                    }
                                } else {
                                    generator2.notificationOccurred(.error)
                                }
                            }) {
                                Text("Create Chat")
                                    .bold()
                                    .frame(width: 360, height: 50)
                                    .background(.blue)
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    .padding()
                    .navigationBarTitle("Join or Create Chats", displayMode: .inline)
                    .navigationBarItems(
                        trailing:
                            Button(action: {
                                generator.impactOccurred(intensity: 0.7)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                        })
                }
                .listRowBackground(Color("bgColorTab2"))
                .scrollContentBackground(.hidden)
                .background(Color("bgColorTab"))
            }
            .background(Color("bgColorTab"))
        }
        .onAppear {
            if isLoggedIn == false {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

struct chatroomSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        chatroomSwiftUI()
    }
}
