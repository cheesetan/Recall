//
//  KSMapView.swift
//  Food Friend
//
//  Created by Tristan on 28/12/2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import MapKit

struct KSMapView: View {
    var body: some View {
        mapView()
    }
}

struct KSMapView_Previews: PreviewProvider {
    static var previews: some View {
        KSMapView()
    }
}

struct mapView: UIViewRepresentable {
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("locationTracking", store: .standard) private var locationTracking = false
    
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    
    
    let map = MKMapView()
    let manager = CLLocationManager()
    
    func makeUIView(context: UIViewRepresentableContext<mapView>) -> MKMapView {
        
        manager.delegate = context.coordinator
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        manager.requestWhenInUseAuthorization()
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<mapView>) {
        
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
        @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
        @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
        @AppStorage("finalUID", store: .standard) private var finalUID = ""
        @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
        
        @AppStorage("locationTracking", store: .standard) private var locationTracking = false
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                print("denied")
            }
            if status == .authorizedWhenInUse {
                print("authorized when in use")
                CLLocationManager().requestAlwaysAuthorization()
            }
            if status == .authorizedAlways {
                print("authorized always")
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            manager.allowsBackgroundLocationUpdates = true
            
            let last = locations.last
            
            if isLoggedIn {
                if locationTracking {
                    Firestore.firestore().collection("users").document("\(finalUID)").updateData([
                        "coordinates" : GeoPoint(latitude: (last?.coordinate.latitude)!, longitude: (last?.coordinate.longitude)!)
                    ]) { (err) in
                        
                        if err != nil {
                            print((err?.localizedDescription))
                            return
                        }
                        
                        print("success")
                        Firestore.firestore().collection("users").document("\(Auth.auth().currentUser!.uid)").updateData([
                            "coordinates-lastupdate" : Date()
                        ]) { (err) in
                            
                            if err != nil {
                                print((err?.localizedDescription))
                                return
                            }
                            
                            print("success")
                        }
                    }
                }
            }
            
        }
    }
}
