//
//  addToListVC.swift
//  Recall
//
//  Created by Tristan on 16/7/22.
//

import UIKit
import SwiftUI

class addToListVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwiftUIaddToList()
    }
}

private extension addToListVC {
    func addSwiftUIaddToList() {
        let addToListView = addToListSwiftUI()
        let controller = UIHostingController(rootView: addToListView)
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
