//
//  SettingsViewController.swift
//  Recall
//
//  Created by Tristan on 7/7/22.
//

import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    
    @AppStorage("justLeftMoreInfo", store: .standard) var justLeftMoreInfo = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        justLeftMoreInfo = true
        addSwiftUISettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

private extension SettingsViewController {
    func addSwiftUISettings() {
        let settingsView = SettingsSwiftUI()
        let controller = UIHostingController(rootView: settingsView)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
