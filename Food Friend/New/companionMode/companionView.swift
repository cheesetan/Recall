//
//  companionView.swift
//  Recall
//
//  Created by Tristan on 26/10/22.
//

import SwiftUI
import CodeScanner
import Firebase
import FirebaseAuth


struct companionView: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var showingSignOutAlert = false
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("companionpremiumMode", store: .standard) private var companionpremiumMode = false
    
    @AppStorage("autoDeleteRecalls", store: .standard) private var autoDeleteRecalls = true
    
    @State private var selectedView = 1
    
    var body: some View {
        if isCompLogged {
            VStack {
                TabView(selection: $selectedView) {
                    companionListView(foods: Foods(description: "corn", title: "corn", due: "duedate", dueTime: Date()))
                        .tabItem {
                            Label("Recalls", systemImage: "list.bullet.clipboard.fill")
                        }
                        .tag(1)
                    CompanionKSMapView()
                        .tabItem {
                            Label("Location", systemImage: "map.fill")
                        }
                        .tag(2)
                    if companionpremiumMode {
                        companionMessageView(message: Message(isUser: "true", displayName: "user", content: "hahaha"))
                            .tabItem {
                                Label("Message", systemImage: "message.fill")
                            }
                            .tag(3)
                        purchaseView()
                            .tabItem {
                                Label("Medication", systemImage: "pills.fill")
                                
                            }
                            .tag(4)
                    }
                    companionSettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(5)
                }
                .onAppear {
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
                            if document.get("premium") as! String == "true" {
                                companionpremiumMode = true
                            } else {
                                companionpremiumMode = false
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
                            if document.get("autodelete") as! String == "true" {
                                autoDeleteRecalls = true
                            } else {
                                autoDeleteRecalls = false
                            }
                        }
                }
            }
        } else {
            companionEnterView()
        }
    }
}

struct companionEnterView: View {
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var codefield = ""
    @State private var showingQRScanner = false
    
    @State private var showing3AccountAlert = false
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("companionmode", store: .standard) var companionmode = false
        
