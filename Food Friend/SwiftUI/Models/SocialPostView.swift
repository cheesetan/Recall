//
//  SocialPostView.swift
//  Recall
//
//  Created by Tristan on 24/8/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseStorage

struct SocialPostView: View {
    
    let dateFormatter = DateFormatter()
    
    @State private var arrOfFollowing = String()
    @State private var arrOfLiked = String()
    
    @State private var likeButton = false
    
    let postTitle: String
    let postExpire: String
    let postVerify: String
    
    let postUserUsername: String
    let postUserUID: String
    
    let postImage: String
    let postDocID: String
    @State private var realPostDocID = String()
    let postTime: String
    
    let imageInt: String
    let postedFoodsID: String
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @State private var showFollowButton = 2
    @State private var showingMakerView = false
    
    @State private var showingDelAlert = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("isDark", store: .standard) var isDark = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(postUserUsername)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 35)
                        .padding(.bottom, 10)
                    if showFollowButton == 0 {
                        Spacer()
                        ZStack {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                Firestore.firestore().collection("users").document(finalUID).updateData([
                                    "following": FieldValue.arrayUnion([postUserUID])])
                                generator2.notificationOccurred(.success)
                                showFollowButton = 1
                            } label: {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: 75, height: 30)
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .cornerRadius(10)
                                    Text("Follow")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 8)
                            .padding(.trailing, 35)
                        }
                    } else if showFollowButton == 1 {
                        Spacer()
                        ZStack {
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                Firestore.firestore().collection("users").document(finalUID).updateData([
                                    "following": FieldValue.arrayRemove([postUserUID]),
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                        generator2.notificationOccurred(.error)
                                    } else {
                                        print("Document successfully updated")
                                        showFollowButton = 0
                                    }
                                }
                            } label: {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .cornerRadius(10)
                                    Text("Following")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 8)
                            .padding(.trailing, 35)
                        }
                    } else if showFollowButton == 2 {
                        Spacer()
                    }
                }
                if postImage != "Undefined" && postImage != "" && postImage != "square.fill" {
                    ZStack {
                        ProgressView()
                        WebImage(url: URL(string: postImage))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                            .foregroundColor(Color.primary)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            .shadow(color: Color("bgColorTab").opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color("bgColorTab").opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                } else {
                    ZStack {
                        Image(systemName: "questionmark.folder.fill")
                            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 4).foregroundColor(.gray))
                        Text("No image provided")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.top, 40)
                    }
                }
                HStack {
                    Text(postTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 7)
                        .padding(.leading, 35)
                    if postVerify == "true" {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.top, 7)
                    }
                    Spacer()
                }
                HStack {
                    
                    /*
                    if dateFormatter.date(from: "\(postExpire)") ?? Date() > Date() {
                        Text("Expires on: \(postExpire)")
                            .padding(.leading, 35)
                            .padding(.bottom, 7)
                            .font(.subheadline)
                    } else {
                        Text("Expired on: \(postExpire)")
                            .padding(.leading, 35)
                            .padding(.bottom, 7)
                            .font(.subheadline)
                    }
                     */
                    
                    Text("Expiry date: \(postExpire)")
                        .padding(.leading, 35)
                        .padding(.bottom, 7)
                        .font(.subheadline)
                     
                    Spacer()
                }
                .onAppear {
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                }
                /*
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 50, alignment: .center)
                 */
                HStack {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        likeButton.toggle()
                        
                        if likeButton {
                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                "liked": FieldValue.arrayUnion([postDocID])])
                        } else {
                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                "liked": FieldValue.arrayRemove([postDocID]),
                            ]) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                    generator2.notificationOccurred(.error)
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                        }
                    } label: {
                        if !likeButton {
                            Image(systemName: "suit.heart")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                .padding(.top, 15)
                        } else {
                            Image(systemName: "suit.heart.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                .padding(.top, 15)
                        }
                    }
                    .padding(.leading, 35)
                    .padding(.trailing)
                    if postUserUID != finalUID {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            showingMakerView = true
                        } label: {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(postUserUID == finalUID ? .gray : .blue)
                                .padding(.top, 15)
                        }
                        .padding(.trailing)
                        .disabled(postUserUID == finalUID)
                        .sheet(isPresented: $showingMakerView) {
                            chatMakerRequestView(sendToUser: postUserUsername, sendToUserUID: postUserUID)
                                .presentationDetents([.height(190)])
                        }
                    }
                    if postUserUID == finalUID {
                        Button {
                            showingDelAlert = true
                            generator2.notificationOccurred(.warning)
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                .padding(.top, 15)
                        }
                        .alert("Delete Post", isPresented: $showingDelAlert, actions: {
                            Button("Cancel", role: .cancel, action: {
                                generator.impactOccurred(intensity: 0.7)
                            })
                            Button("Delete", role: .destructive, action: {
                                
                                if postImage != "Undefined" && postImage != "" && postImage != "square.fill" {
                                    let desertRef = Storage.storage().reference().child("\(finalUID)/\(postedFoodsID)/Post/\(postedFoodsID)-(\(imageInt)).png")
                                    desertRef.delete { error in
                                        if let error = error {
                                            print("error while deleting image: \(error)")
                                        }
                                    }
                                }
                                
                                db.collection("posts").document(realPostDocID).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                        generator2.notificationOccurred(.error)
                                    } else {
                                        print("Document successfully removed!")
                                        generator2.notificationOccurred(.success)
                                    }
                                }
                                generator.impactOccurred(intensity: 0.7)
                            })
                        }, message: {
                            Text("Are you sure you want to delete this post? This action cannot be undone.")
                        })
                    }
                    Spacer()
                    VStack {
                        Text(postTime)
                            .padding(.trailing, 35)
                            .padding(.top, 15)
                            .font(.caption2)
                    }
                }
                Divider()
                    .padding(.top)
            }
            .background(Color("bgColorTab"))
        }
        .onAppear {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            realPostDocID = postDocID.replacingOccurrences(of: "Optional(\"", with: "")
            realPostDocID = realPostDocID.replacingOccurrences(of: "\")", with: "")
            DispatchQueue.main.async {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                print("happy meal")
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
                        print("happy meal: \(arrOfFollowing)")
                        if postUserUID == finalUID {
                            showFollowButton = 2
                        } else {
                            if arrOfFollowing.contains("\(postUserUID)") {
                                showFollowButton = 1
                            } else {
                                showFollowButton = 0
                            }
                        }
                    }
                
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
                        
                        if arrOfLiked.contains(postDocID) {
                            likeButton = true
                        } else {
                            likeButton = false
                        }
                    }
            }
        }
    }
}

