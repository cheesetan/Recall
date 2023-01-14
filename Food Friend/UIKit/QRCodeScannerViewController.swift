//
//  QRCodeScannerViewController.swift
//  Recall
//
//  Created by Tristan on 6/7/22.
//
/*
import UIKit
import AVFoundation
import CoreData
import SwiftUI

class QRCodeScannerViewController: UIViewController {
    
    // MARK: - Checks if you just came from Manual Product Adding
    @AppStorage("justFromAddManual", store: .standard) var justFromAddManual = false
    @AppStorage("justLeftMoreInfo", store: .standard) var justLeftMoreInfo = false
    
    @AppStorage("appendToTop", store: .standard) var appendToTop = true
    @AppStorage("segmentToTop", store: .standard) var segmentToTop = 0
    @AppStorage("allowFFC", store: .standard) var allowFFC = false
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    @AppStorage("isCamAllowed", store: .standard) var isCamAllowed = false
    @AppStorage("camPrompt", store: .standard) var camPrompt = false
    
    
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrame:UIView!
    var textLabel:UILabel!
    let haptics = UINotificationFeedbackGenerator()
    var feedbackHaptics = 0
    var justFromInvalid = false
    var oldSaveQR = ""
    var camChoice = 0
    
    var foodTitleLabel = ""
    var foodExpireLabel = ""
    
    var foodTitleNow = ""
    var foodExpireNow = ""
    var foodIDNow = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tempDevMode = 0
        
        justLeftMoreInfo = true
        
        if justFromAddManual {
            justFromAddManual = false
            self.performSegue(withIdentifier: "ShowTable", sender: self)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            initialiseQRScanner()
            if allowFFC == false {
                if camChoice != 1 {
                    camChoice = 1
                    captureSession.stopRunning()
                    initialiseQRScanner()
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func initialiseQRScanner() {
        
        var discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        if camChoice == 1 {
            discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        } else if camChoice == 2 {
            discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        }
        
        guard let captureDevice = discoverySession.devices.first else {
            print("No devices found")
            return
        }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            captureSession.addInput(input)
            
            let videoMetaDataOutput = AVCaptureMetadataOutput()
            if let outputs = captureSession.outputs as? [AVCaptureMetadataOutput] {
                for output in outputs {
                    captureSession.removeOutput(output)
                }
            }
            captureSession.addOutput(videoMetaDataOutput)
            
            videoMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            videoMetaDataOutput.metadataObjectTypes = [.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            
            qrCodeFrame = UIView()
            
            if qrCodeFrame == qrCodeFrame {
                qrCodeFrame.layer.borderColor = UIColor.blue.cgColor
                qrCodeFrame.layer.borderWidth = 2.0
                
                view.addSubview(qrCodeFrame)
                view.bringSubviewToFront(qrCodeFrame)
            }
            
            textLabel = UILabel()
            
            if textLabel == textLabel {
                textLabel.layer.backgroundColor = UIColor.clear.cgColor
                textLabel.text = ""
                textLabel.textAlignment = .center
                textLabel.lineBreakMode = .byWordWrapping
                textLabel.numberOfLines = 2
                textLabel.adjustsFontSizeToFitWidth = true
                textLabel.minimumScaleFactor = 0.5
                
                view.addSubview(textLabel)
                view.bringSubviewToFront(textLabel)
            }
            
            captureSession.startRunning()
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                print("cam allowed")
                self.isCamAllowed = true
                self.camPrompt = true
            } else { AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] (granted: Bool) in
                if granted {
                    print("cam allowed")
                    self.isCamAllowed = true
                    self.camPrompt = true
                } else {
                    print("cam not allowed")
                    self.camPrompt = true
                }
            })
            }
            
        } catch {
            
            print(error)
            return
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    */
/*
}
class CustomTextField: UITextField {
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    func setUp() {
        //Setting constraints of CustomTextField with centerX, centerY
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: (self.superview?.centerYAnchor)!).isActive = true
        self.centerXAnchor.constraint(equalTo: (self.superview?.centerXAnchor)!).isActive = true
        //use if you want fixed width
        self.widthAnchor.constraint(equalToConstant: 250).isActive = true
        //self.heightAnchor.constraint(equalToConstant: 250).isActive = true
        self.backgroundColor = .red
        self.textAlignment = .center
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(
        _ action: Selector, withSender sender: Any?) -> Bool {
            return super.canPerformAction(action, withSender: sender)
            && (action == #selector(UIResponderStandardEditActions.cut)
                || action == #selector(UIResponderStandardEditActions.copy))
        }
}

extension QRCodeScannerViewController:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            textLabel.layer.backgroundColor = UIColor.clear.cgColor
            textLabel.text = ""
            qrCodeFrame.frame = .zero
            print("No code found.")
            feedbackHaptics = 0
            justFromInvalid = false
            oldSaveQR = ""
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObject.type == .qr {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFrame.frame = barCodeObject!.bounds
            
            let textCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            textLabel.frame = textCodeObject!.bounds
            
            if metadataObject.stringValue != nil {
                let qrValue = metadataObject.stringValue!
                print(metadataObject.stringValue!)
                if qrValue.contains("foodFriendApproved") {
                    let qrValueNew = qrValue.replacingOccurrences(of: "foodFriendApproved", with: "", options: NSString.CompareOptions.literal, range: nil)
                    let sentence = String(qrValueNew)
                    let lines = sentence.split(whereSeparator: \.isNewline)
                    print(lines)
                    print("foodLineCount: \(lines.count)")
                    if lines.count == 0 {
                        foodTitleLabel = "Unknown"
                        foodExpireLabel = "Unknown"
                    } else if lines.count == 1 {
                        foodTitleLabel = String("\(lines[0])")
                        foodExpireLabel = "Unknown"
                    } else {
                        foodTitleLabel = String("\(lines[0])")
                        foodExpireLabel = String("\(lines[1])")
                    }
                    textLabel.text = String(foodTitleLabel)
                    textLabel.layer.backgroundColor = UIColor.systemGreen.cgColor
                    
                    if feedbackHaptics == 0 || justFromInvalid {
                        if justFromInvalid {
                            print("snap stop prevented", justFromInvalid, feedbackHaptics)
                        }
                        haptics.notificationOccurred(.success)
                        justFromInvalid = false
                        feedbackHaptics = 1
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity (forEntityName: "Foods", in: context)
                        let newFoods = Foods(entity: entity!, insertInto: context)
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Foods")
                        
                        do {
                            let results = try context.fetch(request)
                            for results in results {
                                let foods = results as! Foods
                                print("foodsCurr: \(foods)")
                                if foodTitleNow == "" || foodTitleNow == " " {
                                    foodTitleNow = "\(foods.title)"
                                } else {
                                    foodTitleNow = "\(foodTitleNo)\(foods.title)"
                                }
                                if foodExpireNow == "" || foodExpireNow == " " {
                                    foodExpireNow = "\(foods.expire)"
                                } else {
                                    foodExpireNow = "\(foodExpireNow)\(foods.expire)"
                                }
                                if foodIDNow == "" || foodIDNow == " " {
                                    foodIDNow = "\(foods.id)"
                                } else {
                                    foodIDNow = "\(foodIDNow)\(foods.id)"
                                }
                            }
                            print("foodsCurr: \(foodTitleNow)")
                            print("foodsCurr: \(foodExpireNow)")
                            print("foodsCurr: \(foodIDNow)")
                            
                        } catch {
                            print("fetch error")
                        }
                        if foodTitleLabel == "" {
                            newFoods.title = String("Unknown")
                        } else {
                            newFoods.title = String(foodTitleLabel)
                        }
                        if foodExpireLabel == "" {
                            newFoods.expire = String("Expires on: Unknown")
                        } else {
                            newFoods.expire = String("Expires on: \(foodExpireLabel)")
                        }
                        
                        do {
                            if feedbackHaptics == 1 {
                                try context.save()
                                print(newFoods)
                                if appendToTop && segmentToTop == 0 {
                                    foodList.insert(newFoods, at: 0)
                                    appendToTop = true
                                    segmentToTop = 0
                                } else if appendToTop == false && segmentToTop == 1 {
                                    foodList.append(newFoods)
                                    appendToTop = false
                                    segmentToTop = 1
                                } else if appendToTop && segmentToTop == 1 {
                                    foodList.append(newFoods)
                                    appendToTop = false
                                    segmentToTop = 1
                                } else if appendToTop == false && segmentToTop == 0 {
                                    foodList.insert(newFoods, at: 0)
                                    appendToTop = true
                                    segmentToTop = 0
                                }
                                navigationController?.popViewController(animated: true)
                                print("done")
                                
                                // let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                // let vc: UINavigationController = storyboard.instantiateViewController(withIdentifier: "TableTableView") as! UINavigationController
                                self.performSegue(withIdentifier: "ShowTable", sender: self)
                                // self.present(vc, animated: true)
                                // TableTableView().performSegue(withIdentifier: "ShowSuccess", sender: TableTableView())
                            }
                            
                        } catch {
                            print("context save error")
                        }
                    }
                } else {
                    if qrValue != oldSaveQR {
                        textLabel.text = "Invalid Recall Code"
                        textLabel.layer.backgroundColor = UIColor.systemRed.cgColor
                        haptics.notificationOccurred(.error)
                        feedbackHaptics = 1
                        justFromInvalid = true
                        oldSaveQR = qrValue
                    }
                }
            }
        }
    }
}
*/
