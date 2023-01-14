//
//  foodDriveSwiftUI.swift
//  Recall
//
//  Created by Tristan on 30/7/22.
//

import SwiftUI
import MapKit

struct foodDriveSwiftUI: View {
    
    @State private var region: MKCoordinateRegion = {
        var mapCoordinates = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        var mapZoomLevel = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
        var mapRegion = MKCoordinateRegion(center: mapCoordinates, span: mapZoomLevel)
        
        return mapRegion
    }()
    
    let locations: [NationalParkLocation] = Bundle.main.decode("locationsFD.json")
    
    @State private var orgTapped = false
    
    @State private var orgNameShow = ""
    @State private var orgAddressShow = ""
    @State private var orgWebsiteShow = ""
    
    @State private var isShowingPopover = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Basic Map
                // Map(coordinateRegion: $region)
                
                // MARK: - Advanced Map
                Map(coordinateRegion: $region, annotationItems: locations, annotationContent: { item in
                  // (A) PIN: OLD STYLE (always static)
                  // MapPin(coordinate: item.location, tint: .accentColor)
                  
                  // (B) MARKER: NEW STYLE (always static)
                  // MapMarker(coordinate: item.location, tint: .accentColor)
                  
                  // (C) CUSTOM BASIC ANNOTATION (it could be interactive)
                  // MapAnnotation(coordinate: item.location) {
                  //   Image("logo")
                  //     .resizable()
                  //     .scaledToFit()
                  //     .frame(width: 32, height: 32, alignment: .center)
                  // } //: ANNOTATION
                  
                  // (D) CUSTOM ADVANCED ANNOTATION (it could be interactive)
                    MapAnnotation(coordinate: item.location) {
                        MapAnnotationView2(location: item)
                            .onTapGesture {
                                orgNameShow = item.name
                                orgAddressShow = item.address
                                orgWebsiteShow = item.website
                                
                                generator.impactOccurred(intensity: 0.7)
                                
                                orgTapped = true
                                isShowingPopover = true
                            }
                            .sheet(isPresented: $isShowingPopover) {
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .fontWeight(.semibold)
                                        Text("Food Drive's Information")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                }
                                
                                Divider()
                                
                                let url = orgWebsiteShow
                                let link = "[\(orgWebsiteShow)](\(url))"
                                
                                VStack {
                                    HStack {
                                        Text("Name: ")
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 5)
                                            .padding(.leading, 18)
                                        Spacer()
                                        Text("\(orgNameShow)")
                                            .padding(.trailing, 18)
                                    }
                                    Divider()
                                    HStack {
                                        Text("Address: ")
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 5)
                                            .padding(.leading, 18)
                                        Spacer()
                                        Text("\(orgAddressShow)")
                                            .padding(.trailing, 18)
                                    }
                                    Divider()
                                    HStack {
                                        Text("Website: ")
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 5)
                                            .padding(.leading, 18)
                                        Spacer()
                                        Text(.init(link))
                                            .fontWeight(.semibold)
                                            .padding(.trailing, 18)
                                    }
                                    Divider()
                                    Spacer()
                                }
                                .presentationDetents([.height(220)])
                            }
                    }
                }) //: MAP
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Food Drives", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    })
        }
    }
}

struct foodDriveSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        foodDriveSwiftUI()
    }
}
