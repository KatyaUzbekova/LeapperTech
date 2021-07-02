//
//  ClientsTableViewCell.swift
//  Leapper
//
//  Created by Kratos on 1/24/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftKeychainWrapper
import SwiftyJSON

class ClientsTableViewCell: UITableViewCell {

    weak var parent:UIViewController!
    var messenger:ParticularChatViewController!
    @IBOutlet weak var mainLayer: UIView!
    @IBOutlet weak var chatLayer: UIView!
    @objc func clicked(){
        parent.present(messenger, animated: true, completion: nil)
    }
    @IBOutlet weak var avatar: UIImageView!
    var proView:ProfileViewPro!
    var clientView:ProfileViewClient!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var thanx: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var comm: UILabel!
    @IBOutlet weak var leappsIcon: UIImageView!
       var clients: ClientsModel? {
            didSet{
                setClickListener()
                fullname.text = clients!.fullname
                comm.text = clients?.communityCount ?? "0"
                thanx.text = clients!.leappsCount
                leapps.text = clients!.thanksCount
                setNewImage(linkToPhoto: clients?.avatar, imageInput: self.avatar, isRounded: true)
                self.messenger = (self.parent.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController)
                self.messenger.linkToAvatar = self.clients?.avatar
                self.messenger.fullnameText = self.clients?.fullname ?? ""
                self.messenger.idWhom = (self.clients?._id)!
                self.messenger.roleWho = self.clients?.isPro
                self.messenger.isOpenedFromLists = true
                if clients?.isPro == .client {
                    thanx.isHidden = true
                    leappsIcon.isHidden = true
                }
                else {
                    thanx.isHidden = false
                    leappsIcon.isHidden = false
                }
            }
        }
        
     func setClickListener(){
        mainLayer.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickedUser))
        mainLayer.addGestureRecognizer(tap)
        
        chatLayer.isUserInteractionEnabled = true
        let mc = UITapGestureRecognizer(target: self, action: #selector(openChat))
        chatLayer.addGestureRecognizer(mc)
     }
    var chatId: String?
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    private let _id = KeychainWrapper.standard.string(forKey: "_id")!

    func getAllChatRoomsById() {
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
                print(httpResponse)
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        let decodedData =  JSON(safeData)["rooms"].array ?? []
                        for i in 0..<decodedData.count {
                            let participants = decodedData[i]["participants"].array ?? []
                            for participant in 0..<participants.count {

                                if participants[participant]["userId"].string ?? "" == (self.clients?._id)! {
                                    let chatId = decodedData[i]["_id"].string
                                    DispatchQueue.main.async {
                                        if let existingChatId = chatId{
                                            self.messenger.isChatExist = true
                                            self.messenger.chatRoomId = existingChatId
                                            self.parent.present(self.messenger, animated: true, completion: nil)
                                        }
                                    }
                                    return
                                }

                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.messenger.isChatExist = false
                            self.parent.present(self.messenger, animated: true, completion: nil)
                        }                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self.parent)
                    self.getAllChatRoomsById()
                }
                else {
                    print("Something went wrong, try again")
                }
                
            }
        })
        task.resume()
    }
    @objc func openChat() {
        getAllChatRoomsById()
    }
    @objc func clickedUser(){
        switch clients?.isPro {
        case .client:
            let cl = parent.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            cl?._id = clients!._id
            parent.present(cl!, animated: true, completion: nil)
            break
        case .professional:
            let proView = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            proView?._id = clients!._id
            proView?.NAME = clients!.fullname
            parent.present(proView!, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}


