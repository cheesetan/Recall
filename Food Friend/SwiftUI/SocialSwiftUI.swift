//
//  SocialSwiftUI.swift
//  Recall
//
//  Created by Tristan on 7/8/22.
//

import SwiftUI
import Firebase

struct SocialSwiftUI: View {
    
    let dateFormatter = DateFormatter()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @State private var showFollowButton = false
        
    let posts: Posts
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @ObservedObject var viewModel = SocialViewModel()
    @State private var searchField = ""
    
    @State private var recent50Post = 0
    
    @State private var showingMapView = false
    @AppStorage("showingSocialPostPicker", store: .standard) private var showingSocialPostPicker = false
    @AppStorage("showingMessageView", store: .standard) private var showingMessageView = false
    @AppStorage("showingSearchView", store: .standard) private var showingSearchView = false
    @AppStorage("currentSocialView", store: .standard) private var currentSocialView = "Recent 100"
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("searchPostExpire", store: .standard) private var searchPostExpire = false
    
    @AppStorage("isDark", store: .standard) var isDark = false
    
    @AppStorage("hideCustomTabBar", store: .standard) private var hideCustomTabBar = false
    
    @State private var arrOfFollowing = String()
    @State private var arrOfLiked = String()
    
    init(posts: Posts) {
        //UINavigationBarAppearance().backgroundColor = UIColor(Color("bgColorTab"))
        //UINavigationBar.changeAppearance(clear: false)
        self.posts = posts
        viewModel.fetchData()
    }

