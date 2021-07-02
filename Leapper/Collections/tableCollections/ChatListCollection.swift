//
//  ChatListCollection.swift
//  Leapper
//
//  Created by Kratos on 8/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit
class ChatListCollection: UITableViewCell {
        
    override func awakeFromNib () {
        super.awakeFromNib ()
        let longPress = UILongPressGestureRecognizer (target: self, action: #selector (self.longPress (gesture :)))
        longPress.minimumPressDuration = 1
        self.addGestureRecognizer (longPress)

    }
    
    @objc func longPress (gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let alertController = UIAlertController()
            
            let deleteAction = UIAlertAction(title:  NSLocalizedString("MessengerViewController.Action.Delete", comment: ""), style: UIAlertAction.Style.default, handler: nil)
            let muteAction = UIAlertAction(title:  NSLocalizedString("MessengerViewController.Action.MuteChat", comment: ""), style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(muteAction)

            alertController.addAction(deleteAction)
           
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Action.Cancel", comment: ""), style: .cancel, handler: {
                action in
                     // Called when user taps outside
            }))
            parent.present(alertController, animated: true, completion: nil)

        }
        if gesture.state == .ended {
        }
    }

    @IBOutlet weak var mainLay: UIView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    weak var parent:UIViewController!
    
    var chats: ChatListsModel?{
        didSet {
            time.text = setTimeFromJson(time: chats?.lastUpdateTime ?? "")
            fullname.text = chats?.fullname
            message.text = chats?.lastMessage
            setNewImage(linkToPhoto: chats?.avatar, imageInput: avatar, isRounded: true)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.clicked(_:)))
            mainLay.isUserInteractionEnabled = true
            mainLay.addGestureRecognizer(tap)
            
            if let unreadedMess = chats?.unreadedMess {
                counterLabel.text = "\(unreadedMess)"
                if unreadedMess == 0 {
                    let image1Attachment = NSTextAttachment()
                    let fullString = NSMutableAttributedString(string: "")
                    var imageOffsetY: CGFloat = -2.0
                    
                    if !chats!.isReaded{
                        image1Attachment.image = UIImage(named: "read")!.resize(maxWidthHeight: 14)
                        imageOffsetY = CGFloat(0.0)
                    }
                    else {
                        image1Attachment.image = UIImage(named: "sent")!.resize(maxWidthHeight: 13)
                        imageOffsetY = CGFloat(-3.0)
                    }
                    
                    image1Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: image1Attachment.image!.size.width, height: image1Attachment.image!.size.height)
                    
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    fullString.append(image1String)
                    
                    counterLabel.attributedText = fullString
                    counterLabel.backgroundColor = .clear
                }
                else {
                    counterLabel.isHidden = false
                    counterLabel.backgroundColor = UIColor(displayP3Red: 33/255, green: 133/255, blue: 247/255, alpha: 1)
                }
            }
            else {
                counterLabel.isHidden = true
            }
        }
    }
    
    
    @objc func clicked(_ sender: UITapGestureRecognizer? = nil){
        let messenger = parent.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController
        messenger.linkToAvatar = chats?.avatar
        messenger.isDeleted = chats!.isDeleted

        messenger.CHATTERPHONE = chats?.phoneNumber ?? ""
        messenger.chatRoomId = chats!.chatId
        messenger.fullnameText = chats?.fullname ?? ""
        messenger.idWhom = (chats?.idWhomUser)!
        messenger.roleWho = chats?.roleWhomUser
        parent.present(messenger, animated: true, completion: nil)
    }
}
