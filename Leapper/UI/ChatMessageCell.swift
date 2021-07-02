//
//  ChatMessageCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 03.02.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import Nantes
import SwiftKeychainWrapper

class ChatMessageCell: UITableViewCell {
    
    //MARK: for promotion
    let promoView = UIView()
    let promoDescriptionLabel = UILabel()
    let promoImage = UIImageView()
    let promoAmountLabel = UILabel()
    let promoNameLabel = UILabel()
    let markedPromoLabel = UILabel()
    
    
    //MARK: message blocks
    let dataLabel = UILabel()
    let dataView1 = UIView()
    let dataView2 = UIView()
    let messageLabel2: NantesLabel = .init(frame: .zero)
    let messageLabel = UILabel()
    let timeLabel = UILabel()
    let bubbleBackColor = UIView()
    var imageAvatar = UIImageView()
    var parentReg: RegistrationPro!
    var parentRegClient: RegistrationClient!
    var regRole = "pro"
    
    var leadingConstraintsPromo: NSLayoutConstraint!
    var heightPromoImageConstraint: NSLayoutConstraint!
    var trailingContraintPromo: NSLayoutConstraint!
    var leadingConstraints: NSLayoutConstraint!
    var promotionContraints = [NSLayoutConstraint]()
    var leadingConstraints2: NSLayoutConstraint!
    var leadingConstraintsTime: NSLayoutConstraint!
    var trailingContraintTime: NSLayoutConstraint!
    var hewbrewContraintTime: NSLayoutConstraint!
    
    var trailingContraint: NSLayoutConstraint!
    
    //MARK: objc-C interaction to open agreement, used in Registration Client and Registration Pro
    
    @objc func openAgreement(_ sender: UITapGestureRecognizer? = nil) {
        let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") // file path for file "data.txt"
        do {
            let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let alertController = UIAlertController(title: NSLocalizedString("ChatMessageCell.Agreement", comment: ""), message: string, preferredStyle: .alert)
            
            //What happended on agree button, only 1 button
            let agreeAction = UIAlertAction(title: NSLocalizedString("ChatMessageCell.Agree", comment: ""), style: .default) { (action) in
                if self.regRole == "pro" {
                    self.parentReg.isHiddenApprove()
                }
                else {
                    self.parentRegClient.isHiddenApprove()
                }
            }
            alertController.addAction(agreeAction)
            if regRole == "pro" {
                parentReg.present(alertController, animated: true) {}
            }
            else {
                parentRegClient.present(alertController, animated: true) {}
            }
            
        }
        catch {
            
        }
        
    }
    
    
    let notificationGrayColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
    
    //MARK: set text features
    func setTextsFeatures() {
        timeLabel.font = UIFont(name: "roboto", size: 11)
        timeLabel.textColor = notificationGrayColor
        messageLabel.font = UIFont(name: "roboto", size: 14)
        dataLabel.textColor = notificationGrayColor
        dataLabel.font = UIFont(name: "roboto", size: 11)
        dataView1.backgroundColor = notificationGrayColor
        dataView2.backgroundColor = notificationGrayColor
        markedPromoLabel.textColor = notificationGrayColor
        markedPromoLabel.font = UIFont(name: "roboto", size: 11)
        promoDescriptionLabel.font = UIFont(name: "roboto", size: 14)
        promoDescriptionLabel.numberOfLines = 0
        promoAmountLabel.font = UIFont(name: "roboto", size: 14)
        promoAmountLabel.numberOfLines = 0
        promoNameLabel.font = UIFont(name: "roboto", size: 14)
        promoNameLabel.numberOfLines = 0
    }
    
