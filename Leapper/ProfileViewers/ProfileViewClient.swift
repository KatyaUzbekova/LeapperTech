//
//  ProfileViewClient.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class ProfileViewClient: UIViewController {
    
    var _id = ""
    var allUsers = [AllUsers]()
    @IBOutlet weak var community: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var leappIcon: UIImageView!
    @IBOutlet weak var thanx: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var mainTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        setInfoClientApi()
    }
    
    @IBAction func callToClient(_ sender: Any) {
        if phone.count > 0 {
            if let url = URL(string: "tel://\(phone)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        }
    }
    
    
    func getAllChatRoomsById() {
        let messenger = self.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController
        messenger.linkToAvatar = avatarLink
        messenger.fullnameText = fullname.text ?? "Leapper Client"
        messenger.idWhom = _id
        messenger.roleWho = UsersType.client
        messenger.isOpenedFromLists = true
        let _idCheck = KeychainWrapper.standard.string(forKey: "_id")!
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/chats/getRooms/\(_idCheck)")! //change the url
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
                if httpResponse.statusCode == 200{
                    if let safeData = data {
                        let decodedData =  JSON(safeData)["rooms"].array ?? []

                        for i in 0..<decodedData.count {
                            let participants = decodedData[i]["participants"].array ?? []
                            for participant in 0..<participants.count {
                                if participants[participant]["userId"].string ?? "" == self._id {
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
                    self.getAllChatRoomsById()
                }
                else {
                    print("Something went wrong, try again")
                }
                
            }
        })
        task.resume()
    }
    @IBAction func chatWithClient(_ sender: Any) {
        getAllChatRoomsById()
    }
    
    var phone = ""
    var avatarLink: String?
    func setInfoClientApi() {
        
        /*
         method to send GET request to server and receive JSON with user data
         */
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/getUser/\(_id)")! //change the url
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
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        do {
                            let json = JSON(safeData)
                            self.phone = "\(json["userInfo"]["phone"])"
                            DispatchQueue.main.async {
                                let namecheck = json["userInfo"]["name"].string ?? ""
                                let lastcheck = json["userInfo"]["lastName"].string ?? ""
                                let fullnameApiWho = "\(namecheck + " " + lastcheck)"

                                self.fullname.text = fullnameApiWho
                                self.avatarLink = json["userInfo"]["avatar"].string
                                setNewImage(linkToPhoto: json["userInfo"]["avatar"].string, imageInput: self.avatar, isRounded: true)
                                let allLeapps = json["leappsGiven"]
                                for i in 0..<allLeapps.count {
                                    self.allUsers.append(AllUsers(isPro: true, phone: "", fullName: allLeapps[i]["whom"]["name"].string! + " " + allLeapps[i]["whom"]["lastName"].string!, profession: allLeapps[i]["whom"]["portfolio"]["jobName"].string?.lowercased().capitalizingFirstLetter() ?? "New user", linkToAvatar: allLeapps[i]["whom"]["avatar"].string ?? "", mutualsCount: "0", _id: allLeapps[i]["whom"]["_id"].string!, role: "professional"))
                                }
                            }
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.setInfoClientApi()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
                
            }
        })
        task.resume()
    }
    
    
    
    
}
extension ProfileViewClient: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "mainTable", for: indexPath) as? SearchTableViewCell{
            itemCell.user = allUsers[indexPath.row]
            itemCell.parent = self.self
            return itemCell
        }
        return UITableViewCell()
    }
    
    
}
