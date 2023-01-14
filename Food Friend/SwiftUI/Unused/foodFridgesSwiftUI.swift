//
//  foodFridgesSwiftUI.swift
//  Recall
//
//  Created by Tristan on 30/7/22.
//

import SwiftUI
import MapKit

struct foodFridgesSwiftUI: View {
    // MARK: - PROPERTIES
    
    @State private var region: MKCoordinateRegion = {
        var mapCoordinates = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        var mapZoomLevel = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
        var mapRegion = MKCoordinateRegion(center: mapCoordinates, span: mapZoomLevel)
        
        return mapRegion
    }()
    
    let locations: [NationalParkLocation] = Bundle.main.decode("locationsFF.json")
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var orgTapped = false
    
    @State private var orgNameShow = ""
    @State private var orgAddressShow = ""
    @State private var orgWebsiteShow = ""
    
    @State private var isShowingPopover = false
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    let heights = stride(from: 0.15, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
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
                        MapAnnotationView3(location: item)
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
                                        Text("Food Fridge's Information")
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
                /*
                .overlay(
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36, alignment: .center)
                            .foregroundColor(.white)
                        if orgTapped {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text("Name:")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(orgNameShow)")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Address:")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(orgAddressShow)
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Website:")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    let url = orgWebsiteShow
                                    let link = "[\(orgWebsiteShow)](\(url))"
                                    
                                    HStack {
                                        Text(.init(link))
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.trailing)
                                        Button {
                                            guard let google = URL(string: "\(orgWebsiteShow)"),
                                                  UIApplication.shared.canOpenURL(google) else {
                                                return
                                            }
                                            UIApplication.shared.open(google,
                                                                      options: [:],
                                                                      completionHandler: nil)
                                        } label: {
                                            Image(systemName: "arrow.up.forward.app")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("Tap on a point to view more information!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                        }
                    } //: HSTACK
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(
                            Color.black
                                .cornerRadius(8)
                                .opacity(0.6)
                        )
                        .padding()
                    , alignment: .top
                )
                */
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Food Fridges", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        orgTapped = false
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    })
        }
    }
}

struct foodFridgesSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        foodFridgesSwiftUI()
    }
}
