//
//  ngoMapSwiftUI.swift
//  Recall
//
//  Created by Tristan on 30/7/22.
//

import SwiftUI
import MapKit

struct ngoMapSwiftUI: View {
    
    @State private var region: MKCoordinateRegion = {
        var mapCoordinates = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        var mapZoomLevel = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
        var mapRegion = MKCoordinateRegion(center: mapCoordinates, span: mapZoomLevel)
        
        return mapRegion
    }()
    
    let locations: [NationalParkLocation] = Bundle.main.decode("locationsNGOs.json")
    
    @AppStorage("orgNameShow", store: .standard) private var orgNameShow = ""
    @AppStorage("orgAddressShow", store: .standard) private var orgAddressShow = ""
    @AppStorage("orgWebsiteShow", store: .standard) private var orgWebsiteShow = ""
    @AppStorage("orgImageShow", store: .standard) private var orgImageShow = ""
    
    @State private var isShowingPopover = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @State private var isShowingSuggest = false
    @State private var isShowingVisitWebsite = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalUsername", store: .standard) private var finalUsername = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("isWebsiteAlert", store: .standard) var isWebsiteAlert = true
    @AppStorage("isWebsiteAllowed", store: .standard) var isWebsiteAllowed = true
    
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
                                orgImageShow = item.image
                                orgAddressShow = item.address
                                orgWebsiteShow = item.website
                                
                                print("vegetables \(item)")
                                
                                generator.impactOccurred(intensity: 0.7)
                                
                                isShowingPopover = true
                            }
                            .sheet(isPresented: $isShowingPopover) {
                                
                                // let url = orgWebsiteShow
                                // let link = "[\(orgWebsiteShow)](\(url))"
                                VStack(alignment: .center) {
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .center) {
                                            Image(orgImageShow)
                                                .resizable()
                                                .frame(width: 115, height: 115)
                                                .cornerRadius(20)
                                                .padding(.top)
                                                .padding(.horizontal, 10)
                                            ShareLink(
                                                    item: orgWebsiteShow,
                                                    preview: SharePreview(
                                                        "\(orgNameShow) at \(orgAddressShow)",
                                                        image: Image(orgImageShow)
                                                    )
                                                )
                                                .padding(.top, 5)
                                        }
                                        VStack(alignment: .trailing) {
                                            HStack {
                                                Text("\(orgNameShow)")
                                                    .padding(.trailing, 18)
                                                    .multilineTextAlignment(.trailing)
                                            }
                                            .padding(.vertical, 8)
                                            Divider()
                                            HStack {
                                                Text("\(orgAddressShow)")
                                                    .padding(.trailing, 18)
                                                    .multilineTextAlignment(.trailing)
                                            }
                                            .padding(.vertical, 8)
                                            Divider()
                                            HStack {
                                                Button {
                                                    if isWebsiteAlert {
                                                        isShowingVisitWebsite = true
                                                    } else {
                                                        guard let google = URL(string: "\(orgWebsiteShow)"),
                                                              UIApplication.shared.canOpenURL(google) else {
                                                            return
                                                        }
                                                        UIApplication.shared.open(google,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text(orgWebsiteShow)
                                                            .fontWeight(.semibold)
                                                            .multilineTextAlignment(.trailing)
                                                        Image(systemName: "arrow.up.forward.app")
                                                            .fontWeight(.semibold)
                                                            .padding(.trailing, 18)
                                                            .multilineTextAlignment(.trailing)
                                                    }
                                                }
                                                .disabled(isWebsiteAllowed == false)
                                                .alert("Visit Website", isPresented: $isShowingVisitWebsite, actions: {
                                                    Button("No", role: .cancel, action: {
                                                        
                                                    })
                                                    Button("Yes", role: .destructive, action: {
                                                        guard let google = URL(string: "\(orgWebsiteShow)"),
                                                              UIApplication.shared.canOpenURL(google) else {
                                                            return
                                                        }
                                                        UIApplication.shared.open(google,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
                                                    })
                                                }, message: {
                                                    Text("You're about to leave Recall and visit \(orgWebsiteShow), are you sure you want to do this?")
                                                    
                                                })
                                            }
                                            .padding(.vertical, 8)
                                            Divider()
                                        }
                                    }
                                    /*
                                     HStack(alignment: .center) {
                                     Image(systemName: "info.circle")
                                     .resizable()
                                     .frame(width: 20, height: 20)
                                     .fontWeight(.semibold)
                                     Text("Food Drive's Information")
                                     .font(.title3)
                                     .fontWeight(.semibold)
                                     }
                                     .padding(.vertical)
                                     */
                                    
                                    /*
                                     VStack {
                                     HStack {
                                     Text("Name: ")
                                     .fontWeight(.semibold)
                                     .multilineTextAlignment(.leading)
                                     .padding(.vertical, 10)
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
                                     .padding(.vertical, 10)
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
                                     .padding(.vertical, 10)
                                     .padding(.leading, 18)
                                     Spacer()
                                     Text(.init(link))
                                     .fontWeight(.semibold)
                                     .padding(.trailing, 18)
                                     }
                                     Divider()
                                     Spacer()
                                     }
                                     */
                                        .presentationDetents([.height(190)])
                                }
                            }
                    }
                }) //: MAP
            }
            .background(Color("bgColorTab"))
            .navigationBarTitle("Food Donation Drives", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    })
            /*
            .navigationBarItems(
                trailing:
                    Button(action: {
                        generator.impactOccurred(intensity: 0.7)
                        isShowingSuggest = true
                    }) {
                        Image(systemName: "plus.circle")
                    })
            .disabled(isLoggedIn == false)
            .sheet(isPresented: $isShowingSuggest) {
                suggestNewLocationSwiftUI()
            }
             */
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            orgNameShow = ""
            orgAddressShow = ""
            orgWebsiteShow = ""
            orgImageShow = ""
        }
    }
}

struct ngoMapSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        ngoMapSwiftUI()
    }
}
