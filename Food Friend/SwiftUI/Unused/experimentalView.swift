//
//  experimentalView.swift
//  Recall
//
//  Created by Tristan on 30/9/22.
//

import SwiftUI

struct experimentalView: View {
    var body: some View {
        ZStack {
            Color.offWhite
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.offWhite)
                .frame(width: 300, height: 300)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
        }
        .background(Color("bgColorTab"))
        .edgesIgnoringSafeArea(.all)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

struct experimentalView_Previews: PreviewProvider {
    static var previews: some View {
        experimentalView()
    }
}
