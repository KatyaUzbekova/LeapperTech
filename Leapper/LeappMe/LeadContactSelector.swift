//
//  LeadContactSelector.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import Contacts
import DLRadioButton
import MessageUI
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire

class LeadContactSelector: UIViewController {
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var selectAllButton: DLRadioButton!
    
    var _idSender = ""
    var _id = ""
    
    @IBOutlet weak var viewSelectAll: UIView!
    @objc func funcSelectAll(){
        if selected == false {
            selectAllButton.isSelected = true
            for cont in contacts {
                for ctcNum: CNLabeledValue in cont.phoneNumbers {
                    if let fulPhone = ctcNum.value as? CNPhoneNumber {
                        if let ph = fulPhone.value(forKey: "digits") as? String{
                            if !pickedPhones.contains(ph){
                                pickedPhones.append(ph)
                            }
                        }
                    }
                }
                
            }
            selected = true
        }
        else {
            selectAllButton.isSelected = false
            selected = false
            pickedPhones = []
        }
        DispatchQueue.main.async {
            
            self.contactsListTableView.reloadData()
        }
    }
    
    
    @IBOutlet weak var contactsListTableView: UITableView!
    @IBOutlet weak var info: UILabel!
    var PHONENUMBER = ""
    var PROFKEY = ""
    var selected = false
    var contacts = [CNContact]()
    var pickedPhones = [String]()
    
    var leads = [String: String]()
    
