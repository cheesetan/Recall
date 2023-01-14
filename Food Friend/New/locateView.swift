//
//  locateView.swift
//  Food Friend
//
//  Created by Tristan on 26/10/22.
//

import SwiftUI
import MapKit

struct locateView: View {
    
    @State private var region: MKCoordinateRegion = {
        var mapCoordinates = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        var mapZoomLevel = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
        var mapRegion = MKCoordinateRegion(center: mapCoordinates, span: mapZoomLevel)
        
        return mapRegion
    }()
    
    @StateObject var manager = LocationManager()
    
    @State var tracking: MapUserTrackingMode = .follow
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Map(
                    coordinateRegion: $region,
                    interactionModes: MapInteractionModes.all,
                    showsUserLocation: true,
                    userTrackingMode: $tracking
                )
                .accentColor(.pink)
                .background(Color("bgColorTab"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: UIScreen.main.bounds.width - 25, height: 100)
                        .foregroundColor(Color("bgColorTab2"))
                        .padding(.top)
                        .overlay(
                            Text("\(finalEmail) is at 1 Technology Drive")
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        )
                    ,alignment: .top
                )
            }
            .navigationTitle("\(finalEmail)'s location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct locateView_Previews: PreviewProvider {
    static var previews: some View {
        locateView()
    }
}
