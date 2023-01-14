//
//  commselectView.swift
//  Food Friend
//
//  Created by Tristan on 31/10/22.
//

import SwiftUI

struct commselectView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color("bgColorTab")
                    .ignoresSafeArea()
                VStack {
                    NavigationLink(destination: callView(contacts: Contacts(name: "cheesetan_", number: "83895233"))) {
                        commselectbox(commtype: "Call")
                    }
                    .padding(.vertical)
                    NavigationLink(destination: messageView(message: Message(isUser: "true", displayName: "user", content: "hahaha"))) {
                        commselectbox(commtype: "Message")
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Contact Companion")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct commselectbox: View {
    
    let commtype: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: UIScreen.main.bounds.width - 25, height: 80)
                .foregroundColor(commtype == "Call" ? .green : .blue)
            HStack {
                Image(systemName: commtype == "Call" ? "phone.fill" : "message.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                Text("\(commtype) companion(s)")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .toolbar(.visible, for: .tabBar)
    }
}

struct commselectView_Previews: PreviewProvider {
    static var previews: some View {
        commselectView()
    }
}
