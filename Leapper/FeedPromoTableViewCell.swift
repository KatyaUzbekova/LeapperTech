//
//  FeedPromoTableViewCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 16.03.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class FeedPromoTableViewCell: UITableViewCell {

    var whoView = UIView()
    var whomView = UIView()
    var isNewLabel = UILabel()
    var promotionName =  UILabel()
    var promotionPic = UIImageView()
    var promotionDesc = UILabel()
    var promotionAmount = UILabel()
    var promotionInterestedButton = UIButton()
    var promotionShareButton = UIButton()

    var isWhoFullname = UILabel()
    weak var parent: UIViewController!
    var avatar = UIImageView()
    var time = UILabel()
    var reccomendedOnLabel = UILabel()

    var backgroundAvatar = UIView()
    
    
    var dividerView = UIView()
    
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

    func getAllChatRoomsById() {
        let messenger = (parent.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController)
        messenger.CHATTERPHONE = ""
        messenger.idWhom = chatMessage._idWho
        messenger.fullnameText = chatMessage.fullname
        messenger.promoId = chatMessage.idPromo!
        messenger.isPromoSharing = true
        messenger.isOpenedFromLists = true
        messenger.isChatExist = false
        let _idMy = KeychainWrapper.standard.string(forKey: "_id")!

        if _idMy == self.chatMessage._idWho {
            let alertController = UIAlertController(title: "Unavailable", message: "You can not text yourself", preferredStyle: UIAlertController.Style.alert)
            let purchaseAction2 = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel){_ in
            }
            alertController.addAction(purchaseAction2)
            parent.present(alertController, animated: true, completion: nil)
            return
        }
        let url = URL(string: "https://api.leapper.com/chats/getRooms/\(_idMy)")! //change the url
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
                        let decodedData = JSON(safeData)["rooms"].array ?? []
                        for i in 0..<decodedData.count {
                            let participants = decodedData[i]["participants"].array ?? []
                            for participant in 0..<participants.count {

                                if participants[participant]["userId"].string ?? "" == self.chatMessage._idWho{
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
                    self.getAllChatRoomsById()
                }
                else {
                    print("Something went wrong, try again")
                }
                
            }
        })
        task.resume()
    }
    
    @objc func imterestedPromotionAction(sender: UIButton!) {
        print("РАБОТАЕТ")
        getAllChatRoomsById()
    }
    
    @objc func buttonShareAction(sender: UIButton!) {
        ApiServices.shared.sharePromotion(isShared: chatMessage.isShared, lastController: parent, _idPromo: chatMessage.idPromo!, isMy: chatMessage._idWho == KeychainWrapper.standard.string(forKey: "_id")!)
    }
    
    
    var chatMessage: FeedsModel! {
        didSet {
            if chatMessage.isNew {
                isNewLabel.isHidden = false
            }
            else {
                isNewLabel.isHidden = true
            }
            
            setNewImage(linkToPhoto: chatMessage.isWhoAvatar, imageInput: avatar, isRounded: true)
            DispatchQueue.main.async {
                self.time.text = setTimeFromJson(time: self.chatMessage.time)
                self.isWhoFullname.text = self.chatMessage.fullname
                self.promotionName.text = self.chatMessage.promName
                self.promotionDesc.text = self.chatMessage.promDesc
                self.promotionAmount.text = self.chatMessage.promAmount

                
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openRecommender(_:)))
            self.promotionName.lineBreakMode = .byCharWrapping
            self.promotionDesc.lineBreakMode = .byCharWrapping
            self.promotionAmount.lineBreakMode = .byCharWrapping
            whoView.isUserInteractionEnabled = true
            whoView.addGestureRecognizer(tap)

            setNewImage(linkToPhoto: chatMessage.promPic, imageInput: promotionPic, isRounded: false, placeholderPic: "promotionTemp")

        }
    }

    func setTextsFeatures() {
        time.font = UIFont(name: "roboto", size: 11)
        time.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        isWhoFullname.font = UIFont(name: "roboto", size: 14)
        reccomendedOnLabel.font = UIFont(name: "roboto", size: 13)
        reccomendedOnLabel.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        
        isNewLabel.font = UIFont(name: "roboto", size: 14)
        isNewLabel.textColor = UIColor(displayP3Red: 252/255, green: 33/255, blue: 95/255, alpha: 1)
        promotionAmount.font = UIFont(name: "roboto", size: 14)
        promotionName.font = UIFont(name: "roboto-bold", size: 14)
        promotionDesc.font = UIFont(name: "roboto", size: 14)

    }

    
    @objc func openRecommender(_ sender: UITapGestureRecognizer? = nil) {
        if ReachabilityTest.isConnectedToNetwork() {

        switch chatMessage?.roleWho {
        case .client:
            let cl = parent?.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            cl?._id = chatMessage!._idWho
            parent!.present(cl!, animated: true, completion: nil)
            break
        case .professional:
            let proView = parent?.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            proView?._id = chatMessage!._idWho
            proView?.NAME = chatMessage!.fullname
            parent!.present(proView!, animated: true, completion: nil)
            break
        default:
            break
        }
        }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTextsFeatures()
        
        promotionPic.layer.cornerRadius = 20
        promotionPic.clipsToBounds = true
        promotionPic.contentMode = .scaleAspectFill
        reccomendedOnLabel.text = NSLocalizedString("FeedPromoTableViewCell.Action.SharedPromotion", comment: "Share promotion in Feed")
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true


        backgroundAvatar.backgroundColor = UIColor(displayP3Red: 255/255, green: 199/255, blue: 0, alpha: 1)
        dividerView.backgroundColor = UIColor(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        
        let constraintsWhoView = [
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            whoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            whoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            whoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            
            whomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            whomView.topAnchor.constraint(equalTo: whoView.bottomAnchor, constant: 0),
            whomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            whomView.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -10),
            
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            dividerView.heightAnchor.constraint(equalToConstant: 3),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

        ]
        
        let constraintsImage = [

            
            isNewLabel.trailingAnchor.constraint(equalTo: whoView.trailingAnchor, constant: -10),
            isNewLabel.topAnchor.constraint(equalTo: whoView.topAnchor, constant: 10),

            backgroundAvatar.topAnchor.constraint(equalTo: whoView.topAnchor, constant: 10),
            backgroundAvatar.leadingAnchor.constraint(equalTo: whoView.leadingAnchor, constant: 25),
            backgroundAvatar.widthAnchor.constraint(equalToConstant: 63),
            backgroundAvatar.heightAnchor.constraint(equalToConstant: 63),
            backgroundAvatar.bottomAnchor.constraint(equalTo: whoView.bottomAnchor, constant: 0),
            
            avatar.widthAnchor.constraint(equalToConstant: 60),
            avatar.heightAnchor.constraint(equalToConstant: 60),
            avatar.centerYAnchor.constraint(equalTo: backgroundAvatar.centerYAnchor, constant: 0),
            avatar.centerXAnchor.constraint(equalTo: backgroundAvatar.centerXAnchor, constant: 0),
            
            time.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            time.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            isWhoFullname.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 8),
            isWhoFullname.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            reccomendedOnLabel.topAnchor.constraint(equalTo: isWhoFullname.bottomAnchor, constant: 8),
            reccomendedOnLabel.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            
            promotionPic.topAnchor.constraint(equalTo: whomView.topAnchor, constant: 10),
            promotionPic.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            promotionPic.widthAnchor.constraint(equalToConstant: 80),
            promotionPic.heightAnchor.constraint(equalToConstant: 80),
            
            promotionName.topAnchor.constraint(equalTo: whomView.topAnchor, constant: 16),
            promotionName.leadingAnchor.constraint(equalTo: promotionPic.trailingAnchor, constant: 9),
            promotionName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),

            promotionDesc.topAnchor.constraint(equalTo: promotionName.bottomAnchor, constant: 5),
            promotionDesc.leadingAnchor.constraint(equalTo: promotionPic.trailingAnchor, constant: 9),
            promotionDesc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),
            promotionAmount.topAnchor.constraint(equalTo: promotionDesc.bottomAnchor, constant: 10),

            promotionAmount.leadingAnchor.constraint(equalTo: promotionPic.trailingAnchor, constant: 9),

            promotionAmount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),

            promotionInterestedButton.topAnchor.constraint(equalTo: promotionAmount.bottomAnchor, constant: 12),
            promotionInterestedButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            promotionInterestedButton.trailingAnchor.constraint(equalTo: promotionShareButton.leadingAnchor, constant: -30),


            promotionInterestedButton.widthAnchor.constraint(equalToConstant: 200),
            promotionInterestedButton.heightAnchor.constraint(equalToConstant: 40),

            promotionInterestedButton.bottomAnchor.constraint(equalTo: whomView.bottomAnchor, constant: 0),

            promotionShareButton.topAnchor.constraint(equalTo: promotionAmount.bottomAnchor, constant: 12),

            promotionShareButton.widthAnchor.constraint(equalToConstant: 100),
            promotionShareButton.heightAnchor.constraint(equalToConstant: 40),

            promotionShareButton.bottomAnchor.constraint(equalTo: whomView.bottomAnchor, constant: 0),
            
        ]
        promotionName.text = " "
        promotionDesc.text = " "
        promotionAmount.text = " "
        isNewLabel.text = NSLocalizedString("FeedCells.Label.New", comment: "NEW")

        promotionInterestedButton.setTitleColor(.black, for: .normal)
        promotionInterestedButton.layer.cornerRadius = 20
        
        promotionInterestedButton.text(NSLocalizedString("FeedPromoTableViewCell.Action.InterestedPromotion", comment: "Interested promotion action"))
        
        promotionShareButton.text(NSLocalizedString("FeedCells.Label.ShareFeed", comment: "Share by Feed"))
        promotionShareButton.layer.cornerRadius = 20
        promotionShareButton.setTitleColor(.black, for: .normal)
        
        promotionInterestedButton.backgroundColor = UIColor(displayP3Red: 225/255, green: 217/255, blue: 246/255, alpha: 0.8)
        promotionInterestedButton.titleLabel?.font =  UIFont(name: "roboto", size: 15)

        promotionShareButton.backgroundColor = UIColor(displayP3Red: 225/255, green: 217/255, blue: 246/255, alpha: 0.8)
        promotionShareButton.titleLabel?.font =  UIFont(name: "roboto", size: 15)
        
        backgroundAvatar.translatesAutoresizingMaskIntoConstraints = false
        backgroundAvatar.layer.cornerRadius = 63/2
        avatar.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        reccomendedOnLabel.translatesAutoresizingMaskIntoConstraints = false
        isWhoFullname.translatesAutoresizingMaskIntoConstraints = false
        
        whoView.translatesAutoresizingMaskIntoConstraints = false
        whomView.translatesAutoresizingMaskIntoConstraints = false
        isNewLabel.translatesAutoresizingMaskIntoConstraints = false

        promotionName.translatesAutoresizingMaskIntoConstraints = false
        promotionName.numberOfLines = 0
        promotionPic.translatesAutoresizingMaskIntoConstraints = false
        promotionDesc.translatesAutoresizingMaskIntoConstraints = false
        promotionDesc.numberOfLines = 0
        
        promotionAmount.translatesAutoresizingMaskIntoConstraints = false
        promotionAmount.numberOfLines = 0
        promotionInterestedButton.translatesAutoresizingMaskIntoConstraints = false
        promotionShareButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(whoView)
        contentView.addSubview(whomView)
        whoView.addSubview(isNewLabel)

        whoView.addSubview(backgroundAvatar)
        whoView.addSubview(avatar)
        
        whoView.addSubview(time)
        whoView.addSubview(isWhoFullname)
        whoView.addSubview(reccomendedOnLabel)
        
        
        whomView.addSubview(promotionPic)
        whomView.addSubview(promotionName)
        whomView.addSubview(promotionDesc)
        whomView.addSubview(promotionAmount)
        whomView.addSubview(promotionInterestedButton)
        whomView.addSubview(promotionShareButton)
        
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate(constraintsWhoView)
        NSLayoutConstraint.activate(constraintsImage)
        
        promotionInterestedButton.addTarget(self, action: #selector(imterestedPromotionAction), for: .touchUpInside)
        promotionShareButton.addTarget(self, action: #selector(buttonShareAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
