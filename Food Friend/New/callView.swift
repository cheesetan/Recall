//
//  callView.swift
//  Food Friend
//
//  Created by Tristan on 27/10/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct callView: View {
    
    let contacts: Contacts
    @ObservedObject var viewModel = contactsVM()
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var number = ""
    
    @State private var showingCallList = false
    @State private var saveView = false
    
    @State private var newContactName = ""
    
    @State private var contactAdded = false
    @State private var contactName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                        .foregroundColor(Color("bgColorTab2"))
                        .overlay(
                            Text(number)
                                .foregroundColor(.primary)
                                .font(.title3)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        )
                        .overlay(
                            Button {
                                generator.impactOccurred(intensity: 0.7)
                                number = ""
                            } label: {
                                Image(systemName: number != "" ? "xmark.circle.fill" : "")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                                .padding(.trailing, 25)
                            ,alignment: .trailing
                        )
                    
                    if contactAdded {
                        Text("\(contactName)")
                            .padding(.bottom)
                            .fontWeight(.bold)
                            .font(.body)
                    } else {
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            saveView.toggle()
                        } label: {
                            if number != "" {
                                Text("Save New Contact")
                            } else {
                                Text("Save New Contact")
                                    .foregroundColor(Color("bgColorTab"))
                            }
                        }
                        .font(.body)
                        .fontWeight(.bold)
                        .disabled(number == "")
                        .padding(.bottom)
                        .sheet(isPresented: $saveView) {
                            newContactView(contactAdded: $contactAdded, contactNamecheck: $contactName, number: number)
                                .presentationDetents([.height(190)])
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "1"
                        } label: {
                            numberView(number: 1)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "2"
                        } label: {
                            numberView(number: 2)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "3"
                        } label: {
                            numberView(number: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack {
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "4"
                        } label: {
                            numberView(number: 4)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "5"
                        } label: {
                            numberView(number: 5)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "6"
                        } label: {
                            numberView(number: 6)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack {
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "7"
                        } label: {
                            numberView(number: 7)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "8"
                        } label: {
                            numberView(number: 8)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "9"
                        } label: {
                            numberView(number: 9)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack {
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "0"
                        } label: {
                            Circle()
                                .frame(width: 95, height: 95)
                                .foregroundColor(Color("bgColorTab"))
                        }
                        .buttonStyle(.plain)
                        .disabled(true)
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            number = number + "0"
                        } label: {
                            numberView(number: 0)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            if number != "" {
                                generator.impactOccurred(intensity: 0.7)
                                number.removeLast()
                            }
                        } label: {
                            Circle()
                                .frame(width: 95, height: 95)
                                .foregroundColor(Color("bgColorTab"))
                                .overlay(
                                    Image(systemName: "delete.left.fill")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(number == "")
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack {
                        Spacer()
                        Button {
                            generator.impactOccurred(intensity: 0.7)
                            if number != "" {
                                let tel = "tel://"
                                let formattedString = tel + number
                                guard let url = URL(string: formattedString) else { return }
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Circle()
                                .frame(width: 95, height: 95)
                                .foregroundColor(.green)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    Spacer()
                }
            }
//            .toolbar(.hidden, for: .tabBar)
            .navigationTitle("Call")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        showingCallList.toggle()
                    } label: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                    }
                    .fullScreenCover(isPresented: $showingCallList) {
                        callList(contactAdded: $contactAdded, contactNamecheck: $contactName)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
        .onChange(of: number) { newValue in
            contactAdded = false
            checkContact()
        }
        .navigationBarHidden(true)
    }
    
    func checkContact() {
        viewModel.contacts.forEach { contact in
            if !contactAdded {
                if number == contact.number {
                    contactAdded = true
                    contactName = contact.name
                } else {
                    contactAdded = false
                    contactName = ""
                }
            }
        }
    }
}

struct newContactView: View {
    
    @ObservedObject var viewModel = contactsVM()
    
    @Binding var contactAdded: Bool
    @Binding var contactNamecheck: String
    
    var ref: DocumentReference? = nil
    
    let number: String
    @State private var contactName = ""
    
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
        
    var body: some View {
        VStack {
            TextField("Enter New Contact Name", text: $contactName)
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.top, 10)
            Button {
                if contactName != "" && contactName != " " {
                    
                    Firestore.firestore().collection("users").document("\(finalUID)").collection("contacts").addDocument(data: [
                        "addedAt": Date(),
                        "name": "\(contactName)",
                        "number": "\(number)"
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added")
                            
                            contactAdded = false
                            viewModel.contacts.forEach { contact in
                                print("cycled1")
                                if !contactAdded {
                                    if number == contact.number {
                                        print("cycled2")
                                        contactAdded = true
                                        contactNamecheck = contact.name
                                    } else {
                                        print("cycled3")
                                        contactAdded = false
                                        contactNamecheck = ""
                                    }
                                }
                            }
                            
                            generator2.notificationOccurred(.success)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    generator2.notificationOccurred(.error)
                }
            } label: {
                Text("Create New Contact")
                    .bold()
                    .frame(width: UIScreen.main.bounds.width - 50, height: 50)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
        .padding(.horizontal)
    }
}

struct callList: View {
    
    @ObservedObject var viewModel = contactsVM()
    
    @Binding var contactAdded: Bool
    @Binding var contactNamecheck: String
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
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
                        Section() {
                            ForEach(viewModel.contacts) { contact in
                                HStack {
                                    VStack {
                                        HStack {
                                            Text(contact.name)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(contact.number)
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        generator.impactOccurred(intensity: 0.7)
                                        
                                        let tel = "tel://"
                                        let formattedString = tel + contact.number
                                        guard let url = URL(string: formattedString) else { return }
                                        UIApplication.shared.open(url)
                                    } label: {
                                        Image(systemName: "phone.fill.arrow.up.right")
                                            .font(.title3)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.trailing)
                                }
                                .padding(.vertical)
                                .swipeActions() {
                                    Button(role: .destructive) {
                                        Firestore.firestore().collection("users").document(finalUID).collection("contacts").document(contact.id!).delete() { err in
                                            if let err = err {
                                                print("Error removing document: \(err)")
                                            } else {
                                                print("Document successfully removed!")
                                                
                                                contactAdded = false
                                                viewModel.contacts.forEach { contact2 in
                                                    print("cycled1")
                                                    if !contactAdded {
                                                        if contact.number == contact2.number {
                                                            print("cycled2")
                                                            contactAdded = true
                                                            contactNamecheck = contact2.name
                                                        } else {
                                                            print("cycled3")
                                                            contactAdded = false
                                                            contactNamecheck = ""
                                                        }
                                                    }
                                                }
                                                
                                                viewModel.fetchData()
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                }
                                
                            }
                            .onDelete(perform: delete)
                            .listRowBackground(Color("bgColorTab2"))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Saved Contacts")
                .navigationBarTitleDisplayMode(.inline)
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
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    func delete(at offsets: IndexSet) {
        generator.impactOccurred(intensity: 0.7)
    }
}

struct numberView: View {
    
    let number: Int
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Circle()
            .frame(width: 95, height: 95)
            .foregroundColor(Color("bgColorTab2"))
            .overlay(
                Text("\(number)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            )
    }
}

struct callView_Previews: PreviewProvider {
    static var previews: some View {
        callView(contacts: Contacts(name: "cheesetan_", number: "83895233"))
    }
}
