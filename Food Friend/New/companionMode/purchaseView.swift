//
//  purchaseView.swift
//  Food Friend
//
//  Created by Tristan on 7/11/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImage
import SDWebImageSwiftUI

struct purchaseView: View {
    
    @ObservedObject var viewModel = productsVM()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var showingCart = false
    @State private var showingLiked = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: itemMoreInfoView(product: Products(id: product.id!, title: product.title, description: product.description, price: product.price, imageURL: product.imageURL))) {
                                eachItemView(id: product.id, title: product.title, description: product.description, price: product.price, imageURL: product.imageURL)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medication")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingLiked.toggle()
                    } label: {
                        Image(systemName: "heart")
                    }
                    .sheet(isPresented: $showingLiked) {
                        likedView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingCart.toggle()
                    } label: {
                        Image(systemName: "cart")
                    }
                    .sheet(isPresented: $showingCart) {
                        cartView()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct itemMoreInfoView: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    let product: Products
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var arrOfCart = String()
    @State private var arrOfLiked = String()
    
    @State private var askingApproval = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                ZStack(alignment: .bottom) {
                    VStack {
                        ZStack {
                            ProgressView()
                            WebImage(url: URL(string: product.imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 150, alignment: .center)
                                .foregroundColor(Color.primary)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(color: Color("bgColorTab").opacity(0.2), radius: 10, x: 10, y: 10)
                                .shadow(color: Color("bgColorTab").opacity(0.7), radius: 10, x: -5, y: -5)
                        }
                        .padding(.top)
                        
                        HStack {
                            Text(product.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.leading, 25)
                        
                        HStack {
                            Text(product.description)
                                .font(.body)
                                .fontWeight(.none)
                                .lineLimit(10)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.leading, 25)
                        .padding(.top, 5)
                        
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text("Cost:")
                            Spacer()
                            Text(product.price)
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Button {
                                if askingApproval == "false" {
                                    if arrOfCart.description.contains(product.id!) {
                                        generator.impactOccurred(intensity: 0.7)
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayRemove([product.id!]),
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                                generator2.notificationOccurred(.error)
                                            } else {
                                                print("Document successfully updated")
                                            }
                                        }
                                    } else {
                                        generator2.notificationOccurred(.success)
                                        presentationMode.wrappedValue.dismiss()
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayUnion([product.id!])])
                                    }
                                } else if askingApproval == "true" {
                                    generator2.notificationOccurred(.error)
                                }
                            } label: {
                                if arrOfCart.description.contains(product.id!) {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.minus")
                                        Text("Remove from Cart")
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .cornerRadius(16)
                                } else {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.plus")
                                        Text("Add to Cart")
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 100, height: 60)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .cornerRadius(16)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom)
                            
                            Button {
                                if arrOfLiked.description.contains(product.id!) {
                                    generator.impactOccurred(intensity: 0.7)
                                    Firestore.firestore().collection("users").document(finalUID).updateData([
                                        "liked": FieldValue.arrayRemove([product.id!]),
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                            generator2.notificationOccurred(.error)
                                        } else {
                                            print("Document successfully updated")
                                        }
                                    }
                                } else {
                                    generator2.notificationOccurred(.success)
                                    Firestore.firestore().collection("users").document(finalUID).updateData([
                                        "liked": FieldValue.arrayUnion([product.id!])])
                                }
                            } label: {
                                if arrOfLiked.contains(product.id!) {
                                    HStack {
                                        Image(systemName: "heart.slash.fill")
                                    }
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .clipShape(Circle())
                                } else {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                    }
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .clipShape(Circle())
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle(product.title)
            .navigationBarTitleDisplayMode(.inline)
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
            .onAppear {
                db.collection("users").document(finalUID).addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    askingApproval = document.get("seekApproval") as! String
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
                        
                        let secarrOfLiked = document.get("liked") as! [String]
                        arrOfLiked = secarrOfLiked.description
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
                        
                        let secarrOfCart = document.get("cart") as! [String]
                        arrOfCart = secarrOfCart.description
                    }
            }
        }
        .navigationBarHidden(true)
    }
}

