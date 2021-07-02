//
//  Community.swift
//  Leapper
//
//  Created by Kratos on 1/24/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftKeychainWrapper
import SwiftyJSON

class CommunityCollectionView: UITableViewCell {
     var proView:ProfileViewPro!
     var clientView:ProfileViewClient!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var chatLayer: UIView!
    @IBOutlet weak var mainLayer: UIView!
    @IBOutlet weak var fullname: UILabel!
    
    @IBOutlet weak var thanxIcon: UIImageView!
    
    @IBOutlet weak var thanx: UILabel!
    
    @IBOutlet weak var leapps: UILabel!
    
    @IBOutlet weak var community: UILabel!
    weak var parent:UIViewController!

    var messenger:ParticularChatViewController!

    var communityUsers: ClientsModel? {
        didSet{
            setClickListener()
            fullname.text = communityUsers!.fullname
            thanx.text = communityUsers!.leappsCount
            community.text = communityUsers?.communityCount ?? "0"
            leapps.text = communityUsers!.thanksCount
            setNewImage(linkToPhoto: communityUsers?.avatar, imageInput: self.avatar, isRounded: true)
            
            
            if communityUsers?.isPro == .client {
                thanx.isHidden = true
                thanxIcon.isHidden = true
            }
            else {
                thanx.isHidden = false
                thanxIcon.isHidden = false
            }
            self.messenger = self.parent.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController
            self.messenger.linkToAvatar = self.communityUsers?.avatar
            self.messenger.fullnameText = self.communityUsers?.fullname ?? ""
            self.messenger.idWhom = (self.communityUsers?._id)!
            self.messenger.roleWho = self.communityUsers?.isPro
            self.messenger.isOpenedFromLists = true
        }
        
        
        
    }
    @objc func clickedUser(){
        switch communityUsers?.isPro {
        case .client:
            let cl = parent.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            cl!._id = communityUsers!._id
            parent.present(cl!, animated: true, completion: nil)
            break
        case .professional:
            let proView = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            proView?._id = communityUsers!._id
            proView?.NAME = communityUsers!.fullname
            parent.present(proView!, animated: true, completion: nil)
            break
        default:
            break
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
    
    func getAllChatRoomsById() {
        let _id = KeychainWrapper.standard.string(forKey: "_id")!
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
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
                if httpResponse.statusCode == 200{
                    if let safeData = data {
                        let decodedData =  JSON(safeData)["rooms"].array ?? []

                        for i in 0..<decodedData.count {
                            let participants = decodedData[i]["participants"].array ?? []
                            for participant in 0..<participants.count {
                                if participants[participant]["userId"].string ?? "" == (self.communityUsers?._id)! {
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
                        }
                    }
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
}
