//
//  NewQRCodeScannerViewController.swift
//  Recall
//
//  Created by Tristan on 5/8/22.
//

import UIKit
import SwiftUI

class NewQRCodeScannerViewController: UIViewController {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    @IBOutlet weak var addListButton: UIBarButtonItem!
    
    // MARK: - Checks if you just came from Manual Product Adding
    @AppStorage("justFromAddManual", store: .standard) var justFromAddManual = false
    @AppStorage("justLeftMoreInfo", store: .standard) var justLeftMoreInfo = false
    
    @AppStorage("appendToTop", store: .standard) var appendToTop = true
    @AppStorage("segmentToTop", store: .standard) var segmentToTop = 0
    @AppStorage("allowFFC", store: .standard) var allowFFC = false
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    @AppStorage("isCamAllowed", store: .standard) var isCamAllowed = false
    @AppStorage("camPrompt", store: .standard) var camPrompt = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addSwiftUIQRScan()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addListButton_pressed(_ sender: Any) {
        generator.impactOccurred(intensity: 0.7)
    }
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension NewQRCodeScannerViewController {
    func addSwiftUIQRScan() {
        let qrCodeView = QRCodeScannerSwiftUI()
        let controller = UIHostingController(rootView: qrCodeView)
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
