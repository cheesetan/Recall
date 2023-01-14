//
//  WatchTestSwiftUI().swift
//  Recall
//
//  Created by Tristan on 8/8/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct WatchTestSwiftUI: View {
    // @ObservedObject をつけてメッセージ配列の変更通知を受け取る
    @ObservedObject var viewModel = MessageListViewModel()
    @State private var isReachable = "NO"
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // iPhone と Apple Watch が疎通できるか
                        // true の場合メッセージ送信可能
                        self.isReachable = self.viewModel.session.isReachable ? "YES": "NO"
                    }) {
                        Text("Check")
                    }
                    .padding(.leading, 16.0)
                    Spacer()
                    Text("isReachable")
                        .font(.headline)
                        .padding()
                    Text(self.isReachable)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                }
                .background(Color.init(.systemGray5))
                Button {
                    print(self.viewModel.messages)
                } label: {
                    Text("print check")
                }
                List {
//                    ForEach(self.viewModel.messages, id: \.self) { animal in
//                        MessageRow(animal: animal)
//                    }
                    ForEach(self.viewModel.messages, id: \.self) { animal in
                        Text(animal)
                            .onChange(of: self.viewModel.messages) { animals in
                                Firestore.firestore().collection("users").document(finalUID).collection("foods").addDocument(data: [
                                    "addedAt": Date(),
                                    "title": animal,
                                    "expire": animal,
                                    "verified": "false"])
                            }
                    }
                }
                .listStyle(PlainListStyle())
                Spacer()
            }
            .background(Color("bgColorTab"))
            .navigationTitle("Receiver")
        }
    }
}

struct WatchTestSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        WatchTestSwiftUI()
    }
}
