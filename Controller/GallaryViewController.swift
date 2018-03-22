//
//  GallaryViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-17.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher



class GallaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var gallaryImageView: UIImageView!
    
    var imageArray: [ImageData] = [ImageData]()
    var index: Int?
    var riverName: String?
    let picker = UIImagePickerController()
    let imageStorage = Storage.storage()
    var pictureIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        index = SelectedRiver.River.selectedRiver
        if let riverIndex = index {
            riverName = SelectedRiver.River.riverNames[riverIndex]
        }
        
        gallaryImageView.isUserInteractionEnabled = true
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction(_:)))
        self.gallaryImageView.addGestureRecognizer(swipeGesture)
        
//        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/riverlaunch-6174c.appspot.com/o/2018-03-17%2023%3A11%3A01%20%2B0000.png?alt=media&token=29beba33-867f-43d3-813f-6ffad297c817")
//        gallaryImageView.kf.setImage(with: url)
//
        
        getImageData {
            if self.imageArray.count > 0 {
                for i in 0..<self.imageArray.count {
                    let url = URL(string: self.imageArray[i].imageURL)
                    self.gallaryImageView.kf.setImage(with: url)
                    
                }
            }
            
        }
        
        
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if imageArray.count > 0 {
//            for i in 0..<imageArray.count {
//                let url = URL(string: imageArray[i].imageURL)
//               gallaryImageView.kf.setImage(with: url)
//
//            }
//        }
    }
    
    @objc func getSwipeAction( _ recognizer : UISwipeGestureRecognizer){
        
        let max = imageArray.count - 1
        if recognizer.direction == .right {
            print("swiped right")
            if pictureIndex == max {
                pictureIndex = 0
            } else {
                pictureIndex += 1
            }
            let url = URL(string: imageArray[pictureIndex].imageURL)
            gallaryImageView.kf.setImage(with: url)
        } else if recognizer.direction == .left {
            print("swiped left")
            if pictureIndex == 0 {
                pictureIndex = max
            } else {
                pictureIndex -= 1
            }
        }

        let url = URL(string: imageArray[pictureIndex].imageURL)
        gallaryImageView.kf.setImage(with: url)
    }
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let date = Date()
        let riverRef = imageStorage.reference().child("\(date).png")
        if let uploadData = chosenImage.jpeg(.lowest) {

            riverRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                } else {
                    if let url = metadata?.downloadURL()?.absoluteString {
                        let imageData = ImageData()
                        imageData.imageName = String(describing: date)
                        imageData.imageURL = url
                        imageData.imageBelongsToRiver = self.riverName!
                        let dataToStore = ["imagename" : imageData.imageName, "url" : imageData.imageURL, "belongstoriver" : imageData.imageBelongsToRiver]
                        let myDatabase = Database.database().reference().child("Gallary").child(self.riverName!)
                        myDatabase.childByAutoId().updateChildValues(dataToStore)
                        

                    }
                

                }
            })
        }
    
        dismiss(animated:true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addPictureButton(_ sender: UIBarButtonItem) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
     
    }
    
    
    
    func getImageData(completion: @escaping () -> Void) {
        
        let riverDB = Database.database().reference().child("Gallary").child(riverName!)
        //group.enter()
        riverDB.observe(.childAdded) { (snapShot) in
            let snapShotValue = snapShot.value as! Dictionary<String, String>
            let url = snapShotValue["url"]!
            print(url)
            let riverName = snapShotValue["belongstoriver"]!
            let imageName = snapShotValue["imagename"]!
            
            print("inside image data")
            
            
            let imageData = ImageData()
            imageData.imageBelongsToRiver = riverName
            imageData.imageURL = url
            imageData.imageName = imageName
            
            
            self.imageArray.append(imageData)
            print("#########\(self.imageArray)")
            completion()
            
        }
        
    }
}
    






extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest    = 0
        case low       = 0.25
        case medium    = 0.5
        case high      = 0.75
        case highest   = 1
        
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
