//
//  ViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-02-28.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import ChameleonFramework

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], for: .normal)
        
        titleLabel.textColor = UIColor.flatWhite
        
        
    }

   
}