struct eachItemView: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    let id: String?
    let title: String
    let description: String
    let price: String
    let imageURL: String
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var askingApproval = ""
    @State private var arrOfLiked = String()
    @State private var arrOfCart = String()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: UIScreen.main.bounds.width - 25, height: UIScreen.main.bounds.width - 15)
                .foregroundColor(Color("bgColorTab2"))
                .overlay (
                    VStack {
                        ZStack {
                            ProgressView()
                            WebImage(url: URL(string: imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.width - 150, alignment: .center)
                                .foregroundColor(Color.primary)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(color: Color("bgColorTab").opacity(0.2), radius: 10, x: 10, y: 10)
                                .shadow(color: Color("bgColorTab").opacity(0.7), radius: 10, x: -5, y: -5)
                        }
                        HStack {
                            VStack {
                                HStack {
                                    Text(title)
                                        .foregroundColor(.primary)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .padding(.top)
                                    Spacer()
                                }
                                HStack {
                                    Text(price)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    Spacer()
                                }
                            }
                            .padding(.leading, 30)
                            
                            Spacer()
                            
                            Button {
                                if arrOfLiked.description.contains(id!) {
                                    generator.impactOccurred(intensity: 0.7)
                                    Firestore.firestore().collection("users").document(finalUID).updateData([
                                        "liked": FieldValue.arrayRemove([id!]),
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                            generator2.notificationOccurred(.error)
                                        } else {
                                            print("Document successfully updated")
                                        }
                                    }
                                } else {
                                    generator2.notificationOccurred(.success)
                                    
                                    Firestore.firestore().collection("users").document(finalUID).updateData([
                                        "liked": FieldValue.arrayUnion([id!])])
                                }
                            } label: {
                                if arrOfLiked.contains(id!) {
                                    HStack {
                                        Image(systemName: "heart.slash.fill")
                                    }
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .clipShape(Circle())
                                } else {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                    }
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .clipShape(Circle())
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 0)
                            .padding(.top, 15)
                            
                            Button {
                                if askingApproval == "false" {
                                    if arrOfCart.description.contains(id!) {
                                        generator.impactOccurred(intensity: 0.7)
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayRemove([id!]),
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                                generator2.notificationOccurred(.error)
                                            } else {
                                                print("Document successfully updated")
                                            }
                                        }
                                    } else {
                                        generator2.notificationOccurred(.success)
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayUnion([id!])])
                                    }
                                } else if askingApproval == "true" {
                                    generator2.notificationOccurred(.error)
                                }
                            } label: {
                                if arrOfCart.description.contains(id!) {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.minus")
                                    }
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .clipShape(Circle())
                                } else {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.plus")
                                    }
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .clipShape(Circle())
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 30)
                            .padding(.top, 15)
                        }
                    }
                    ,alignment: .center
                )
        }
        .onAppear {
            db.collection("users").document(finalUID).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                askingApproval = document.get("seekApproval") as! String
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
                    
                    let secarrOfLiked = document.get("liked") as! [String]
                    arrOfLiked = secarrOfLiked.description
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
                    
                    let secarrOfCart = document.get("cart") as! [String]
                    arrOfCart = secarrOfCart.description
                }
        }
    }
}

