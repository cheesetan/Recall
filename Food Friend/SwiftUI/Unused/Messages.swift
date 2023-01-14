//
//  Messages.swift
//  Recall
//
//  Created by Tristan on 22/7/22.
//

import SwiftUI
import FirebaseAuth

struct Messages: View {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingInfoView = false
    
    let chatroom: Chatroom
    @ObservedObject var viewModel = MessagesViewModel()
    @State var messageField = ""
    @State var listCount = 0
    
    @FocusState private var kbFocused: Bool
    
    @AppStorage("curRoomTitle", store: .standard) private var curRoomTitle = ""
    @AppStorage("curRoomCode", store: .standard) private var curRoomCode = ""
    @AppStorage("curRoomID", store: .standard) private var curRoomID = ""
    @AppStorage("curRoomUsers", store: .standard) private var curRoomUsers = ""
    @AppStorage("curRoomSecret", store: .standard) private var curRoomSecret = ""
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("hideCustomTabBar", store: .standard) private var hideCustomTabBar = false
    
    init(chatroom: Chatroom) {
        self.chatroom = chatroom
        viewModel.fetchData(docId: chatroom.id)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                //List {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { value in
                        LazyVStack {
                            Divider()
                                .padding(.bottom, 5)
                            if prefinalUID == finalUID {
                                ForEach(viewModel.messages) { message in
                                    if message.msg != "true" {
                                        HStack {
                                            VStack {
                                                Text("\(message.name) has changed the chat's name to: \(message.content)")
                                                    .foregroundColor(Color.gray)
                                                    .font(.footnote)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.center)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding(.horizontal, 10)
                                            }
                                            .padding(5)
                                        }
                                    } else if message.senderID == Auth.auth().currentUser!.uid {
                                        HStack {
                                            Spacer(minLength: UIScreen.main.bounds.size.width / 4)
                                            VStack {
                                                HStack {
                                                    Spacer()
                                                    Text("\(message.content)")
                                                        .padding()
                                                        .background(Color("blue2"))
                                                        .cornerRadius(25)
                                                        .multilineTextAlignment(.trailing)
                                                        .contextMenu {
                                                            Button("Copy") {
                                                                
                                                            }
                                                            Divider()
                                                            Button(role: .destructive) {
                                                                
                                                            } label: {
                                                                Text("Delete Message")
                                                            }
                                                        }
                                                }
                                            }
                                            .padding(2)
                                        }
                                    } else {
                                        HStack {
                                            VStack {
                                                Text("\(message.name)")
                                                    .font(.footnote)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                HStack {
                                                    Text("\(message.content)")
                                                        .padding()
                                                        .background(Color("green2"))
                                                        .cornerRadius(25)
                                                        .multilineTextAlignment(.leading)
                                                        .contextMenu() {
                                                            Button("Copy") {
                                                                
                                                            }
                                                            Divider()
                                                            Button(role: .destructive) {
                                                                
                                                            } label: {
                                                                Text("Delete Message")
                                                            }
                                                        }
                                                    Spacer()
                                                }
                                            }
                                            .padding(2)
                                            Spacer(minLength: UIScreen.main.bounds.size.width / 4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                    if curRoomSecret == "true" {
                        viewModel.SSSend(messageContent: "curRoomSecretScreenShot", docId: curRoomID, displayName: finalUsername)
                    }
                }
                //}
                .backgroundStyle(.green)
                .cornerRadius(10)
                Group {
                    Divider()
                    HStack {
                        Spacer()
                        /*
                         Image(systemName: "keyboard.chevron.compact.down")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 25, height: 25)
                         .padding(.bottom, 10)
                         .onTapGesture {
                         kbFocused = false
                         }
                         Spacer()
                         Spacer()
                         */
                        TextField("Enter message...", text: $messageField)
                            .padding(10)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .padding(.bottom)
                            .multilineTextAlignment(.leading)
                            .focused($kbFocused)
                        if messageField == "" || messageField == " " {
                            Spacer()
                        }
                        if messageField != "" && messageField != " " {
                            Button(action: {
                                if prefinalUID != finalUID {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    generator.impactOccurred(intensity: 0.7)
                                    if messageField != "" || messageField != " " {
                                        viewModel.sendMessage(messageContent: messageField, docId: chatroom.id, displayName: finalUsername)
                                    }
                                }
                                messageField = ""
                            }, label: {
                                Image(systemName: "arrow.up.message.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 17, height: 17)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .cornerRadius(100)
                            })
                            .cornerRadius(7)
                            .padding(.bottom)
                            Spacer()
                        }
                    }
                    .padding(.top, 10)
                }
                .backgroundStyle(.background)
            }
            .padding(.horizontal, 20)
            .listRowBackground(Color("bgColorTab2"))
            .background(Color("bgColorTab"))
            .navigationBarTitle(chatroom.title, displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        isShowingInfoView = true
                        generator.impactOccurred(intensity: 0.7)
                    }) {
                        Image(systemName: "info.circle")
                    })
            .sheet(isPresented: $isShowingInfoView) {
                chatInfoSwiftUI()
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    })
        }
        .onAppear {
            
            //hideCustomTabBar = true
            
            curRoomTitle = chatroom.title
            curRoomCode = String(chatroom.joinCode)
            curRoomID = chatroom.id
            curRoomSecret = chatroom.isSecret
            if prefinalUID != finalUID {
                print("amogeese")
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onDisappear {
            
            //hideCustomTabBar = false
            
            curRoomTitle = ""
            curRoomCode = ""
            curRoomID = ""
            curRoomUsers = ""
            curRoomSecret = ""
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

struct Messages_Previews: PreviewProvider {
    static var previews: some View {
        Messages(chatroom: Chatroom(id: "10101", title: "PLACEHOLDER TEXT", joinCode: 0, isSecret: "true"))
    }
}