    var filteredData: [CNContact]!
    @IBOutlet weak var searchView: UISearchBar!
    func leappingApi() {
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        for (name, phone) in zip(initializersNames, phonestoSMS) {
            leads[name] = phone
        }
        
        let parameters: [String:Any] = [
            "senderId": "\(_idSender)", "getterId": "\(_id)",
            "leads": [
                leads
            ],
        ]
        AF.request("https://api.leapper.com/api/mobi/giveLeapp", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            let json = resp.data
            _ = String(data: json!, encoding: .utf8)
            do {
                _ = try JSON(data: json!)
            }
            catch {
            }
            
        }
    }
    override func viewDidLoad() {
        super .viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.funcSelectAll))
        viewSelectAll.isUserInteractionEnabled = true
        viewSelectAll.addGestureRecognizer(tap)
        selectAllButton.isMultipleSelectionEnabled = true
        searchView.delegate = self
        getContacts()
        filteredData = contacts
        
        searchView.tintColor = .white
        if #available(iOS 13.0, *) {
            searchView.searchTextField.leftView?.tintColor = .white
        } else {
            // Fallback on earlier versions
        }
        contactsListTableView.separatorStyle = .none
        contactsListTableView.delegate = self
        contactsListTableView.dataSource  = self
        
        
    }
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    
    func dismissAnyAlertControllerIfPresent() {
        guard let window :UIWindow = UIApplication.shared.keyWindow , var topVC = window.rootViewController?.presentedViewController else {return}
        while topVC.presentedViewController != nil  {
            topVC = topVC.presentedViewController!
        }
        if topVC.isKind(of: UIAlertController.self) {
            topVC.dismiss(animated: false, completion: nil)
        }
    }
    var phonestoSMS = [String]()
    var initializersNames = [String]()
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        dismissAnyAlertControllerIfPresent()
        
        if motion == .motionShake {
            phonestoSMS = []
            initializersNames = []
            
            if contacts.count >= 5 {
                let number = Int.random(in: 1..<min(4, contacts.count))
                let randomlySelectedContacts = contacts[randomPick: number]
                for cont in randomlySelectedContacts {
                    for ctcNum: CNLabeledValue in cont.phoneNumbers {
                        if let fulPhone = ctcNum.value as? CNPhoneNumber {
                            if let ph = fulPhone.value(forKey: "digits") as? String{
                                // Alert the user that they cannot send text messages
                                phonestoSMS.append(ph)
                                if cont.givenName == ""{
                                    initializersNames.append(ph)
                                }
                                else {
                                    initializersNames.append("\(cont.givenName) \(cont.familyName)")
                                }
                                
                            }
                            
                            
                        }
                    }
                }
            }
            else {
                phonestoSMS = []
                initializersNames = []
                
                for cont in contacts {
                    for ctcNum: CNLabeledValue in cont.phoneNumbers {
                        if let fulPhone = ctcNum.value as? CNPhoneNumber {
                            if let ph = fulPhone.value(forKey: "digits") as? String{
                                // Alert the user that they cannot send text messages
                                phonestoSMS.append(ph)
                                
                            }
                            
                            
                        }
                    }
                }
            }
            
        }
        
        
        let alertController = UIAlertController(title: initializersNames.joined(separator: "\n "), message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("Promotions.Action.NoReturn", comment: "No,return"), style: UIAlertAction.Style.default, handler: nil)
        let sendAction = UIAlertAction(title: NSLocalizedString("Send", comment: "Send"), style: UIAlertAction.Style.default){ _ in
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.recipients = self.phonestoSMS
            let tempSMS = NSLocalizedString("LeadContactSelector.Action.SharingSMSMessage", comment: "Sharing SMS message")
                    
            composeVC.body = String.localizedStringWithFormat(tempSMS, self.fullname, self.generateURLShare(self.PHONENUMBER))
            
            // Present the view controller modally.
            if MFMessageComposeViewController.canSendText() {
                self.present(composeVC, animated: true, completion: nil)
            } else {
                // Alert the user that they cannot send text messages
                let alertController = UIAlertController(title: NSLocalizedString("LeadContactSelector.Action.CannotSendTextMessage", comment: "Cannot Send Text Message"), message: NSLocalizedString("LeadContactSelector.Action.YourDeviceUnableToSendMessages", comment: "Your device unable to send messages"), preferredStyle: UIAlertController.Style.alert)
                let dismissAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil)
                alertController.addAction(dismissAction)
                self.present(alertController, animated: true, completion: nil)
                
            }                            }
        
        alertController.addAction(dismissAction)
        alertController.addAction(sendAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func sendLeads(_ sender: Any) {
        if pickedPhones != []{
            phonestoSMS = []
            initializersNames = []
            for cont in contacts {
                for ctcNum: CNLabeledValue in cont.phoneNumbers {
                    if let fulPhone = ctcNum.value as? CNPhoneNumber {
                        if let ph = fulPhone.value(forKey: "digits") as? String{
                            if pickedPhones.contains(ph) {
                                phonestoSMS.append(ph)
                                if cont.givenName == ""{
                                    initializersNames.append(ph)
                                }
                                else {
                                    initializersNames.append("\(cont.givenName) \(cont.familyName)")
                                }
                            }
                        }
                        
                        
                    }
                }
            }
            
            displayMessageInterface()
        }
        else {
            // Alert the user that they cannot send text messages
            let alertController = UIAlertController(title: NSLocalizedString("LeadContactSelector.Action.CannotSendTextMessage", comment: "Cannot Send Text Message"), message: NSLocalizedString("LeadContactSelector.Action.SelectAlLeastUser", comment: "Select at least one user"), preferredStyle: UIAlertController.Style.alert)
            let dismissAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func generateURLShare(_ phone:String?)->String{
        return "https://leapper.com/a/pro/\(_id)"
    }
    
    @IBAction func cancelSelection(_ sender: Any) {
        pickedPhones = []
        if selected == false {
        }
        else {
            selectAllButton.isSelected = false
            selected = false
        }
        DispatchQueue.main.async {
            
            self.contactsListTableView.reloadData()
        }
        
    }
    
    func getContacts(){
        contacts = ContactHelper.getContacts()
        DispatchQueue.main.async {
            self.contactsListTableView.reloadData()
        }
    }
    
    func setImageText(){
        let iA = NSTextAttachment()
        iA.image = UIImage(named: "shake")
        let iOY: CGFloat = -5.0
        iA.bounds = CGRect(x: 0, y: iOY, width: iA.image!.size.width, height: iA.image!.size.height)
        let aS = NSAttributedString(attachment: iA)
        let t = NSMutableAttributedString(string: "")
        t.append(aS)
        let tAI = NSAttributedString(string: "shake_inf")
        t.append(tAI)
        info.attributedText = t
        
    }
    var fullname = ""
    
    func displayMessageInterface() {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = pickedPhones
        let tempSMS = NSLocalizedString("LeadContactSelector.Action.SharingSMSMessage", comment: "Sharing SMS message")
        composeVC.body = String.localizedStringWithFormat(tempSMS, self.fullname, self.generateURLShare(self.PHONENUMBER))
        
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("LeadContactSelector.Action.CannotSendTextMessage", comment: "Cannot Send Text Message"), message: NSLocalizedString("LeadContactSelector.Action.YourDeviceUnableToSendMessages", comment: "Your device unable to send messages"), preferredStyle: UIAlertController.Style.alert)
            let dismissAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


extension LeadContactSelector: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "cont", for: indexPath) as? LeadContactCollection {
            itemCell.contact = filteredData[indexPath.row]
            for ctcNum: CNLabeledValue in filteredData[indexPath.row].phoneNumbers {
                if let fulPhone = ctcNum.value as? CNPhoneNumber {
                    if let ph = fulPhone.value(forKey: "digits") as? String{
                        if pickedPhones.contains(ph) {
                            if !itemCell.checkbox.isSelected {
                                itemCell.checkbox.isSelected = true
                                itemCell.contentView.backgroundColor = UIColor(red: 240/256, green: 240/256, blue: 240/256, alpha: 1)
                            }
                        }
                        else {
                            if itemCell.checkbox.isSelected {
                                itemCell.checkbox.isSelected = false
                                itemCell.contentView.backgroundColor = .white
                            }
                        }
                    }
                }
            }
            
            return itemCell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cn = filteredData[indexPath.row]
        if selectAllButton.isSelected == true {
            selectAllButton.isSelected = false
            selected = false
        }
        for ctcNum: CNLabeledValue in cn.phoneNumbers {
            if let tempPhone = ctcNum.value as? CNPhoneNumber {
                if let checkedPhone = tempPhone.value(forKey: "digits") as? String{
                    if !pickedPhones.contains(checkedPhone){
                        pickedPhones.append(checkedPhone)
                    }
                    else {
                        pickedPhones.removeAll { $0 == checkedPhone }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.contactsListTableView.reloadData()
        }
    }
}

extension LeadContactSelector: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            leappingApi()
            if SessionManager.shared.isPro() {
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                    // parent.present(vc, animated: true, completion: nil)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc
                    
                }
            }else {
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "navClient") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc
                }
            }
            
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

extension LeadContactSelector: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = []
        if searchText.isEmpty {
            filteredData = contacts
        }
        else {
            for human in contacts {
                if human.givenName.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(human)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.contactsListTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        filteredData = contacts
        DispatchQueue.main.async {
            self.contactsListTableView.reloadData()
        }
    }
}
extension Array {
    subscript (randomPick n: Int) -> [Element] {
        var indices = [Int](0..<count)
        var randoms = [Int]()
        for _ in 0..<n {
            randoms.append(indices.remove(at: Int(arc4random_uniform(UInt32(indices.count)))))
        }
        return randoms.map { self[$0] }
    }
}
