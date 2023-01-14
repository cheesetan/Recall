//
//  FirebaseStorageManager.swift
//  Recall
//
//  Created by Tristan on 9/8/22.
//

import UIKit
import FirebaseStorage

class FirebaseStorageManager {
    
    public func uploadFile(localFile: URL, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "uploads/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putFile(from: localFile, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func uploadImageData(userUID: String, itemUID: String?, data: Data, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "\(userUID)/\(itemUID!)/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func loadImageFromFirebase(userUID: String, itemUID: String?, completionHandler: @escaping (_ isSuccess: Bool, _ url: URL?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "\(userUID)/\(itemUID!)/\(itemUID!).png")
        storageRef.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                completionHandler(false, nil)
                return
            }
            completionHandler(true, url!)
        }
    }
    
    public func uploadPostImageData(userUID: String, itemUID: String?, data: Data, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "\(userUID)/\(itemUID!)/Post/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func loadPostImageFromFirebase(userUID: String, itemUID: String?, completionHandler: @escaping (_ isSuccess: Bool, _ url: URL?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "\(userUID)/\(itemUID!)/Post/\(itemUID!).png")
        storageRef.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                completionHandler(false, nil)
                return
            }
            completionHandler(true, url!)
        }
    }
    
    public func loadUserPFP(userUID: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: URL?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "\(userUID)/Profile Picture/\(userUID).png")
        storageRef.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                completionHandler(false, nil)
                return
            }
            completionHandler(true, url!)
        }
    }
    
    public func uploadUserPFP(userUID: String, data: Data, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "\(userUID)/Profile Picture/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
}