    var body: some View {
        NavigationStack {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack {
                        Text("Scan the Connect Code of the account you are trying to connect to or enter the code manually")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.bottom)
                        Text("You can find the Connect Code and digit code by going to Settings in the tab bar and pressing \(Image(systemName: "qrcode.viewfinder")) in the top left hand corner")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.bottom)
                    }
                    .padding(.horizontal)
                    TextField("Enter code...", text: $codefield)
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(10)
                        .multilineTextAlignment(.leading)
                        .frame(width: UIScreen.main.bounds.width - 25)
                        .keyboardType(.numberPad)
                    HStack {
                        Button {
                            Firestore.firestore().collection("users").whereField("connectCode", isEqualTo: codefield).getDocuments() { (snapshot, error) in
                                if let error = error {
                                    print("error getting documents! \(error)")
                                    generator2.notificationOccurred(.error)
                                } else {
                                    for document in snapshot!.documents {
                                        db.collection("users").document(document.documentID).getDocument { (document, error) in
                                            guard error == nil else {
                                                print("error", error ?? "")
                                                return
                                            }
                                            
                                            if let document = document, document.exists {
                                                let data = document.data()
                                                if let data = data {
                                                    print("data", data)
                                                    
                                                    if data["premium"] as? String ?? "" == "true" {
                                                        
                                                        finalUID = data["UID"] as? String ?? ""
                                                        finalEmail = data["email"] as? String ?? ""
                                                        finalPassword = data["password"] as? String ?? ""
                                                        isCompLogged = true
                                                        
                                                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                                "companions-uuid": FieldValue.arrayUnion([uuid])])
                                                        }
                                                        
                                                        generator2.notificationOccurred(.success)
                                                        presentationMode.wrappedValue.dismiss()
                                                    } else {
                                                        let tempUID = data["UID"] as? String ?? ""
                                                        
                                                        let docRef = Firestore.firestore().collection("users").document(tempUID)

                                                        docRef.getDocument { (document, error) in
                                                            if let document = document, document.exists {
                                                                guard let data = document.data() else {
                                                                    print("Document data was empty.")
                                                                    return
                                                                }
                                                                
                                                                let tempArr = document.get("companions-uuid") as! [Any]
                                                                
                                                                print(tempArr.count)
                                                                
                                                                if tempArr.count > 2 {
                                                                    generator2.notificationOccurred(.error)
                                                                    showing3AccountAlert = true
                                                                    
                                                                    presentationMode.wrappedValue.dismiss()
                                                                } else {
                                                                    finalUID = data["UID"] as? String ?? ""
                                                                    finalEmail = data["email"] as? String ?? ""
                                                                    finalPassword = data["password"] as? String ?? ""
                                                                    isCompLogged = true
                                                                    
                                                                    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                                                        Firestore.firestore().collection("users").document(finalUID).updateData([
                                                                            "companions-uuid": FieldValue.arrayUnion([uuid])])
                                                                    }
                                                                    
                                                                    generator2.notificationOccurred(.success)
                                                                    presentationMode.wrappedValue.dismiss()
                                                                }
                                                                
                                                            } else {
                                                                print("Document does not exist")
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("Connect")
                                .bold()
                                .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.vertical, 15)
                        }
                        .alert("Limit Reached", isPresented: $showing3AccountAlert, actions: {
                            Button("Ok", role: .none, action: {
                                
                            })
                        }, message: {
                            Text("Only 3 companions can connect to a user's account at once. Disconnect other companion devices or upgrade the user's account to Recall Premium to remove this limit.")
                        })
                        
                        Button {
                            showingQRScanner.toggle()
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .bold()
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(100)
                                .padding(.vertical, 15)
                        }
                        .fullScreenCover(isPresented: $showingQRScanner) {
                            connectqrcode()
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        companionmode.toggle()
                    } label: {
                        Text("Switch to User Mode")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Connect Account")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct connectqrcode: View {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    @State private var isTorchOn = false
    
    @State private var showingAddToListView = false
    @State private var isDateTextFieldDisabled = true
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - User Input
    @State private var titleInput = ""
    @State private var expireInput = Date()
    @State private var expireInputConverted = ""
    @State private var placeholderInput = ""
    
    // MARK: - QR Code Generation
    @State private var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @AppStorage("selectedView", store: .standard) private var selectedView = 1
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @State private var foodTitleLabel = ""
    @State private var foodExpireLabel = ""
    
    @State private var activeTabIndex = 0
    
    @State private var showing3AccountAlert = false
    
//    @Binding var showing3AccountAlert: Bool
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationView {
            VStack {
                CodeScannerView(codeTypes: [.aztec], scanMode: .oncePerCode, simulatedData: "reCallApproved87654321", shouldVibrateOnSuccess: false, isTorchOn: isTorchOn, completion: handleScanResult)
                    .alert("Limit Reached", isPresented: $showing3AccountAlert, actions: {
                        Button("Ok", role: .none, action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    }, message: {
                        Text("Only 3 companions can connect to a user's account at once. Disconnect other companion devices or upgrade the user's account to Recall Premium to remove this limit.")
                    })
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Connect Code Scanner", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        isTorchOn.toggle()
                    } label: {
                        if isTorchOn {
                            Image(systemName: "flashlight.on.fill")
                        } else {
                            Image(systemName: "flashlight.off.fill")
                        }
                    }
            )
            .navigationBarItems(
                trailing:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
            )
        }
    }
    
    func handleScanResult(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let qrValue = result.string
            print(result)
            print(qrValue)
            if qrValue.contains("reCallApproved") {
                let qrValueNew = qrValue.replacingOccurrences(of: "reCallApproved", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                Firestore.firestore().collection("users").whereField("connectCode", isEqualTo: qrValueNew).getDocuments() { (snapshot, error) in
                    if let error = error {
                        print("error getting documents! \(error)")
                        generator2.notificationOccurred(.error)
                    } else {
                        for document in snapshot!.documents {
                            db.collection("users").document(document.documentID).getDocument { (document, error) in
                                guard error == nil else {
                                    print("error", error ?? "")
                                    return
                                }
                                
                                if let document = document, document.exists {
                                    let data = document.data()
                                    if let data = data {
                                        print("data", data)
                                        
                                        if data["premium"] as? String ?? "" == "true" {
                                            
                                            finalUID = data["UID"] as? String ?? ""
                                            finalEmail = data["email"] as? String ?? ""
                                            finalPassword = data["password"] as? String ?? ""
                                            isCompLogged = true
                                            
                                            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                                Firestore.firestore().collection("users").document(finalUID).updateData([
                                                    "companions-uuid": FieldValue.arrayUnion([uuid])])
                                            }
                                            
                                            generator2.notificationOccurred(.success)
                                            presentationMode.wrappedValue.dismiss()
                                        } else {
                                            let tempUID = data["UID"] as? String ?? ""
                                            
                                            let docRef = Firestore.firestore().collection("users").document(tempUID)

                                            docRef.getDocument { (document, error) in
                                                if let document = document, document.exists {
                                                    guard let data = document.data() else {
                                                        print("Document data was empty.")
                                                        return
                                                    }
                                                    
                                                    let tempArr = document.get("companions-uuid") as! [Any]
                                                    
                                                    print(tempArr.count)
                                                    
                                                    if tempArr.count > 2 {
                                                        generator2.notificationOccurred(.error)
                                                        showing3AccountAlert = true
                                                    } else {
                                                        finalUID = data["UID"] as? String ?? ""
                                                        finalEmail = data["email"] as? String ?? ""
                                                        finalPassword = data["password"] as? String ?? ""
                                                        isCompLogged = true
                                                        
                                                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                                            Firestore.firestore().collection("users").document(finalUID).updateData([
                                                                "companions-uuid": FieldValue.arrayUnion([uuid])])
                                                        }
                                                        
                                                        generator2.notificationOccurred(.success)
                                                        presentationMode.wrappedValue.dismiss()
                                                    }
                                                    
                                                } else {
                                                    print("Document does not exist")
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            } else {
                generator2.notificationOccurred(.error)
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct companionView_Previews: PreviewProvider {
    static var previews: some View {
        companionView()
    }
}
