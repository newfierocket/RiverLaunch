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
import KVNProgress
import Reachability



class GallaryViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    
    var imageArray: [ImageData] = [ImageData]()
    var index: String?
    var riverName: String?
    let picker = UIImagePickerController()
    let imageStorage = Storage.storage()
    var pictureIndex = 0
    var launchNameTextField = UITextField()
    let networkStatus = Reachability()!
    
    @IBOutlet weak var pictureNameLabel: UILabel!
    @IBOutlet weak var gallaryImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        
        picker.delegate = self
        pictureNameLabel.text = ""
        index = SelectedRiver.River.selectedRiver
        if let riverIndex = index {
            riverName = riverIndex
        }
        
        gallaryImageView.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.gallaryImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.gallaryImageView.addGestureRecognizer(swipeLeft)
        
        if networkStatus.connection != .none {
            //KVNProgress.show(0, status: "Loading Data")
            //KVNProgress.show(withStatus: "Loading Data")
            getImageData {
                if self.imageArray.count > 0 {
                    KVNProgress.showSuccess(withStatus: "Loading Data")
                    for i in 0..<self.imageArray.count {
                        let url = URL(string: self.imageArray[i].imageURL)
                        self.gallaryImageView.kf.setImage(with: url)
                        self.pictureNameLabel.text = self.imageArray[i].launchName
                        
                    }
                   // KVNProgress.update(1, animated: true)
                   // KVNProgress.dismiss()
                    
                } else {
                   // KVNProgress.dismiss()
                    KVNProgress.showError(withStatus: "No Pictures to Load")
                }
               
            }
        } else {
            KVNProgress.showError(withStatus: "No Network Connection")
        
        }
    }
   
    //MARK: - ZOOM IN USING SCROLL VIEW
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gallaryImageView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationController?.popToRootViewController(animated: false)
    
    }
    
 
}



//MARK: - UPLOAD DATA TO FIREBASE

extension GallaryViewController {
    
    @IBAction func addPicture(_ sender: UIBarButtonItem) {
    
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
       
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            present(self.picker, animated: true, completion: nil)
        } else {
            KVNProgress.showError(withStatus: "Photo Library Not Found")
        }
        
    }
    
    
    //MARK: - UPLOAD TO FIREBASE FUNCTION
    
    func uploadImageWithData(pickedImage: UIImage) {
        let alert = UIAlertController(title: "Please Enter a Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a name."
            self.launchNameTextField = textField
            
        }
        
        let action = UIAlertAction(title: "Please Enter a Name", style: .default) { (alertAction) in
            
            let date = Date()
            let riverRef = self.imageStorage.reference().child("\(date).png")
            if let uploadData = pickedImage.jpeg(.lowest) {
                
                riverRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    } else {
                        if let url = metadata?.downloadURL()?.absoluteString {
                            guard let user = Auth.auth().currentUser?.email else { KVNProgress.showError(withStatus: "Error"); return }
                            let imageData = ImageData()
                            imageData.imageName = String(describing: date)
                            imageData.imageURL = url
                            imageData.imageBelongsToRiver = self.riverName!
                            imageData.user = user
                        
                            let dataToStore = ["imagename" : imageData.imageName, "url" : imageData.imageURL, "belongstoriver" : imageData.imageBelongsToRiver, "launchname" :  self.launchNameTextField.text!, "user" : imageData.user]
                            let myDatabase = Database.database().reference().child("Gallary").child(self.riverName!)
                            myDatabase.childByAutoId().updateChildValues(dataToStore)
                            self.imageArray.append(imageData)
                            
                            
                        }
                        
                        
                    }
                })
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
}

//MARK: - SWIPE RECOGNIZER

extension GallaryViewController {
    
    @objc func getSwipeAction( _ recognizer : UISwipeGestureRecognizer){
        if imageArray.count == 0 {
            return
        } else {
            
            let max = imageArray.count - 1
            if recognizer.direction == .right {
                if pictureIndex == max {
                    pictureIndex = 0
                } else {
                    pictureIndex += 1
                }
                let url = URL(string: imageArray[pictureIndex].imageURL)
                gallaryImageView.kf.setImage(with: url)
            } else if recognizer.direction == .left {
                if pictureIndex == 0 {
                    pictureIndex = max
                } else {
                    pictureIndex -= 1
                }
            }
        }
        
        let url = URL(string: imageArray[pictureIndex].imageURL)
        pictureNameLabel.text = imageArray[pictureIndex].launchName
        gallaryImageView.kf.setImage(with: url)
    }
    
}

//MARK: - IMAGE PICKER DELEGATES

extension GallaryViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
        uploadImageWithData(pickedImage: chosenImage)
        
    }
    
}


//MARK: - GET FIRE BASE DATA

extension GallaryViewController {
    
    func getImageData(completion: @escaping () -> Void) {
        
        let riverDB = Database.database().reference().child("Gallary").child(riverName!)
        
        riverDB.observeSingleEvent(of: .value, with:  { (snapShot) in
            if let _ = snapShot.value as? NSNull {
                //KVNProgress.update(0.75, animated: true)
                completion()
            } else {
               // KVNProgress.update(0.5, animated: true)
                let snapShotValue = snapShot.value as! Dictionary<String, AnyObject>
                let keyArray = snapShotValue.keys
                
                for key in keyArray {
                    let imageData = ImageData()
                    
                    imageData.imageURL = snapShotValue[key]!["url"] as! String
                    imageData.imageBelongsToRiver = snapShotValue[key]!["belongstoriver"] as! String
                    imageData.imageName = snapShotValue[key]!["imagename"] as! String
                    imageData.launchName = snapShotValue[key]!["launchname"] as! String

                    self.imageArray.append(imageData)

                    }
                completion()
            }
        
        })
 
    }
}

    
//MARK: - UPLOAD IMAGE QUALITY AS JPEG

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
