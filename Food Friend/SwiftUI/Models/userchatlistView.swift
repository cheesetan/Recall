//
//  userchatlistView.swift
//  Recall
//
//  Created by Tristan on 26/7/22.
//

import SwiftUI
import Firebase

struct userchatlistView: View {
    
    var userChat: [String]
    
    @AppStorage("curRoomUsers", store: .standard) private var curRoomUsers = ""
    
    var curChatUsers2 = [Any].self
    var curChatUsers3 = 0

  
  // MARK: - BODY

  var body: some View {
      VStack {
          ForEach(0..<userChat.count, id: \.self) { item in
              Button {
                  // action when pressed on user
              } label: {
                  HStack {
                      VStack(alignment: .leading) {
                          Text(userChat[item])
                              .foregroundColor(Color.primary)
                          if item + 1 != userChat.count {
                              Divider()
                                  .padding(.vertical, 5)
                          }
                      }
                      Spacer()
                  }
                  .padding(5)
              }
          }
      }
  }
}

// MARK: - PREVIEW

struct userchatlistView_Previews: PreviewProvider {
  static var previews: some View {
      userchatlistView(userChat: ["abc", "def", "ghi"])
      .previewLayout(.sizeThatFits)
      .padding()
  }
}