    var body: some View {
        NavigationView {
            VStack {
                /*
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
                        .foregroundColor(.gray)
                        .padding(.leading, 20)
                }
                .padding(.horizontal)
                 */
                ZStack(alignment: .bottomTrailing) {
                    NavigationLink(destination: messagingSwiftUI(), isActive: $showingMessageView) {
                    }
                    NavigationLink(destination: searchView(posts: Posts(title: "Bananas", expire: "12/04/2023", verified: "true", user: "cheesetan+", userID: "abc", postTime: "25 August 2022 at 5:00 PM", postImageURL: "square.fill", randomInt: "0", postedFoodsID: "abc")), isActive: $showingSearchView) {
                    }
                    if currentSocialView == "Following" {
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollViewReader { value in
                                LazyVStack {
                                    ForEach(viewModel.posts) { post in
                                        if arrOfFollowing.contains(post.userID) {
                                            SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: "\(post.randomInt)", postedFoodsID: "\(post.postedFoodsID)")
                                                .padding(.top)
                                        }
                                    }
                                }
                                .padding(.bottom, 75)
                            }
                            //.transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                        .onAppear {
                            viewModel.fetchData()
                            print(viewModel.posts)
                            
                            db.collection("users").document("\(finalUID)")
                                .addSnapshotListener { documentSnapshot, error in
                                    guard let document = documentSnapshot else {
                                        print("Error fetching document: \(error!)")
                                        return
                                    }
                                    guard let data = document.data() else {
                                        print("Document data was empty.")
                                        return
                                    }
                                    let secarrOfFollowing = document.get("following") as! [Any]
                                    arrOfFollowing = secarrOfFollowing.description
                                }
                        }
                    } else if currentSocialView == "Liked Posts" {
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollViewReader { value in
                                LazyVStack {
                                    ForEach(viewModel.posts) { post in
                                        if arrOfLiked.contains("\(post.id)") {
                                            SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: "\(post.randomInt)", postedFoodsID: "\(post.postedFoodsID)")
                                                .padding(.top)
                                        }
                                    }
                                }
                                .padding(.bottom, 75)
                            }
                            //.transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                        .onAppear {
                            viewModel.fetchData()
                            print(viewModel.posts)
                            
                            db.collection("users").document("\(finalUID)")
                                .addSnapshotListener { documentSnapshot, error in
                                    guard let document = documentSnapshot else {
                                        print("Error fetching document: \(error!)")
                                        return
                                    }
                                    guard let data = document.data() else {
                                        print("Document data was empty.")
                                        return
                                    }
                                    let secarrOfLiked = document.get("liked") as! [Any]
                                    arrOfLiked = secarrOfLiked.description
                                    print("happy meal2: \(arrOfLiked)")
                                }
                        }
                    } else if currentSocialView == "Your Posts" {
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollViewReader { value in
                                LazyVStack {
                                    ForEach(viewModel.posts) { post in
                                        if post.userID == user!.uid {
                                            SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: "\(post.randomInt)", postedFoodsID: "\(post.postedFoodsID)")
                                                .padding(.top)
                                        }
                                    }
                                }
                                .padding(.bottom, 75)
                            }
                            //.transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                        .onAppear {
                            viewModel.fetchData()
                            print(viewModel.posts)
                        }
                    } else if currentSocialView == "Recent 100" {
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollViewReader { value in
                                LazyVStack {
                                    ForEach($viewModel.posts.wrappedValue.prefix(100)) { post in
                                            SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: "\(post.randomInt)", postedFoodsID: "\(post.postedFoodsID)")
                                                .padding(.top)
                                    }
                                }
                                .padding(.bottom, 75)
                            }
                            //.transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                        .background(.clear)
                        .onAppear {
                            viewModel.fetchData()
                            print(viewModel.posts)
                        }
                    } else if currentSocialView == "Search Posts" {
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollViewReader { value in
                                LazyVStack {
                                    if searchField.isEmpty {
                                        HStack {
                                            Text("Type something into the search field!")
                                            Image(systemName: "arrow.turn.right.up")
                                        }
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                        .fontWeight(.bold)
                                        .font(.callout)
                                    } else {
                                        ForEach(viewModel.posts) { post in
                                            if dateFormatter.date(from: "\(post.expire)") ?? Date() > Date() || searchPostExpire {
                                                if post.title.localizedCaseInsensitiveContains(searchField) {
                                                    SocialPostView(postTitle: "\(post.title)", postExpire: "\(post.expire)", postVerify: "\(post.verified)", postUserUsername: "\(post.user)", postUserUID: "\(post.userID)", postImage: "\(post.postImageURL)", postDocID: "\(post.id)", postTime: "\(post.postTime)", imageInt: "\(post.randomInt)", postedFoodsID: "\(post.postedFoodsID)")
                                                        .padding(.top)
                                                }
                                            }
                                        }
                                        .gesture(DragGesture()
                                            .onChanged({ _ in
                                                UIApplication.shared.dismissKeyboard()
                                            })
                                        )
                                    }
                                }
                                .padding(.bottom, 75)
                            }
                        }
                        .onAppear {
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            viewModel.fetchData()
                            print(viewModel.posts)
                        }
                        .searchable(text: $searchField, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Post Titles")
                    }
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingSocialPostPicker = true
                    } label: {
                        ZStack {
                            Circle().fill(Color.blue)
                                .frame(width: 58, height: 58, alignment: .center)
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 70)
                    .fullScreenCover(isPresented: $showingSocialPostPicker) {
                        SocialPostPicker(foods: Foods(description: "12/04/23", title: "Apples"))
                    }
                }
            }
            .background(Color("bgColorTab"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            withAnimation {
                                generator.impactOccurred(intensity: 0.7)
                                currentSocialView = "Search Posts"
                            }
                        } label: {
                            HStack {
                                Text("Search Posts")
                                Image(systemName: "magnifyingglass")
                                Spacer()
                            }
                        }
                        Divider()
                        Button {
                            withAnimation {
                                generator.impactOccurred(intensity: 0.7)
                                currentSocialView = "Recent 100"
                            }
                        } label: {
                            HStack {
                                Text("Recent 100")
                                Image(systemName: "clock")
                                Spacer()
                            }
                        }
                        Button {
                            withAnimation {
                                generator.impactOccurred(intensity: 0.7)
                                currentSocialView = "Following"
                            }
                        } label: {
                            HStack {
                                Text("Following")
                                Image(systemName: "person.line.dotted.person.fill")
                                Spacer()
                            }
                        }
                        Button {
                            withAnimation {
                                generator.impactOccurred(intensity: 0.7)
                                currentSocialView = "Your Posts"
                            }
                        } label: {
                            HStack {
                                Text("Your Posts")
                                Image(systemName: "shared.with.you")
                                Spacer()
                            }
                        }
                        Button {
                            withAnimation {
                                generator.impactOccurred(intensity: 0.7)
                                currentSocialView = "Liked Posts"
                            }
                        } label: {
                            HStack {
                                Text("Liked Posts")
                                Image(systemName: "heart.text.square")
                                Spacer()
                            }
                        }
                    } label: {
                        HStack {
                            /*
                            Text("Social")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Text("•")
                                .font(.title)
                                .foregroundColor(.primary)
                            */
                            if currentSocialView == "Following" {
                                Text("Following")
                                //.font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: "person.line.dotted.person.fill")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            } else if currentSocialView == "Liked Posts" {
                                Text("Liked Posts")
                                //.font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: "heart.text.square")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            } else if currentSocialView == "Recent 100" {
                                Text("Recent 100")
                                //.font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: "clock")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            } else if currentSocialView == "Your Posts" {
                                Text("Your Posts")
                                //.font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: "shared.with.you")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            } else if currentSocialView == "Search Posts" {
                                Text("Search Posts")
                                //.font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            //.toolbarBackground(Color("bgColorTab"), for: .navigationBar)
            .navigationBarItems(
                trailing:
                    /*
                    Menu {
                        Button {
                            // your account menu
                        } label: {
                            HStack {
                                Text("Your Account")
                                Spacer()
                                Image(systemName: "person.circle")
                            }
                        }
                        Button {
                            showingMessageView = true
                        } label: {
                            HStack {
                                Text("Your Messages")
                                Spacer()
                                Image(systemName: "ellipsis.message")
                            }
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                     */
                Button {
                    generator.impactOccurred(intensity: 0.7)
                    showingMessageView = true
                } label: {
                    Image(systemName: "ellipsis.message")
                }
            )
            /*
            .toolbar {
                ToolbarItem(placement: .navigation){
                    TextField("Search", text: $searchField)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minWidth: 300)
                }
            }
             */
            .navigationBarItems(
                trailing:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingMapView = true
                    } label: {
                        Image(systemName: "map")
                    }
                    .fullScreenCover(isPresented: $showingMapView) {
                        ngoMapSwiftUI()
                    }
            )
            /*
            .navigationBarItems(
                trailing:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingSearchView = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
            )
             */
        }
        .onAppear {
            UINavigationBarAppearance().backgroundColor = UIColor(Color("bgColorTab"))
            UINavigationBar().isTranslucent = true
        }
        //.searchable(text: $searchField)
        .navigationBarHidden(false)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            self.viewModel.fetchData()
            showingMessageView = false
            
            if currentSocialView != "Recent 100" && currentSocialView != "Search Posts" && currentSocialView != "Following" && currentSocialView != "Liked Posts" && currentSocialView != "Your Posts" {
                currentSocialView = "Recent 100"
            }
        }
    }
}

extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
        }
        
        UINavigationBar.appearance().barTintColor = UIColor(Color("bgColorTab"))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct SocialSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        SocialSwiftUI(posts: Posts(title: "Bananas", expire: "12/04/2023", verified: "true", user: "cheesetan+", userID: "abc", postTime: "25 August 2022 at 5:00 PM", postImageURL: "square.fill", randomInt: "0", postedFoodsID: "abc"))
    }
}
