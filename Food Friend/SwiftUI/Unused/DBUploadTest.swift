//
//  DBUploadTest.swift
//  Recall
//
//  Created by Tristan on 9/8/22.
//

import SwiftUI

struct DBUploadTest: View {
    
    @State private var finalImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            HStack {
                if finalImage != nil {
                    Image(uiImage: self.finalImage!)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        .padding(8)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .cornerRadius(50)
                        .padding(.all, 4)
                        .frame(width: 100, height: 100)
                        .background(Color.black.opacity(0.2))
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        .padding(8)
                }
                Text("Change photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(16)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        showSheet = true
                    }
                /*
                    .fullScreenCover(isPresented: $showSheet, onDismiss: loadImage) {
                        ImageMoveAndScaleSheet(croppedImage: $finalImage)
                    }
                 */
            }
        }
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        finalImage = inputImage
    }
}

struct DBUploadTest_Previews: PreviewProvider {
    static var previews: some View {
        DBUploadTest()
    }
}
