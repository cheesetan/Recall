//
//  messageView.swift
//  Food Friend
//
//  Created by Tristan on 31/10/22.
//

import SwiftUI

struct messageView: View {
    
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
                                if message.isUser == "true" {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            blueBubble(content: message.content, displayName: message.displayName)
                                                .padding(.trailing)
                                                .padding(.leading, 50)
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
                                if textfield != "" && textfield != " " && textfield != "\n" {
                                    viewModel.sendMessage(isUser: isCompLogged ? "false" : "true", displayName: isCompLogged ? "Companion" : "User", content: textfield)
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
//            .toolbar(.hidden, for: .tabBar)
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("bgColorTab"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct blueBubble: View {
    
    let content: String
    let displayName: String
    
    var body: some View {
        VStack {
            Text(content)
                .foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(20)
        }
    }
}

struct greenBubble: View {
    
    let content: String
    let displayName: String
    
    var body: some View {
        VStack {
            Text(content)
                .foregroundColor(.white)
                .padding()
                .background(.green)
                .cornerRadius(20)
        }
    }
}

struct messageView_Previews: PreviewProvider {
    static var previews: some View {
        blueBubble(content: "helhfdsfhdjkahfsdjkahfdskjfhdsjkfhdsklfsdjkhkjlhkjhjkhkjhkjhkjlhkhkjhkjllo", displayName: "User")
    }
}
