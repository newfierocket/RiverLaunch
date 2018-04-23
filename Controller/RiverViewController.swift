//
//  RiverViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
//import Foundation
import Firebase

let masterRiverList = SelectedRiver.River.riverNames
var riverDict = SelectedRiver.River.riverNames[0]
var changedRiverDict = riverDict[1]
var userName: String?
var riverAreaPicker: UIPickerView!



class RiverViewController: UIViewController {
    
    @IBOutlet weak var riverSearchBar: UISearchBar!
    @IBOutlet weak var RiverTableView: UITableView!
    @IBOutlet weak var areaButtonOutlet: UIBarButtonItem!
    
    
    let gesture = UIGestureRecognizer()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        RiverTableView.delegate = self
        RiverTableView.dataSource = self
        riverSearchBar.delegate = self
        riverSearchBar.barTintColor = UIColor.clear
        
        
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let signoutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signout))
       // let signoutButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(signout))
        //navigationItem.setRightBarButtonItems([signoutButton], animated: false)
        signoutButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = signoutButton
        
        let userid = Auth.auth().currentUser?.uid
        let database = Database.database().reference().child("users").child(userid!)
        database.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            GetUserName.name.userName = (snapshotValue["username"]!)
            
        }
        
        title = riverDict[0][0]
        
        riverAreaPicker = UIPickerView()
        riverAreaPicker.backgroundColor = UIColor(hexString: "#17518D")
        riverAreaPicker.isHidden = true
        let pickerHeight = view.frame.height
        riverAreaPicker.frame = CGRect(x: 0, y: 120, width: view.frame.width, height: pickerHeight / 4)
        view.addSubview(riverAreaPicker)
        riverAreaPicker.delegate = self
        riverAreaPicker.dataSource = self
       
    }
    
    
    @IBAction func changeAreaButton(_ sender: UIBarButtonItem) {
        
        if riverAreaPicker.isHidden == true {
            riverAreaPicker.isHidden = false
            areaButtonOutlet.title = "Done"
        } else {
            riverAreaPicker.isHidden = true
            areaButtonOutlet.title = "Area"
        }
    }
    
    
    @objc func signout() {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
  
        } catch {
            print(error)
        }
    }
    
  
   
    
}

//MARK: - TABLEVIEW DELEGATES

extension RiverViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return changedRiverDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RiverCell") else {fatalError()}
        cell.textLabel?.text = changedRiverDict[indexPath.row]
       
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.textLabel?.textColor = UIColor.white
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sectionHeaderView = RiverTableView.cellForRow(at: indexPath) {
            guard let title = sectionHeaderView.textLabel?.text else {fatalError()}
            SelectedRiver.River.selectedRiver = title
            
        }
        
        //performSegue(withIdentifier: "GoToInfoViewController", sender: self)
        performSegue(withIdentifier: "Blah", sender: self)
        
    }
    
}

//MARK: - SEARCH BAR DELEGATES

extension RiverViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = riverSearchBar.text!
        //changedRiverDict = riverDict[1].filter {$0.contains(searchText)}
        changedRiverDict = riverDict[1].filter {$0.localizedCaseInsensitiveContains(searchText)}
        RiverTableView.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if riverSearchBar.text?.count == 0 {
            changedRiverDict = riverDict[1]
            RiverTableView.reloadData()
        }
        
    }
    
}

//MARK: - PICKER VEW DELEGATES
extension RiverViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return masterRiverList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        riverDict = SelectedRiver.River.riverNames[row]
        changedRiverDict = riverDict[1]
        pickerView.isHidden = true
        title = riverDict[0][0]
        RiverTableView.reloadData()
        areaButtonOutlet.title = "Area"
       
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titles = SelectedRiver.River.riverNames
        let pickerLabel = UILabel()
        let title = titles[row][0][0]
        pickerLabel.text = title
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = UIColor.flatWhite
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        return pickerLabel
    }
    
    
}
 
