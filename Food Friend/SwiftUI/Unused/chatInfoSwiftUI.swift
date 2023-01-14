//
//  chatInfoSwiftUI.swift
//  Recall
//
//  Created by Tristan on 23/7/22.
//

import SwiftUI
import Firebase

struct chatInfoSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showChatCode = false
    @State private var secretChatOn = false
    
    @ObservedObject var viewModel = MessagesViewModel()
    @State var messageField = ""
    @State private var newRoomCode = ""
    
    @AppStorage("curRoomTitle", store: .standard) private var curRoomTitle = ""
    @AppStorage("curRoomCode", store: .standard) private var curRoomCode = ""
    @AppStorage("curRoomID", store: .standard) private var curRoomID = ""
    @AppStorage("curRoomUsers", store: .standard) private var curRoomUsers = ""
    @AppStorage("curRoomSecret", store: .standard) private var curRoomSecret = ""
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    
    @AppStorage("tempuserholdergetter", store: .standard) private var tempuserholdergetter = ""
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var curChatUsers2 = [String].self
    @State private var curChatUsers3 = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section() {
                        TextField("Enter a chat name...", text: $messageField)
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .multilineTextAlignment(.leading)
                        HStack {
                            Spacer()
                            Button(action: {
                                generator.impactOccurred(intensity: 0.7)
                                if messageField != "" && messageField != " " && messageField != curRoomTitle {
                                    generator2.notificationOccurred(.success)
                                    viewModel.changeChatName(messageContent: messageField, docId: curRoomID, displayName: finalUsername)
                                    Firestore.firestore().collection("chatrooms").document(curRoomID).updateData([
                                        "title": messageField])
                                    curRoomTitle = messageField
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    generator2.notificationOccurred(.error)
                                }
                            }) {
                                Text("Change Chat Name")
                                    .bold()
                                    .frame(width: 330, height: 50)
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .cornerRadius(10)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                    }
                    Section(header: Text("Chat Code"), footer: Text("Regenerating the Chat's Join Code will remove all pending invites to this Chat.").padding(.top, 5)) {
                        HStack {
                            Text("Chat Code:")
                            Spacer()
                            if showChatCode == false {
                                Text(curRoomCode)
                                    .redacted(reason: .placeholder)
                            } else {
                                Text(curRoomCode)
                            }
                        }
                        Toggle(isOn: $showChatCode, label: {
                            Text("Show Chat Code")
                        })
                        Button(action: {
                            generator.impactOccurred(intensity: 0.7)
                            newRoomCode = String(Int.random(in: 100000..<999999))
                            Firestore.firestore().collection("chatrooms").document(curRoomID).updateData([
                                "joinCode": Int(newRoomCode)])
                            curRoomCode = newRoomCode
                        }) {
                            Text("Regenerate Chat Code")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    /*
                    Section(header: Text("Secret Chat"), footer: Text("Show when participants screenshot or screen record the chat!").padding(.top, 5)) {
                        Toggle(isOn: $secretChatOn, label: {
                            Text("Secret Chat")
                        })
                        .disabled(true)
                    }
                     */
                    /*
                    Section() {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            Firestore.firestore().collection("chatrooms").document(curRoomID).updateData([
                                "messages": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                    generator2.notificationOccurred(.error)
                                } else {
                                    print("Document successfully updated")
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } label: {
                            Text("Clear Chat")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                     */
                    Section(header: Text("Participants")) {
                        HStack {
                            userchatlistView(userChat: arrOfCurChatUsers(from: curRoomUsers))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }

                    Section() {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            Firestore.firestore().collection("chatrooms").document(curRoomID).updateData([
                                "users": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                    generator2.notificationOccurred(.error)
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Leave Chat")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(Color("bgColorTab2"))
                }
                .listRowBackground(Color("bgColorTab2"))
                .background(Color("bgColorTab"))
                .scrollContentBackground(.hidden)
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle(curRoomTitle, displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if curRoomSecret == "true" {
                secretChatOn = true
            } else {
                secretChatOn = false
            }
            messageField = curRoomTitle
            if isLoggedIn == false {
                presentationMode.wrappedValue.dismiss()
            }
            if prefinalUID != finalUID {
                presentationMode.wrappedValue.dismiss()
            }
            
            Firestore.firestore().collection("chatrooms").whereField("joinCode", isEqualTo: Int(curRoomCode)).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let currRoomUsers = document.get("users") as! [Any]
                            print("pineapples \(currRoomUsers.description)")
                            curRoomUsers = currRoomUsers.description
                        }
                    }
                }
        }
    }
    
    func getUsernames(UID: String) -> String {
        if (Auth.auth().currentUser != nil) {
            let query = Firestore.firestore().collection("users").whereField("UID", isEqualTo: UID)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let tempfinalgetuser = "\(document.get("username") ?? "UNKNOWNS")"
                        tempuserholdergetter = tempfinalgetuser
                    }
                }
            }
        }
        let temp2finalgetuser = tempuserholdergetter
        tempuserholdergetter = ""
        if temp2finalgetuser != "" {
            return temp2finalgetuser
        } else {
            return ""
        }
    }
    
    func arrOfCurChatUsers(from string: String) -> [String] {
        
        var temparrroomuser = string.replacingOccurrences(of: "nil", with: "")
        temparrroomuser = temparrroomuser.replacingOccurrences(of: "[", with: "")
        temparrroomuser = temparrroomuser.replacingOccurrences(of: "]", with: "")

        let arrayOfRoomUsernames = temparrroomuser.components(separatedBy: ", ")
        print(arrayOfRoomUsernames)
        
        return arrayOfRoomUsernames
    }
}

struct chatInfoSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        chatInfoSwiftUI()
    }
}
