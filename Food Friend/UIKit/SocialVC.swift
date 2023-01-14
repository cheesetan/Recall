//
//  SocialVC.swift
//  Recall
//
//  Created by Tristan on 11/7/22.
//

import UIKit
import SwiftUI

class SocialVC: UIViewController {
        
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    @AppStorage("justLeftMoreInfo", store: .standard) var justLeftMoreInfo = false
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("prefinalUID", store: .standard) private var prefinalUID = ""
    @AppStorage("finalUID", store: .standard) private var finalUID = ""

    @IBOutlet weak var messageButton: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        if isLoggedIn {
            messageButton.isEnabled = true
        } else {
            messageButton.isEnabled = false
        }
        tempDevMode = 0
        justLeftMoreInfo = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
