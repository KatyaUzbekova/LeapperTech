//
//  ShareInChatViewController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 25.05.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import Contacts
import Alamofire
import SwiftKeychainWrapper
import MessageUI
import SwiftyJSON

class ShareInChatViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
     
    private let _id = KeychainWrapper.standard.string(forKey: "_id")!

    @IBOutlet weak var usersTableView: UITableView!
    var contacts = [CNContact]()

    func getContacts(){
        contacts = ContactHelper.getContacts()
        filteredData = contacts
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
    
    @IBOutlet weak var searchView: UISearchBar!
    var filteredData = [CNContact]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        getContacts()

        
        searchView.delegate = self
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
    }

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func setupGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleDismissGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleDismissGesture(gesture: UISwipeGestureRecognizer) -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    
    var _idPromo: String?
    var promotionName: String?
    var promotionDesc: String?
    var promotionAmount: String?
    var isWhoFullname: String?
}


extension ShareInChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "allUserContactsList", for: indexPath) as? LeadContactCollection {
            itemCell.contact = filteredData[indexPath.row]
            
            return itemCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Send promotion", message: "Promotion will be sent by Leapper or by SMS", preferredStyle: UIAlertController.Style.alert)
        let purchaseAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default){_ in
            for ctcNum: CNLabeledValue in self.filteredData[indexPath.row].phoneNumbers {
                if let fulPhone = ctcNum.value as? CNPhoneNumber {
                    if let ph = fulPhone.value(forKey: "digits") as? String{
                        self.getUserId(phone: ph, userName: self.filteredData[indexPath.row].givenName)
                    }
                }
            }
        }
        let purchaseAction2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel){_ in
        }
        alertController.addAction(purchaseAction2)

        alertController.addAction(purchaseAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertForMessagingWithMe() {
            let alertController = UIAlertController(title: "Unavailable", message: "You can not text yourself", preferredStyle: UIAlertController.Style.alert)
            let purchaseAction2 = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel){_ in
            }
            alertController.addAction(purchaseAction2)
            present(alertController, animated: true, completion: nil)
    }
    
    func getUserId(phone: String, userName: String) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        AF.request("https://api.leapper.com/api/mobi/getId/\(phone)", method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData {dataResponse in
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let id = JSON(dataResponse.data!)["id"].string!
                
                if id == self._id {
                    self.alertForMessagingWithMe()
                }
                else {
                    self.getAllChatRoomsById(userId: id, phone: phone, userName: userName)
                }
                break
            case 300:
                self.getPromotionApi(phone: phone)
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getUserId(phone: phone, userName: userName)
                break
            default:
                break
            }
        }
    }
    
    
    func getAllChatRoomsById(userId: String, phone: String, userName: String) {
        
        
        let messenger = (self.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController)
        messenger.CHATTERPHONE = phone
        messenger.idWhom = userId
        messenger.fullnameText = userName
        messenger.promoId = _idPromo!
        messenger.isPromoSharing = true
        messenger.isOpenedFromLists = true
        messenger.isChatExist = false

        let url = URL(string: "https://api.leapper.com/chats/getRooms/\(_id)")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
            //    print(httpResponse)
           //     print(String(bytes: data!, encoding: .utf8))

                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        let decodedData = JSON(safeData)["rooms"].array ?? []
                        for i in 0..<decodedData.count {
                            let participants = decodedData[i]["participants"].array ?? []
                            for participant in 0..<participants.count {

                                if participants[participant]["userId"].string ?? "" == (userId) {
                                    let chatId = decodedData[i]["_id"].string
                                    DispatchQueue.main.async {
                                        if let existingChatId = chatId{
                                            messenger.isChatExist = true
                                            messenger.chatRoomId = existingChatId
                                            self.present(messenger, animated: true, completion: nil)
                                        }
                                    }
                                    return
                                }

                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            messenger.isChatExist = false
                            self.present(messenger, animated: true, completion: nil)
                        }
                        
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getAllChatRoomsById(userId: userId, phone: phone, userName: userName)
                }
                else {
                    print("Something went wrong, try again")
                }
                
            }
        })
        task.resume()
    }


    func getPromotionApi(phone: String) {
        
        /*
         method to send GET request to server and receive JSON with mutuals users
         */
        
        let promotionsApiURL = "https://api.leapper.com/api/mobi/getIdPromo/\(_idPromo!)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        AF.request(promotionsApiURL, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { dataResponse in
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                let jsonData = JSON(data)
                self.promotionName = jsonData["promo"]["title"].string
                self.promotionAmount = jsonData["promo"]["discount"].string
                self.promotionDesc = jsonData["promo"]["description"].string
                self.isWhoFullname = "Leapper User"
                
                self.displayMessageInterface(phone: phone)
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getPromotionApi(phone: phone)
                break
            default:
                break
            }
        }
    }
    func displayMessageInterface(phone: String) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [phone]
        let recommendedString = NSLocalizedString("FeedPromoTableViewCell.Text.TextForSharing", comment: "Sharing promo test for SMS")
        let finalString = String.localizedStringWithFormat(recommendedString, promotionName ?? "promotion",promotionDesc ?? "",promotionAmount ?? "0", isWhoFullname ?? "", KeychainWrapper.standard.string(forKey: "_id")!)
        
        print(finalString)
        composeVC.body = String.localizedStringWithFormat(finalString)
        
        
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




extension ShareInChatViewController: UISearchBarDelegate {
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
            self.usersTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        filteredData = contacts
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
}