struct itemMoreInfoView2: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    let id: String
    
    @State private var itemName = ""
    @State private var itemDesc = ""
    @State private var itemPrice = ""
    @State private var imageURL = ""
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var askingApproval = ""
    @State private var arrOfLiked = String()
    @State private var arrOfCart = String()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                ZStack(alignment: .bottom) {
                    VStack {
                        ZStack {
                            ProgressView()
                            WebImage(url: URL(string: imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 150, alignment: .center)
                                .foregroundColor(Color.primary)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(color: Color("bgColorTab").opacity(0.2), radius: 10, x: 10, y: 10)
                                .shadow(color: Color("bgColorTab").opacity(0.7), radius: 10, x: -5, y: -5)
                        }
                        .padding(.top)
                        
                        HStack {
                            Text(itemName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.leading, 25)
                        
                        HStack {
                            Text(itemDesc)
                                .font(.body)
                                .fontWeight(.none)
                                .lineLimit(0)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.leading, 25)
                        
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text("Cost:")
                            Spacer()
                            Text(itemPrice)
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Button {
                                if askingApproval == "false" {
                                    if arrOfCart.description.contains(id) {
                                        generator.impactOccurred(intensity: 0.7)
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayRemove([id]),
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                                generator2.notificationOccurred(.error)
                                            } else {
                                                print("Document successfully updated")
                                            }
                                        }
                                    } else {
                                        generator2.notificationOccurred(.success)
                                        presentationMode.wrappedValue.dismiss()
                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                            "cart": FieldValue.arrayUnion([id])])
                                    }
                                } else if askingApproval == "true" {
                                    generator2.notificationOccurred(.error)
                                }
                            } label: {
                                if arrOfCart.description.contains(id) {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.minus")
                                        Text("Remove from Cart")
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .cornerRadius(16)
                                } else {
                                    HStack {
                                        Image(systemName: "cart.fill.badge.plus")
                                        Text("Add to Cart")
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .cornerRadius(16)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom)
                            
                            /*
                            Button {
                                generator2.notificationOccurred(.success)
                                
                                Firestore.firestore().collection("users").document(finalUID).updateData([
                                    "liked": FieldValue.arrayUnion([product.id!])])
                            } label: {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .frame(width: 60, height: 60)
                                }
                                .background(.red)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.title)
                                .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom)
                             */
                        }
                    }
                }
            }
            .navigationTitle(itemName)
            .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            Firestore.firestore().collection("products").document(id).getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        print("data", data)
                        itemName = data["title"] as? String ?? ""
                        itemDesc = data["description"] as? String ?? ""
                        itemPrice = data["price"] as? String ?? ""
                        imageURL = data["imageURL"] as? String ?? ""
                    }
                }
                
            }
            db.collection("users").document(finalUID).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                askingApproval = document.get("seekApproval") as! String
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
                    
                    let secarrOfLiked = document.get("liked") as! [String]
                    arrOfLiked = secarrOfLiked.description
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
                    
                    let secarrOfCart = document.get("cart") as! [String]
                    arrOfCart = secarrOfCart.description
                }
        }
        .navigationBarHidden(true)
    }
}


struct likedView: View {
    
    @State private var arrOfCart = Array<Any>()
    @State private var arrOfCartCount = Int()
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    List {
                        ForEach(0..<arrOfCartCount, id: \.self) { value in
                            NavigationLink(destination: itemMoreInfoView2(id: "\(arrOfCart[value])")) {
                                itemCartView(itemUID: "\(arrOfCart[value])")
                                    .swipeActions() {
                                        Button(role: .destructive) {
                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                "liked": FieldValue.arrayRemove([arrOfCart[value]]),
                                            ]) { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    print("Document successfully updated")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "heart.slash.fill")
                                        }
                                    }
                            }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    .background(Color("bgColorTab"))
                    .listStyle(InsetGroupedListStyle())
                    .listRowBackground(Color("bgColorTab2"))
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Your Likes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            let docRef = Firestore.firestore().collection("users").document(finalUID)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let tempArr = document.get("liked") as! [Any]
                    arrOfCartCount = tempArr.count
                    arrOfCart = Array(tempArr)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}


struct cartView: View {
    