    //MARK: setup interaction for agreement picture, used in registration
    func agreementCheck() {
        if chatMessage.isAgreement {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openAgreement(_:)))
            messageLabel.isUserInteractionEnabled = true
            messageLabel.addGestureRecognizer(tap)
        }
    }
    
    //MARK: function to convert JSON time to time, used in the app + add images to give the user understanding or is message is readed or only sent, we took parameters:
    /**
     JSON format "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
     checker isBot, bot - another uder, notBot - this user
     chatMessage.timeOfMessage - time ot the message in specific JSON format
     chatMessage.newDateLabel - to setup date on the top of messagem Bool value, calculated in parent view controller, used in messages
     */
    func timeAndReadSetup() {
        
        if !chatMessage.isBot {
            
            let image1Attachment = NSTextAttachment()
            let fullString = NSMutableAttributedString(string: "")
            var imageOffsetY: CGFloat = -2.0
            let isReadedMessage = !(chatMessage.isReaded ?? true)
            if isReadedMessage{
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
            
            fullString.append(NSMutableAttributedString(string: "  "))
            
            if let timeGiven = chatMessage.timeOfMessage {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let timeInDateFormat = dateFormatter.date(from: timeGiven)
                dateFormatter.dateFormat = "dd-MM-yyyy"
                if chatMessage.newDateLabel {
                    dataView1.isHidden = false
                    dataView2.isHidden = false
                    dataLabel.text = dateFormatter.string(from: timeInDateFormat!)
                }
                else {
                    dataView1.isHidden = true
                    dataView2.isHidden = true
                    dataLabel.text = ""
                }
                
                fullString.append(NSMutableAttributedString(string: "\(setTimeFromJson(time:  timeGiven, isOnlyTimeNeeded: true))"))
                
            }
            else {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                dataView1.isHidden = true
                dataView2.isHidden = true
                let currentTime = formatter.string(from: Date())
                formatter.dateFormat = "dd-MM-yyyy"
                let currentData = formatter.string(from: Date())
                
                if chatMessage.newDateLabel {
                    dataView1.isHidden = false
                    dataView2.isHidden = false
                    dataLabel.text = currentData
                }
                else {
                    dataView1.isHidden = true
                    dataView2.isHidden = true
                    dataLabel.text = ""
                }
                
                fullString.append(NSMutableAttributedString(string: currentTime))
            }
            
            timeLabel.attributedText = fullString
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let timeInDateFormat = dateFormatter.date(from: chatMessage.timeOfMessage!)
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            if chatMessage.newDateLabel {
                dataView1.isHidden = false
                dataView2.isHidden = false
                dataLabel.text = dateFormatter.string(from: timeInDateFormat!)
            }
            else {
                dataView1.isHidden = true
                dataView2.isHidden = true
                
                dataLabel.text = ""
            }
            
            timeLabel.text = setTimeFromJson(time: chatMessage.timeOfMessage!, isOnlyTimeNeeded: true)
        }
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage == "he" {
            trailingContraintTime.isActive = false
            hewbrewContraintTime.isActive = true
            leadingConstraintsTime.isActive = false
        }
    }
    
    //MARK: function to setup messageView in case it is usual message, not promotion
    /**
     chatMessage.isChatCell - check is cell for chat or for registration
     trailingContraintTime.isActive && leadingConstraintsTime.isActive - to setup constraints for message withour avatar in the beginning
     chatMessage.image -  to check, if message is image - used in registrations when avatar setup or agreement
     leadingConstraints.isActive && trailingContraint.isActive && leadingConstraints2.isActive - constraints to setup message bubble for you and user with whom you talk
     */
    func notPromotionSetup() {
        
        if chatMessage.isChatCell {
            trailingContraintTime.isActive = true
            leadingConstraintsTime.isActive = false
            timeLabel.isHidden = false
            timeAndReadSetup()
        }
        else {
            trailingContraintTime.isActive = true
            leadingConstraintsTime.isActive = false
            
            imageAvatar.image = UIImage(named: chatMessage.imagePathName ?? "david_big.png")!
            dataView1.isHidden = true
            dataView2.isHidden = true
            
            let fullString = NSMutableAttributedString(string: "")
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let currentTime = formatter.string(from: Date())
            fullString.append(NSMutableAttributedString(string: currentTime))
            timeLabel.attributedText = fullString
        }
        
        
        if chatMessage.image != nil {
            let image1Attachment = NSTextAttachment()
            let fullString = NSMutableAttributedString(string: "")
            
            
            if !chatMessage.isAgreement {
                image1Attachment.image = chatMessage.image!.resize(maxWidthHeight: 100)?.roundedImage
            }
            else {
                image1Attachment.image = chatMessage.image!.resize(maxWidthHeight: 100)
            }
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
            messageLabel.attributedText = fullString
            bubbleBackColor.backgroundColor = .clear
        }
        else {
            messageLabel.text = chatMessage.messages
            bubbleBackColor.layer.cornerRadius = 20
            
        }
        if chatMessage.isBot {
            imageAvatar.isHidden = false
            trailingContraint.isActive = false
            
            if chatMessage.isChatCell {
                leadingConstraints2.isActive = true
                leadingConstraints.isActive = false
            }
            else {
                leadingConstraints.isActive = true
                leadingConstraints2.isActive = false
                
            }
        }
        else {
            imageAvatar.isHidden = true
            leadingConstraints.isActive = false
            trailingContraint.isActive = true
            leadingConstraints2.isActive = false
            
        }
    }
    
    
    //MARK: parent View Controller to make operations with controller
    weak var parent: UIViewController!
    
    var withWhomId: String!
    
    //MARK: open profile in promotions
    @objc func openProfile(_ sender: UITapGestureRecognizer? = nil) {
        let proView = parent?.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
        proView?._id = chatMessage!.promotion!.senderId
        parent!.present(proView!, animated: true, completion: nil)
    }
    
    //MARK: open profile in promotions
    func openProfileInPromotions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openProfile(_:)))
        markedPromoLabel.isUserInteractionEnabled = true
        markedPromoLabel.addGestureRecognizer(tap)
    }
    
    //MARK: setup data from parent View Controller
    var chatMessage: MessageModel! {
        didSet {
            bubbleBackColor.backgroundColor = chatMessage.isBot ? UIColor(red: 240/256, green: 240/256, blue: 240/256, alpha: 1): UIColor(red: 238/256, green: 216/256, blue: 242/256, alpha: 1)
            
            agreementCheck()
            if let promotion = chatMessage.promotion {
                timeAndReadSetup()
                NSLayoutConstraint.activate(promotionContraints)
                
                if promotion.senderId == KeychainWrapper.standard.string(forKey: "_id")! {
                    markedPromoLabel.text = NSLocalizedString("ChatMessageCell.SharedPromotion", comment: "")
                }
                else {
                    markedPromoLabel.text = "Click to see creator"
                }
                openProfileInPromotions()
                
                messageLabel.isHidden = true
                promoView.isHidden = false
                trailingContraintTime.isActive = true
                leadingConstraintsTime.isActive = false
                timeLabel.isHidden = false
                
                setNewImage(linkToPhoto: promotion.imageUrl, imageInput: promoImage, isRounded: false, placeholderPic: "promotionTemp")
                promoNameLabel.text = promotion.name
                promoAmountLabel.text = promotion.amount
                promoDescriptionLabel.text = promotion.description
                bubbleBackColor.layer.cornerRadius = 20
                imageAvatar.isHidden = true
                
                if chatMessage.isBot {
                    leadingConstraintsPromo.isActive = true
                    trailingContraintPromo.isActive = false
                    trailingContraint.isActive = false
                    leadingConstraints2.isActive = true
                    leadingConstraints.isActive = false
                }
                else {
                    leadingConstraintsPromo.isActive = true
                    trailingContraintPromo.isActive = false
                    leadingConstraints.isActive = false
                    trailingContraint.isActive = true
                    leadingConstraints2.isActive = false
                }
                heightPromoImageConstraint.isActive = true
                
            }
            else {
                NSLayoutConstraint.deactivate(promotionContraints)
                
                heightPromoImageConstraint.isActive = false
                trailingContraintPromo.isActive = false
                leadingConstraintsPromo.isActive = false
                
                markedPromoLabel.text = ""
                
                promoView.isHidden = true
                messageLabel.isHidden = false
                notPromotionSetup()
            }
        }
    }
    
    //MARK: setup features
    func imagesFeaturesSetup() {
        promoImage.layer.cornerRadius = 10
        promoImage.contentMode = .scaleAspectFill
        promoImage.clipsToBounds = true
        
        bubbleBackColor.backgroundColor = .yellow
        bubbleBackColor.translatesAutoresizingMaskIntoConstraints = false
        
        imageAvatar.layer.cornerRadius = 17
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.clipsToBounds = true
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTextsFeatures()
        imagesFeaturesSetup()
        let constraintsImage = [                                imageAvatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
                                                                imageAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                                                                imageAvatar.widthAnchor.constraint(equalToConstant: 40),
                                                                imageAvatar.heightAnchor.constraint(equalToConstant: 40)]
        
        contentView.addSubview(bubbleBackColor)
        contentView.addSubview(messageLabel)
        contentView.addSubview(imageAvatar)
        contentView.addSubview(timeLabel)
        contentView.addSubview(dataLabel)
        contentView.addSubview(dataView1)
        contentView.addSubview(dataView2)
        contentView.addSubview(promoView)
        
        promoView.addSubview(promoDescriptionLabel)
        promoView.addSubview(promoImage)
        promoView.addSubview(promoAmountLabel)
        promoView.addSubview(promoNameLabel)
        bubbleBackColor.addSubview(markedPromoLabel)
        
        promoView.translatesAutoresizingMaskIntoConstraints = false
        markedPromoLabel.translatesAutoresizingMaskIntoConstraints = false
        promoDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        promoImage.translatesAutoresizingMaskIntoConstraints = false
        promoAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        promoNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        promoDescriptionLabel.numberOfLines = 0
        promoNameLabel.numberOfLines = 0
        promoAmountLabel.numberOfLines = 0
        
        
        // timeLabel.isHidden = true
        messageLabel.isUserInteractionEnabled = true
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataView1.translatesAutoresizingMaskIntoConstraints = false
        dataView2.translatesAutoresizingMaskIntoConstraints = false
        imageAvatar.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.numberOfLines = 0
        
        let constraints = [messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                           messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
                           messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                           promoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                           promoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
                           promoView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                           
                           bubbleBackColor.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
                           bubbleBackColor.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
                           bubbleBackColor.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
                           timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
                           bubbleBackColor.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 25),
                           bubbleBackColor.widthAnchor.constraint(greaterThanOrEqualTo: timeLabel.widthAnchor, multiplier: 2),
                           dataView1.heightAnchor.constraint(equalToConstant: 1),
                           dataView2.heightAnchor.constraint(equalToConstant: 1),
                           dataLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                           dataView1.trailingAnchor.constraint(equalTo: dataLabel.leadingAnchor, constant: -5),
                           dataView2.leadingAnchor.constraint(equalTo: dataLabel.trailingAnchor, constant: 5),
                           
                           dataView1.centerYAnchor.constraint(equalTo: dataLabel.centerYAnchor),
                           dataView2.centerYAnchor.constraint(equalTo: dataLabel.centerYAnchor),
                           
                           dataView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                           dataView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                           
                           
        ]
        promotionContraints = [
            markedPromoLabel.topAnchor.constraint(equalTo: bubbleBackColor.topAnchor, constant: 2),
            markedPromoLabel.leadingAnchor.constraint(equalTo: bubbleBackColor.leadingAnchor, constant: 10),
            promoImage.widthAnchor.constraint(equalToConstant: 75),
            promoImage.leadingAnchor.constraint(equalTo: promoView.leadingAnchor, constant: 10),
            promoImage.topAnchor.constraint(equalTo: promoView.topAnchor, constant: 10),
            promoImage.bottomAnchor.constraint(equalTo: promoView.bottomAnchor, constant: -5),
            promoNameLabel.leadingAnchor.constraint(equalTo: promoImage.trailingAnchor, constant: 10),
            promoNameLabel.topAnchor.constraint(equalTo: promoView.topAnchor, constant: 10),
            promoNameLabel.trailingAnchor.constraint(equalTo: bubbleBackColor.trailingAnchor, constant: -10),
            promoDescriptionLabel.leadingAnchor.constraint(equalTo: promoImage.trailingAnchor, constant: 10),
            promoDescriptionLabel.trailingAnchor.constraint(equalTo: bubbleBackColor.trailingAnchor, constant: -10),
            promoDescriptionLabel.topAnchor.constraint(equalTo: promoNameLabel.bottomAnchor, constant: 10),
            promoAmountLabel.leadingAnchor.constraint(equalTo: promoImage.trailingAnchor, constant: 10),
            promoAmountLabel.topAnchor.constraint(equalTo: promoDescriptionLabel.bottomAnchor, constant: 10),
            promoAmountLabel.trailingAnchor.constraint(equalTo: bubbleBackColor.trailingAnchor, constant: -10),
        ]
        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(constraintsImage)
        //    NSLayoutConstraint.activate(promotionContraints)
        
        heightPromoImageConstraint = promoImage.heightAnchor.constraint(equalToConstant: 75)
        leadingConstraints = messageLabel.leadingAnchor.constraint(equalTo: imageAvatar.trailingAnchor, constant: 30)
        leadingConstraintsPromo = promoView.leadingAnchor.constraint(equalTo: bubbleBackColor.leadingAnchor, constant: 0)
        trailingContraintPromo = promoView.trailingAnchor.constraint(equalTo: bubbleBackColor.trailingAnchor, constant: 10)
        leadingConstraints2 = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        leadingConstraintsTime = timeLabel.leadingAnchor.constraint(equalTo: bubbleBackColor.leadingAnchor, constant: 16)
        trailingContraintTime = timeLabel.leadingAnchor.constraint(equalTo: bubbleBackColor.leadingAnchor, constant: 16)
        
        hewbrewContraintTime = timeLabel.trailingAnchor.constraint(equalTo: bubbleBackColor.trailingAnchor, constant: -16)
        hewbrewContraintTime.isActive = false
        
        leadingConstraintsTime.isActive = false
        leadingConstraints2.isActive = false
        leadingConstraints.isActive = false
        
        trailingContraint = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        trailingContraint.isActive = false
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: used for open links from messages in chats
extension ChatMessageCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectAddress addressComponents: [NSTextCheckingKey: String]) {
        print("Tapped address: \(addressComponents)")
    }
    
    func attributedLabel(_ label: NantesLabel, didSelectDate date: Date, timeZone: TimeZone, duration: TimeInterval) {
        print("Tapped Date: \(date), in time zone: \(timeZone), with duration: \(duration)")
    }
    
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(link)
        }
    }
    
    func attributedLabel(_ label: NantesLabel, didSelectPhoneNumber phoneNumber: String) {
        print("Tapped phone number: \(phoneNumber)")
    }
    
    func attributedLabel(_ label: NantesLabel, didSelectTransitInfo transitInfo: [NSTextCheckingKey: String]) {
        print("Tapped transit info: \(transitInfo)")
    }
}
