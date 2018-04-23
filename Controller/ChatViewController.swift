//
//  ChatViewController.swift
//  RiverLaunch
//
//  Created by Christopher Hynes on 2018-04-21.
//  Copyright © 2018 Christopher Hynes. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import ChameleonFramework


class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
   
        
        
        // Declare instance variables here
        var messageArray : [Message] = [Message]()
        var riverName: String?
        
        // We've pre-linked the IBOutlets
        @IBOutlet var heightConstraint: NSLayoutConstraint!
        @IBOutlet var sendButton: UIButton!
        @IBOutlet var messageTextfield: UITextField!
        @IBOutlet var messageTableView: UITableView!
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            if let riverIndex = SelectedRiver.River.selectedRiver {
                title = riverIndex
                riverName = riverIndex
            } else {
                title = "No River Selected"
            }
            
            
            //TODO: Set yourself as the delegate and datasource here:
            messageTableView.delegate = self
            messageTableView.dataSource = self
            messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
            messageTableView.backgroundColor = UIColor(patternImage: UIImage(named: "Nighthawk")!)
            
            
            
            //TODO: Set yourself as the delegate of the text field here:
            messageTextfield.delegate = self
            
            
            //TODO: Set the tapGesture here:
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
            messageTableView.addGestureRecognizer(tapGesture)
            
            //TODO: Register your MessageCell.xib file here:
            
            configureTableView()
            retrieveMessages()
            messageTableView.separatorStyle = .none
        }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
        
        ///////////////////////////////////////////
        
        //MARK: - TableView DataSource Methods
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.timeStamp.text = messageArray[indexPath.row].date
            
            cell.avatarImageView.image = UIImage(named: "avatar")
            
            if cell.senderUsername.text == GetUserName.name.userName {
                cell.avatarImageView.backgroundColor = UIColor.flatMint
                cell.messageBackground.backgroundColor = UIColor.flatSkyBlue
            } else {
                //cell.avatarImageView.backgroundColor = UIColor.flatWatermelon
                cell.messageBackground.backgroundColor = UIColor.flatGreen
                
            }
            
            return cell
        }
        
        
        //TODO: Declare cellForRowAtIndexPath here:
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messageArray.count
        }
        
        
        
        //TODO: Declare numberOfRowsInSection here:
        
        
        
        //TODO: Declare tableViewTapped here:
        
        @objc func tableViewTapped() {
            messageTextfield.endEditing(true)
        }
        
        
        //TODO: Declare configureTableView here:
        
        func configureTableView() {
            messageTableView.rowHeight = UITableViewAutomaticDimension
            messageTableView.estimatedRowHeight = 120.0
        }
        
        ///////////////////////////////////////////
        
        //MARK:- TextField Delegate Methods
        
        
        
        
        //TODO: Declare textFieldDidBeginEditing here:
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
            UIView.animate(withDuration: 0.5) {
                self.heightConstraint.constant = 315
                self.view.layoutIfNeeded()
            }
        }
        
        
        
        //TODO: Declare textFieldDidEndEditing here:
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            UIView.animate(withDuration: 0.5) {
                self.heightConstraint.constant = 50
                self.view.layoutIfNeeded()
            }
            
            
        }
        
        
        ///////////////////////////////////////////
        
        
        //MARK: - Send & Recieve from Firebase
        
        
        
        
        
        @IBAction func sendPressed(_ sender: AnyObject) {
            
            
            //TODO: Send the message to Firebase and save it in our database
            
            
            messageTextfield.endEditing(true)
            messageTextfield.isEnabled = false
            sendButton.isEnabled = false
            let getDateData = GetDateData()
            let timeStamp = getDateData.currentDate()
            let messagesDB = Database.database().reference().child("Messages").child(riverName!)
            
            //let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
            let messageDictionary = ["Sender": GetUserName.name.userName, "MessageBody": messageTextfield.text!, "Date" : timeStamp]
            messagesDB.childByAutoId().setValue(messageDictionary){
                (error, reference) in
                
                if error != nil {
                    print(error!)
                    
                } else {
                    print("Message saved succesfully")
                    
                    self.messageTextfield.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextfield.text = ""
                }
            }
        }
        
        //TODO: Create the retrieveMessages method here:
        
        func retrieveMessages() {
            let messageDB = Database.database().reference().child("Messages").child(riverName!)
            messageDB.observe(.childAdded) { (snapShot) in
                let snapShotValue = snapShot.value as! Dictionary<String, String>
                let text = snapShotValue["MessageBody"]!
                let sender = snapShotValue["Sender"]!
                let timeStamp = snapShotValue["Date"]!
                
                let message = Message()
                message.messageBody = text
                message.sender = sender
                message.date = timeStamp
                
                self.messageArray.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
        
        
        
        
        
        
        @IBAction func logOutPressed(_ sender: AnyObject) {
            
            //TODO: Log out the user and send them back to WelcomeViewController
            do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            }
            catch {
                print("There was an error")
            }
            
        }
        
        
        
}