    @State private var arrOfCart = Array<Any>()
    @State private var arrOfCartCount = Int()
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var askingApproval = ""
    @State private var arrOfLiked = String()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    List {
                        ForEach(0..<arrOfCartCount, id: \.self) { value in
                            itemCartView(itemUID: "\(arrOfCart[value])")
                                .swipeActions() {
                                    if askingApproval == "false" {
                                        Button(role: .destructive) {
                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                "cart": FieldValue.arrayRemove([arrOfCart[value]]),
                                            ]) { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    print("Document successfully updated")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "minus.circle")
                                        }
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button(role: .destructive) {
                                        if arrOfLiked.description.contains(arrOfCart[value] as! String) {
                                            generator.impactOccurred(intensity: 0.7)
                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                "liked": FieldValue.arrayRemove([arrOfCart[value]]),
                                            ]) { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                    generator2.notificationOccurred(.error)
                                                } else {
                                                    print("Document successfully updated")
                                                }
                                            }
                                        } else {
                                            generator2.notificationOccurred(.success)
                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                "liked": FieldValue.arrayUnion([arrOfCart[value]])])
                                        }
                                    } label: {
                                        if arrOfLiked.description.contains(arrOfCart[value] as! String) {
                                            Image(systemName: "heart.slash.fill")
                                        } else {
                                            Image(systemName: "heart.fill")
                                        }
                                    }
                                }
                        }
                        .listRowBackground(Color("bgColorTab2"))
                    }
                    .background(Color("bgColorTab"))
                    .listStyle(InsetGroupedListStyle())
                    .listRowBackground(Color("bgColorTab2"))
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Your Cart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    VStack {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                        } label: {
                            HStack {
                                Image(systemName: "cart.fill.badge.questionmark")
                                Text("Ask for Approval")
                            }
                            .frame(width: UIScreen.main.bounds.width - 25, height: 55)
                            .background(.blue)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom)
                        
                        /*
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            
                            if askingApproval == "false" {
                                generator2.notificationOccurred(.success)
                                let washingtonRef = Firestore.firestore().collection("users").document("\(finalUID)")

                                // Set the "capital" field of the city 'DC'
                                washingtonRef.updateData([
                                    "seekApproval": "true"
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            } else if askingApproval == "true" {
                                generator.impactOccurred(intensity: 0.7)
                                let washingtonRef = Firestore.firestore().collection("users").document("\(finalUID)")

                                // Set the "capital" field of the city 'DC'
                                washingtonRef.updateData([
                                    "seekApproval": "false"
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            }
                        } label: {
                            if askingApproval == "false" {
                                HStack {
                                    Image(systemName: "cart.fill.badge.questionmark")
                                    Text("Ask for Approval")
                                }
                                .frame(width: UIScreen.main.bounds.width - 25, height: 55)
                                .background(.blue)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.subheadline)
                                .cornerRadius(16)
                            } else if askingApproval == "true" {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Cancel Ask for Approval")
                                }
                                .frame(width: UIScreen.main.bounds.width - 25, height: 55)
                                .background(.red)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.subheadline)
                                .cornerRadius(16)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom)
                        */
                    }
                }
            }
        }
        .onAppear {
            
            Firestore.firestore().collection("users").document(finalUID).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                askingApproval = document.get("seekApproval") as! String
            }
            
            let docRef = Firestore.firestore().collection("users").document(finalUID)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let tempArr = document.get("cart") as! [Any]
                    arrOfCartCount = tempArr.count
                    arrOfCart = Array(tempArr)
                } else {
                    print("Document does not exist")
                }
            }
            
            Firestore.firestore().collection("users").document("\(finalUID)")
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let secarrOfLiked = document.get("liked") as! [String]
                    arrOfLiked = secarrOfLiked.description
                }
        }
    }
}

struct itemCartView: View {
    
    let itemUID: String
    
    @State private var itemName = ""
    @State private var itemDesc = ""
    @State private var itemPrice = ""
    @State private var imageURL = ""
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: imageURL))
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .cornerRadius(10)
            VStack {
                HStack {
                    Text(itemName)
                        .fontWeight(.semibold)
                        .font(.title2)
                        .lineLimit(1)
                    Spacer()
                }
                
                HStack {
                    Text(itemDesc)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                }
            }
            .padding(.leading)
            
            Spacer()
            
            VStack {
                Text(itemPrice)
                    .font(.title3)
                    .padding(.trailing, 5)
            }
        }
        .padding(.vertical, 5)
        .onAppear {
            Firestore.firestore().collection("products").document(itemUID).getDocument { (document, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        print("data", data)
                        itemName = data["title"] as? String ?? ""
                        itemDesc = data["description"] as? String ?? ""
                        itemPrice = data["price"] as? String ?? ""
                        imageURL = data["imageURL"] as? String ?? ""
                    }
                }
                
            }
        }
    }
}

struct purchaseView_Previews: PreviewProvider {
    static var previews: some View {
        itemMoreInfoView(product: Products(title: "Bananas", description: "This is a yellow banana", price: "$24", imageURL: "https://firebasestorage.googleapis.com/v0/b/project-dementia-702bf.appspot.com/o/download%20(1).jpeg?alt=media&token=abf1b2ac-93fe-4146-98ce-2d42b18f5d5a"))
    }
}
