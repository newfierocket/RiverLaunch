//
//  RiverViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-03-11.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Foundation

let riverDict = SelectedRiver.River.riverNames
var changedRiverDict = riverDict


class RiverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var riverSearchBar: UISearchBar!
    
    @IBOutlet weak var RiverTableView: UITableView!
    let gesture = UIGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RiverTableView.delegate = self
        RiverTableView.dataSource = self
        riverSearchBar.delegate = self
        riverSearchBar.barTintColor = UIColor.clear
        
        
      

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return changedRiverDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RiverCell") else {fatalError()}
        cell.textLabel?.text = changedRiverDict[indexPath.row]
        //changedRiverDict.append(riverDict[indexPath.row])
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
      
        performSegue(withIdentifier: "GoToInfoViewController", sender: self)
    
        
      
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = riverSearchBar.text!
        changedRiverDict = riverDict.filter {$0.contains(searchText)}
        RiverTableView.reloadData()
    
    
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if riverSearchBar.text?.count == 0 {
            changedRiverDict = riverDict
            RiverTableView.reloadData()
        }
        
    }
    
    
    
}
 
