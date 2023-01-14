//
//  RecallSquares.swift
//  Food Friend
//
//  Created by Tristan on 26/10/22.
//

import SwiftUI

struct RecallSquares: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color("bgColorTab"))
            .frame(width: UIScreen.main.bounds.width - 50, height: (UIScreen.main.bounds.width - 100) / 2)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 10, y: 10)
            .shadow(color: Color.white.opacity(0.2), radius: 8, x: -5, y: -5)
            .padding(.vertical)
    }
}

struct RecallSquares_Previews: PreviewProvider {
    static var previews: some View {
        RecallSquares()
    }
}
