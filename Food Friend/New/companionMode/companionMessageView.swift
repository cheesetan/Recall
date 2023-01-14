//
//  companionMessageView.swift
//  Food Friend
//
//  Created by Tristan on 1/11/22.
//

import SwiftUI

struct companionMessageView: View {
    
    let message: Message
    @ObservedObject var viewModel = chatMessageVM()
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var textfield = String()
    @State private var scrollCount = 0
    
    @FocusState private var isTextFieldFocused: Bool
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("finalDN", store: .standard) private var finalDN = "Companion"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            HStack {
                                Spacer()
                            }
                            ForEach(viewModel.message) { message in
                                if message.isUser == "false" {
                                    VStack {
                                        Text(message.displayName)
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing)
                                        HStack {
                                            Spacer()
                                            blueBubble(content: message.content, displayName: message.displayName)
                                                .padding(.trailing)
                                                .padding(.leading, 50)
                                                .padding(.bottom, 5)
                                        }
                                    }
                                } else {
                                    VStack {
                                        Text(message.displayName)
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading)
                                        HStack {
                                            greenBubble(content: message.content, displayName: message.displayName)
                                                .padding(.leading)
                                                .padding(.trailing, 50)
                                                .padding(.bottom, 5)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                            }
                            .padding(.bottom)
                            .id("EMPTY")
                            .onLoad {
                                proxy.scrollTo("EMPTY", anchor: .bottom)
                            }
                            .onAppear {
                                proxy.scrollTo("EMPTY", anchor: .bottom)
                            }
                            .onChange(of: scrollCount) { value in
                                proxy.scrollTo("EMPTY", anchor: .bottom)
                            }
                        }
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                    }
                    Divider()
                    HStack {
                        Spacer()
                        TextField("Enter text", text: $textfield, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 1).foregroundColor(.gray))
                            .background(Color("bgColorTab2"))
                            .cornerRadius(16)
                            .frame(width: !textfield.isEmpty ? UIScreen.main.bounds.width - 86 : UIScreen.main.bounds.width - 24, height: 100)
                            .lineLimit(3)
                            .padding(.bottom, 5)
                        if !textfield.isEmpty {
                            Spacer()
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                if textfield != "" && textfield != " " && textfield != "\n" && finalDN != "" && finalDN != " " && finalDN != "\n" {
                                    viewModel.sendMessage(isUser: isCompLogged ? "false" : "true", displayName: isCompLogged ? finalDN : "User", content: textfield)
                                    textfield = ""
                                    scrollCount += 1
                                }
                            } label: {
                                Image(systemName: "arrow.up.message.fill")
                                    .font(.title3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }
                .gesture(DragGesture()
                    .onChanged({ _ in
                        UIApplication.shared.dismissKeyboard()
                    })
                )
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("bgColorTab"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct companionMessageView_Previews: PreviewProvider {
    static var previews: some View {
        companionMessageView(message: Message(isUser: "true", displayName: "user", content: "hahaha"))
    }
}
