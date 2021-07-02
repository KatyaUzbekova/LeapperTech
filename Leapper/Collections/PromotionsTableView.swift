//
//  PromotionsTableView.swift
//  Leapper
//
//  Created by Kratos on 2/29/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import MessageUI
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire

extension PromotionsTableView: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result) {
            case .cancelled:
                print("Message was cancelled")
            case .failed:
                print("Message failed")
            case .sent:
                print("Message was sent")
            default:
            break
        }
    }
}



class PromotionsTableView: UITableViewCell {
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    let _id = KeychainWrapper.standard.string(forKey: "_id")!

    func apiSharePromotion() {

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        AF.request("https://api.leapper.com/api/mobi/sharePromo/\((self.promotions?._id)!)", method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).response { resp in

            if let err = resp.error{
                print(err)
                return
            }
            
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self.parent)
            }
            else if resp.response?.statusCode == 200 {
                UserDefaults.standard.set(true, forKey: "isFullyRegistered")
                self.parent.dismiss(animated: true, completion: nil)
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self.parent)
                    }
            }

        
    }
    }
    
    
    var phone = ""
    var userId = ""
    var userName = ""
    
    func getAllChatRoomsById(userId: String, phone: String, userName: String) {
        let messenger = (parent.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController)
        messenger.CHATTERPHONE = phone
        messenger.idWhom = userId
        messenger.fullnameText = userName
        messenger.promoId = self.promotions!._id
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
                                            self.parent.present(messenger, animated: true, completion: nil)
                                        }
                                    }
                                    return
                                }

                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            messenger.isChatExist = false
                            self.parent.present(messenger, animated: true, completion: nil)
                        }
                        
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self.parent)
                    self.getAllChatRoomsById(userId: userId, phone: phone, userName: userName)
                }
                else {
                    print("Something went wrong, try again")
                }
                
            }
        })
        task.resume()
    }
    
    @IBAction func interested(_ sender: Any) {
        getAllChatRoomsById(userId: userId, phone: phone, userName: userName)
    }

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    weak var parent:UIViewController!
   
    var promotions: PromotionModel?{
        didSet{
           setPromotions(promotions)
        }
    }
    func setPromotions(_ promotions:PromotionModel?){
        self.amount.text = "\((promotions?.amount)!)"
        self.name.text = promotions?.name
        self.desc.text = promotions?.description
        if verifyUrl(urlString: promotions?.imageUrl) {
            self.photo.sd_setImage(with: URL(string:(promotions?.imageUrl)!), placeholderImage: UIImage(named: "promotionTemp.png"))
        }
        else{
            self.photo.image = UIImage(named: "promotionTemp")
        }
    }
}