struct SocialPostPreview: View {
    
    @State private var likeButton = false
    
    let postTitle: String
    let postExpire: String
    let postVerify: Bool
    
    let postUserUsername: String
    let postUserUID: String
    
    let postImage: String
    
    let curImageDisplay: Int
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            /*
            Color.primary
                .opacity(0.2)
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width - 25, height: UIScreen.main.bounds.height/1.8)
             */
            VStack {
                Divider()
                    .padding(.bottom)
                HStack {
                    Text(postUserUsername)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 35)
                        .padding(.bottom, 10)
                    Spacer()
                    ZStack {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                        } label: {
                            ZStack {
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .frame(width: 75, height: 30)
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .cornerRadius(10)
                                Text("Follow")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 8)
                        .padding(.trailing, 35)
                    }
                }
                //Color.blue
                if postImage != "Undefined" && postImage != "square.fill" {
                    if curImageDisplay == 0 {
                        ZStack {
                            WebImage(url: URL(string: postImage))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                                .foregroundColor(Color.primary)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            ProgressView()
                        }
                    } else if curImageDisplay == 1 {
                        ZStack {
                            Image(systemName: "")
                                .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 4).foregroundColor(.gray))
                            Text("Select an image by clicking \"Post Image\" below!")
                                .multilineTextAlignment(.center)
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                    } else {
                        ZStack {
                            ProgressView()
                            WebImage(url: URL(string: postImage))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                                .foregroundColor(Color.primary)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        }
                    }
                } else {
                    ZStack {
                        Image(systemName: "questionmark.folder.fill")
                            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 125, alignment: .center)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 4).foregroundColor(.gray))
                        Text("No image provided")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.top, 40)
                    }
                }
                HStack {
                    Text(postTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 7)
                        .padding(.leading, 35)
                    if postVerify {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.top, 7)
                    }
                    Spacer()
                }
                HStack {
                    Text("Expiry date: \(postExpire)")
                        .padding(.leading, 35)
                        .padding(.bottom, 7)
                        .font(.subheadline)
                    Spacer()
                }
                /*
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 50, alignment: .center)
                 */
                HStack {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        likeButton.toggle()
                    } label: {
                        if !likeButton {
                            Image(systemName: "suit.heart")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                //.padding(.leading, 35)
                                .padding(.top, 15)
                        } else {
                            Image(systemName: "suit.heart.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                //.padding(.leading, 35)
                                .padding(.top, 15)
                        }
                    }
                    .padding(.leading, 35)
                    .padding(.trailing)
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                    } label: {
                        Image(systemName: "paperplane")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                            //.padding(.leading, 35)
                            .padding(.top, 15)
                    }
                    Spacer()
                    VStack {
                        Text(Date.now.formatted(date: .long, time: .shortened))
                            .padding(.trailing, 35)
                            .padding(.top, 15)
                            .font(.caption2)
                    }
                }
                Divider()
                    .padding(.top)
                    .background(Color("bgColorTab"))
            }
            .background(Color("bgColorTab"))
        }
    }
}

struct SocialPostView_Previews: PreviewProvider {
    static var previews: some View {
        SocialPostView(postTitle: "Bananas", postExpire: "12/04/2023", postVerify: "true", postUserUsername: "cheesetan_", postUserUID: "abc", postImage: "square.fill", postDocID: "abc", postTime: "25 August 2022, 5:00 PM", imageInt: "0", postedFoodsID: "abc")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
