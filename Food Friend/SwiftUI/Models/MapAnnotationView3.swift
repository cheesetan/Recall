//
//  MapAnnotationView3.swift
//  Recall
//
//  Created by Tristan on 31/7/22.
//

import SwiftUI

struct MapAnnotationView3: View {
  // MARK: - PROPERTIES
  
  var location: NationalParkLocation
  @State private var animation: Double = 0.0
  
  // MARK: - BODY

  var body: some View {
    ZStack {
      Circle()
        .fill(Color.green)
        .frame(width: 28, height: 28, alignment: .center)
      
      Circle()
        .stroke(Color.green, lineWidth: 2)
        .frame(width: 26, height: 26, alignment: .center)
        .scaleEffect(1 + CGFloat(animation))
        .opacity(1 - animation)
      
      Image(location.image)
        .resizable()
        .scaledToFit()
        .frame(width: 22, height: 22, alignment: .center)
        .clipShape(Circle())
    } //: ZSTACK
    .onAppear {
      withAnimation(Animation.easeOut(duration: 2).repeatForever(autoreverses: false)) {
        animation = 1
      }
    }
  }
}

// MARK: - PREVIEW

struct MapAnnotationView3_Previews: PreviewProvider {
  static var locations: [NationalParkLocation] = Bundle.main.decode("locations.json")
  
  static var previews: some View {
    MapAnnotationView2(location: locations[0])
      .previewLayout(.sizeThatFits)
      .padding()
  }
}
