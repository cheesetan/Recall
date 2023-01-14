//
//  CustomTabBar.swift
//  Recall
//
//  Created by Tristan on 15/10/22.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case checklist
    case person
    case gearshape
}

struct CustomTabBar: View {
    
    @AppStorage("hideCustomTabBar", store: .standard) var hideCustomTabBar = false

    @Binding var selectedTab: Tab
    
    private var tabColor: Color {
        switch selectedTab {
        case .checklist:
            return .teal
        case .person:
            return .green
        case .gearshape:
            return .indigo
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    if tab.rawValue != "checklist" {
                        Image(systemName: tab.rawValue + ".fill")
                            .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                            .foregroundColor(selectedTab == tab ? tabColor : .gray)
                            .font(.title3)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    selectedTab = tab
                                }
                            }
                    } else {
                        if selectedTab == tab {
                            Image(systemName: tab.rawValue)
                                .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                                .foregroundColor(selectedTab == tab ? tabColor : .gray)
                                .font(.title3)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        selectedTab = tab
                                    }
                                }
                        } else {
                            Image(systemName: tab.rawValue + ".unchecked")
                                .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                                .foregroundColor(selectedTab == tab ? tabColor : .gray)
                                .font(.title3)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTab = tab
                                    }
                                }
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: hideCustomTabBar ? 0 : nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.checklist))
    }
}
