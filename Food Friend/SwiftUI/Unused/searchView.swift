//
//  searchView.swift
//  Recall
//
//  Created by Tristan on 28/9/22.
//

import SwiftUI

struct searchView: View {
    
    let posts: Posts
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @ObservedObject var viewModel = SocialViewModel()
    
    @State private var searchField = ""
    @AppStorage("showingSearchView", store: .standard) private var showingSearchView = false
    
    init(posts: Posts) {
        self.posts = posts
        viewModel.fetchData()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(height: 40)
                        .cornerRadius(13)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    TextField("Search", text: $searchField)
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                    if searchField != "" {
                        Button {
                            searchField = ""
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                .padding(.horizontal)
                if searchField.isEmpty {
                    HStack {
                        Text("Type something into the search field!")
                        Image(systemName: "arrow.turn.right.up")
                    }
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .font(.callout)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { value in
                            VStack {
                                ForEach(viewModel.posts) { post in
                                    if post.title.localizedCaseInsensitiveContains(searchField) {
                                        SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: post.randomInt, postedFoodsID: "\(post.postedFoodsID)")
                                            .padding(.top)
                                    }
                                }
                                .gesture(DragGesture()
                                    .onChanged({ _ in
                                        UIApplication.shared.dismissKeyboard()
                                    })
                                )
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color("bgColorTab"))
            .onAppear {
                viewModel.fetchData()
                print(viewModel.posts)
            }
            .navigationTitle("Search Posts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                        showingSearchView = false
                    } label: {
                        Image(systemName: "chevron.left")
                    }
            )
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct searchView_Previews: PreviewProvider {
    static var previews: some View {
        searchView(posts: Posts(title: "Bananas", expire: "12/04/2023", verified: "true", user: "cheesetan+", userID: "abc", postTime: "25 August 2022 at 5:00 PM", postImageURL: "square.fill", randomInt: "0", postedFoodsID: "abc"))
    }
}
