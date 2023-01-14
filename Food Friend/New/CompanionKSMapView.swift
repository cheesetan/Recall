//
//  CompanionKSMapView.swift
//  Food Friend
//
//  Created by Tristan on 28/12/2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import MapKit

struct Point: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct CompanionKSMapView: View {
    
    @AppStorage("isCompLogged", store: .standard) private var isCompLogged = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var lat = Double()
    @State private var lon = Double()
    
    @State private var updateDate = ""
    @State private var updateTime = ""
    
    let db = Firestore.firestore()
    
    @State var tracking: MapUserTrackingMode = .follow
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45))
    
    var body: some View {
        let annotations = [
            Point(name: "User", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
        ]
        
        NavigationView {
            Map(coordinateRegion: $region, interactionModes: MapInteractionModes.all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: annotations) {
                MapAnnotation(coordinate: $0.coordinate) {
                    VStack {
                        Text("User")
                            .fontWeight(.bold)
                            .font(.subheadline)
                        Image(systemName: "person.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
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
                        if let coords = document.get("coordinates") {
                            let point = coords as! GeoPoint
                            lat = point.latitude
                            lon = point.longitude
                            print(lat, lon) //here you can let coor = CLLocation(latitude: longitude:)
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
                        if let lastupdate = document.get("coordinates-lastupdate") {
                            let lastupdate2 = lastupdate as! Timestamp
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "hh:mm:ss a"
                            updateTime = dateFormatter.string(from: lastupdate2.dateValue())
                            
                            let dateFormatter2 = DateFormatter()
                            dateFormatter2.dateStyle = .long
                            dateFormatter2.timeStyle = .none
                            updateDate = dateFormatter2.string(from: lastupdate2.dateValue())
                            
                            print(updateDate, updateTime)
                        }
                    }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Last updated: \(updateDate) at \(updateTime)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                }
            }
        }
    }
}

struct CompanionKSMapView_Previews: PreviewProvider {
    static var previews: some View {
        CompanionKSMapView()
    }
}
