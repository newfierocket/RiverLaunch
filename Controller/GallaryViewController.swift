//
//  GallaryViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-17.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase



class GallaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var gallaryImageView: UIImageView!
    
    var imageArray = [String]()
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
        
       
        
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageArray.count > 0 {
            for i in 0..<imageArray.count {
                let url = imageArray[i]
                gallaryImageView.downloadedFrom(link: url)
                
            }
        }
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
            let url = imageArray[pictureIndex]
            gallaryImageView.downloadedFrom(link: url)
        } else if recognizer.direction == .left {
            print("swiped left")
            if pictureIndex == 0 {
                pictureIndex = max
            } else {
                pictureIndex -= 1
            }
        }
        
        let url = imageArray[pictureIndex]
        gallaryImageView.downloadedFrom(link: url)
    }
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        gallaryImageView.contentMode = .scaleAspectFit //3
//        gallaryImageView.image = chosenImage //4
        let date = Date()
        let riverRef = imageStorage.reference().child("\(date).png")
        if let uploadData = UIImagePNGRepresentation(chosenImage) {
            
            riverRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                } else {
                    if let url = metadata?.downloadURL()?.absoluteString {
                        self.imageArray.append(url)
                        self.gallaryImageView.downloadedFrom(link: url)
                        
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
    


}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
