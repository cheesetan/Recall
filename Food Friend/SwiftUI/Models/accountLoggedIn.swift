//
//  SwiftUIView.swift
//  Recall
//
//  Created by Tristan on 13/7/22.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct accountLoggedIn: View {
    
    var loadedImageURL: String
    var loadedSuccess: Bool
    
    @State private var CurloadedImageURL = "https://firebasestorage.googleapis.com/v0/b/food-friend-sst.appspot.com/o/139369246-vector-empty-transparent-background-vector-transparency-grid-seamless-pattern-.jpg?alt=media&token=86a053bf-3b4b-4c8a-ae06-835a553363b0"
    @State private var CurloadedSuccess = false
    //@AppStorage("CurloadedSuccess", store: .standard) private var CurloadedSuccess = false

    
    @State private var image = UIImage()
    @State private var showSheet = false
    @State private var showSheet2 = false
    @State private var showSheet3 = false
    @State private var showSheet4 = false
    
    @State private var actList = 0
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    
    // MARK: - BODY
    
    var body: some View {
        VStack {
            if actList == 0 {
                HStack {
                    VStack {
                        ZStack {
                            ProgressView()
                            Image(systemName: "")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70, alignment: .center)
                                .foregroundColor(Color.white)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 17, height: 17)))
                        }
                        Text("Edit")
                            .padding(.top, 7)
                            .font(.caption)
                            .foregroundColor(Color.blue)
                    }
                    .padding(.trailing, 8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(finalEmail)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                    }
                    Spacer()
                }
            } else if actList == 1 {
                HStack {
                    VStack {
                        ZStack {
                            Image(systemName: "person.fill")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40, alignment: .center)
                                .foregroundColor(Color.white)
                                .padding(15)
                                .background(.secondary)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        }
                        Menu("Edit") {
                            Button("Take a Picture", action: {
                                showSheet = true
                            })
                            Button("Choose from Photos", action: {
                                showSheet4 = true
                            })
                        }
                        .font(.caption)
                        .foregroundColor(Color.blue)
                    }
                    .padding(.trailing, 8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(finalUsername)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    VStack {
                        ZStack {
                            WebImage(url: URL(string: CurloadedImageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70, alignment: .center)
                                .foregroundColor(Color.white)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 17, height: 17)))
                        }
                        Menu("Edit") {
                            Button("Take a Picture", action: {
                                showSheet = true
                            })
                            Button("Choose from Photos", action: {
                                showSheet4 = true
                            })
                        }
                        .font(.caption)
                        .foregroundColor(Color.blue)
                    }
                    .padding(.trailing, 8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(finalEmail)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            actList = 0
            
            FirebaseStorageManager().loadUserPFP(userUID: finalUID) { (isSuccess, url) in
                print("loadImageFromFirebase: \(isSuccess), \(url)")
                if isSuccess {
                    print("success getting pfp url")
                    actList = 2
                    CurloadedImageURL = "\(url!)"
                } else {
                    actList = 1
                    CurloadedImageURL = ""
                }
            }
        }
        
        
        /*
        HStack {
            if CurloadedSuccess {
                VStack {
                    ZStack {
                        ProgressView()
                        /*
                        AsyncImage(url: URL(string: CurloadedImageURL), scale: 15) { image in
                            image.resizable()
                        } placeholder: {
                            Color.clear
                        }
                         */
                        Image(systemName: "")
                            .data(url: URL(string: CurloadedImageURL)!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70, alignment: .center)
                            .foregroundColor(Color.white)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 17, height: 17)))
                    }
                    Menu("Edit") {
                        Menu("Upload New Image") {
                            Button("Take a Picture", action: {
                                showSheet2 = true
                            })
                            Button("Choose from Photos", action: {
                                showSheet3 = true
                            })
                        }
                        Button("Remove Image", action: {
                            let desertRef = Storage.storage().reference().child("\(finalUID)/Profile Picture/\(finalUID).png")
                            desertRef.delete { error in
                                if let error = error {
                                    print("error while deleting image: \(error)")
                                } else {
                                    image = UIImage()
                                    CurloadedImageURL = ""
                                    CurloadedSuccess = false
                                }
                            }
                        })
                    }
                    .padding(.top, 5)
                    .font(.caption)
                    .foregroundColor(Color.blue)
                    .sheet(isPresented: $showSheet2) {
                        ImagePicker(sourceType: .camera, selectedImage: self.$image)
                            .onDisappear {
                                CurloadedSuccess = true
                                if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                    FirebaseStorageManager().uploadUserPFP(userUID: finalUID, data: data, serverFileName: "\(finalUID).png") { (isSuccess, url) in
                                        print("uploadImageData: \(isSuccess), \(url)")
                                        if isSuccess {
                                            CurloadedSuccess = true
                                            CurloadedImageURL = "\(url!)"
                                        }
                                    }
                                }
                            }
                    }
                    .sheet(isPresented: $showSheet3) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                            .onDisappear {
                                CurloadedSuccess = true
                                if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                    FirebaseStorageManager().uploadUserPFP(userUID: finalUID, data: data, serverFileName: "\(finalUID).png") { (isSuccess, url) in
                                        print("uploadImageData: \(isSuccess), \(url)")
                                        if isSuccess {
                                            CurloadedSuccess = true
                                            CurloadedImageURL = "\(url!)"
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.trailing, 8)
            } else {
                VStack {
                    Image(systemName: "person.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40, alignment: .center)
                        .foregroundColor(Color.white)
                        .padding(15)
                        .background(.secondary)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                    Menu("Edit") {
                        Button("Take a Picture", action: {
                            showSheet = true
                        })
                        Button("Choose from Photos", action: {
                            showSheet4 = true
                        })
                    }
                    .font(.caption)
                    .foregroundColor(Color.blue)
                }
                .padding(.trailing, 8)
                .sheet(isPresented: $showSheet) {
                    ImagePicker(sourceType: .camera, selectedImage: self.$image)
                        .onDisappear {
                            if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                FirebaseStorageManager().uploadUserPFP(userUID: finalUID, data: data, serverFileName: "\(finalUID).png") { (isSuccess, url) in
                                    print("uploadImageData: \(isSuccess), \(url)")
                                    if isSuccess {
                                        CurloadedSuccess = true
                                        CurloadedImageURL = "\(url!)"
                                    }
                                }
                            }
                        }
                }
                .sheet(isPresented: $showSheet4) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                        .onDisappear {
                            if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                FirebaseStorageManager().uploadUserPFP(userUID: finalUID, data: data, serverFileName: "\(finalUID).png") { (isSuccess, url) in
                                    print("uploadImageData: \(isSuccess), \(url)")
                                    if isSuccess {
                                        CurloadedSuccess = true
                                        CurloadedImageURL = "\(url!)"
                                    }
                                }
                            }
                        }
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(finalUsername)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                Text("Tap to view your account information")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13, alignment: .center)
                .foregroundColor(Color.gray)
            
        } //: HSTACK
        .padding(4)
        .onAppear {
            CurloadedSuccess = true
            FirebaseStorageManager().loadUserPFP(userUID: finalUID) { (isSuccess, url) in
                print("loadImageFromFirebase: \(isSuccess), \(url)")
                if isSuccess {
                    print("success getting pfp url")
                    CurloadedSuccess = isSuccess
                    CurloadedImageURL = "\(url!)"
                } else {
                    CurloadedSuccess = false
                    CurloadedImageURL = "https://firebasestorage.googleapis.com/v0/b/food-friend-sst.appspot.com/o/139369246-vector-empty-transparent-background-vector-transparency-grid-seamless-pattern-.jpg?alt=media&token=86a053bf-3b4b-4c8a-ae06-835a553363b0"
                }
            }
        }
        */
    }
}

// MARK: - PREVIEW

struct accountLoggedIn_Previews: PreviewProvider {
    static var previews: some View {
        accountLoggedIn(loadedImageURL: "", loadedSuccess: false)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
