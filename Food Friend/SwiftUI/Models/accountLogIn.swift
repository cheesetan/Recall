//
//
//
//
//

import SwiftUI

struct accountLogIn: View {
    
    // MARK: - BODY
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(Color.white)
                .padding(20)
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Log In")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                Text("Tap anywhere in the box to log in to your account.")
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
    }
}

// MARK: - PREVIEW

struct accountLogIn_Previews: PreviewProvider {
    static var previews: some View {
        accountLogIn()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
