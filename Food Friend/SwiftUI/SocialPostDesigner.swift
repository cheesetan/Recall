//
//  SocialPostDesigner.swift
//  Recall
//
//  Created by Tristan on 26/8/22.
//

import SwiftUI
import FirebaseStorage
import Firebase

struct SocialPostDesigner: View {
    
    @State private var postingRn = false
    
    let foods: Foods
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    let viewModel = SocialViewModel()
    
    @State private var titleToggle = true
    @State private var expireToggle = true
    @State private var verifiedToggle = true
    @State private var verifiedDisabled = false
    @State private var imageToggle = true
    
    @State private var showSheet = false
    @State private var realloadedImageURL = ""
    @State private var loadedImageURL = ""
    @State private var image = UIImage()
    
    @State private var showingInfoView = false
    
    @State private var curact = 0
    
    @AppStorage("showingSocialPostPicker", store: .standard) private var showingSocialPostPicker = false
        
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            //ScrollView(.vertical, showsIndicators: false) {
                //ScrollViewReader { value in
                    VStack {
                        SocialPostPreview(postTitle: foods.title, postExpire: foods.expire, postVerify: verifiedToggle, postUserUsername: finalUsername, postUserUID: finalUID, postImage: imageToggle ? loadedImageURL : "Undefined", curImageDisplay: curact)
                        Spacer()
                            .background(Color("bgColorTab"))
                        Form {
                            Section(header: Text("Post's Settings")) {
                                Toggle(isOn: $titleToggle) {
                                    Text("Show Title")
                                }
                                .disabled(true)
                                Toggle(isOn: $expireToggle) {
                                    Text("Show Expiry Date")
                                }
                                .disabled(true)
                                Toggle(isOn: $verifiedToggle) {
                                    HStack {
                                        Text("Show Verified Badge")
                                        /*
                                        Button {
                                            generator.impactOccurred(intensity: 0.7)
                                            showingInfoView = true
                                        } label: {
                                            Image(systemName: "info.circle")
                                        }
                                        .sheet(isPresented: $showingInfoView) {
                                            MIVCInfoSwiftUI()
                                        }
                                         */
                                    }
                                }
                                .disabled(verifiedDisabled)
                                .onAppear {
                                    if foods.verified == "true" {
                                        verifiedToggle = true
                                        verifiedDisabled = false
                                    } else {
                                        verifiedToggle = false
                                        verifiedDisabled = true
                                    }
                                }
                                Toggle(isOn: $imageToggle) {
                                    Button {
                                        showSheet.toggle()
                                    } label: {
                                        Text("Post Image")
                                    }
                                    .disabled(!imageToggle)
                                    .sheet(isPresented: $showSheet) {
                                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                                            .onDisappear {
                                                
                                                loadedImageURL = ""
                                                curact = 0
                                                
                                                FirebaseStorageManager().loadPostImageFromFirebase(userUID: finalUID, itemUID: foods.id!) { (isSuccess, url) in
                                                    print("loadImageFromFirebase: \(isSuccess), \(url)")
                                                    if isSuccess {
                                                        let desertRef = Storage.storage().reference().child("\(finalUID)/\(foods.id!)/Post/\(foods.id!).png")
                                                        desertRef.delete { error in
                                                            if let error = error {
                                                                print("error while deleting image: \(error)")
                                                            } else {
                                                                if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                                                    FirebaseStorageManager().uploadPostImageData(userUID: finalUID, itemUID: foods.id!, data: data, serverFileName: "\(foods.id!).png") { (isSuccess, url) in
                                                                        print("uploadImageData: \(isSuccess), \(url)")
                                                                        if isSuccess {
                                                                            loadedImageURL = "\(url!)"
                                                                            reloadImage()
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                                            FirebaseStorageManager().uploadPostImageData(userUID: finalUID, itemUID: foods.id!, data: data, serverFileName: "\(foods.id!).png") { (isSuccess, url) in
                                                                print("uploadImageData: \(isSuccess), \(url)")
                                                                if isSuccess {
                                                                    loadedImageURL = "\(url!)"
                                                                    reloadImage()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                            .listRowBackground(Color("bgColorTab2"))
                        }
                        .listRowBackground(Color("bgColorTab2"))
                        .background(Color("bgColorTab"))
                        .scrollContentBackground(.hidden)
                    }
                    .navigationBarTitle("Preview", displayMode: .inline)
                    .navigationBarItems(
                        leading:
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                    )
                    .navigationBarItems(
                        trailing:
                            Button {
                                
                                postingRn = true
                                
                                generator.impactOccurred(intensity: 0.7)
                                
                                if image.pngData() == nil {
                                    
                                    viewModel.postFoods(title: foods.title, expire: foods.expire, verified: "\(verifiedToggle)", postTime: "\(Date.now.formatted(date: .long, time: .shortened))", postImageURL: "Undefined", imageInt: "Undefined", postedFoodsID: "\(foods.id!)")
                                    generator2.notificationOccurred(.success)
                                    presentationMode.wrappedValue.dismiss()
                                    showingSocialPostPicker = false
                                    postingRn = false
                                    
                                    reloadImage()
                                } else {
                                    if let data = image.pngData() { // convert your UIImage into Data object using png representation
                                        let randomInt = Int.random(in: 1..<99999999999)
                                        FirebaseStorageManager().uploadPostImageData(userUID: finalUID, itemUID: foods.id!, data: data, serverFileName: "\(foods.id!)-(\(randomInt)).png") { (isSuccess, url) in
                                            print("uploadImageData: \(isSuccess), \(url)")
                                            if isSuccess {
                                                realloadedImageURL = "\(url!)"
                                                
                                                viewModel.postFoods(title: foods.title, expire: foods.expire, verified: "\(verifiedToggle)", postTime: "\(Date.now.formatted(date: .long, time: .shortened))", postImageURL: imageToggle ? realloadedImageURL : "Undefined", imageInt: "\(randomInt)", postedFoodsID: "\(foods.id!)")
                                                generator2.notificationOccurred(.success)
                                                presentationMode.wrappedValue.dismiss()
                                                showingSocialPostPicker = false
                                                postingRn = false
                                                
                                                reloadImage()
                                            }
                                        }
                                    }
                                }
                            } label: {
                                if postingRn {
                                    HStack {
                                        Text("Posting...")
                                            .padding(.trailing, 5)
                                        ProgressView()
                                    }
                                } else {
                                    Text("Post")
                                }
                            }
                            .disabled(curact == 0)
                            .disabled(postingRn)
                    )
                //}
            //}
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
                        
            FirebaseStorageManager().loadPostImageFromFirebase(userUID: finalUID, itemUID: foods.id!) { (isSuccess, url) in
                print("loadImageFromFirebase: \(isSuccess), \(url)")
                if isSuccess {
                    let desertRef = Storage.storage().reference().child("\(finalUID)/\(foods.id!)/Post/\(foods.id!).png")
                    desertRef.delete { error in
                        if let error = error {
                            print("error while deleting image: \(error)")
                        }
                        reloadImage()
                    }
                } else {
                    reloadImage()
                }
            }
            generator.impactOccurred(intensity: 0.7)
        }
        .onDisappear {
            FirebaseStorageManager().loadPostImageFromFirebase(userUID: finalUID, itemUID: foods.id!) { (isSuccess, url) in
                print("loadImageFromFirebase: \(isSuccess), \(url)")
                if isSuccess {
                    let desertRef = Storage.storage().reference().child("\(finalUID)/\(foods.id!)/Post/\(foods.id!).png")
                    desertRef.delete { error in
                        if let error = error {
                            print("error while deleting image: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func reloadImage() {
        FirebaseStorageManager().loadPostImageFromFirebase(userUID: finalUID, itemUID: foods.id!) { (isSuccess, url) in
            print("loadImageFromFirebase: \(isSuccess), \(url)")
            if isSuccess {
                loadedImageURL = "\(url!)"
                
                curact = 2
            } else {
                loadedImageURL = ""
                
                curact = 1
            }
        }
    }
}

struct SocialPostDesigner_Previews: PreviewProvider {
    static var previews: some View {
        SocialPostDesigner(foods: Foods(expire: "12/04/23", title: "Bananas", verified: "true"))
    }
}
