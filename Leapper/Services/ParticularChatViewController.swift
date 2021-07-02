//
//  Messenger.swift
//  Leapper
//
//  Created by Kratos on 8/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import IQKeyboardManager
import SocketIO


class ParticularChatViewController: UIViewController, UITextViewDelegate {
    
    var isDeleted = false
    var isPromoSharing = false
    var promoId = ""
    
    
    func getPromoData(with promoId: String, index: Int) {
        ApiServices.shared.getPromotionApi(_id:promoId,
                                           controller: self) {
           data,_ in
            if let safeData = data {
                if safeData["promo"]["_id"].string != nil {
                    let promotion = PromotionModel(_id: safeData["promo"]["_id"].string!, name:  safeData["promo"]["title"].string ?? " ", amount: safeData["promo"]["discount"].string ?? " ", description: safeData["promo"]["description"].string ?? " ", imageUrl: safeData["promo"]["imageUrl"].string, senderId: safeData["promo"]["userPro"].string!)
                    self.chatMessages[index].promotion = promotion
                    self.reloadData()
                }
                else {
                }
            }
        }
    }
    @IBOutlet weak var constraintBottomBar: NSLayoutConstraint!
    @IBOutlet weak var buttonForSending: UIButton!
    var showKeyboard = false
    var lastDateRefernced = Date(timeIntervalSinceReferenceDate: -123456789.0)
    var keyBoardSizeSave = CGFloat(0.0)
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if showKeyboard == false || keyBoardSizeSave != keyboardSize.height {
            showKeyboard = true
            keyBoardSizeSave = keyboardSize.height
            constraintBottomBar.constant = -keyboardSize.height
        }
        
    }

    func reloadData() {
        if self.chatMessages.count>0 {
            
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    func socketMessaging() {
        AppDelegate.socket.on(clientEvent: .connect) {data, ack in
            AppDelegate.socket.emit("join-rooms", [
                "userId": self.userId
            ])
        }
        AppDelegate.socket.on("message-general") {data, _ in
        }
    }
    let userId = KeychainWrapper.standard.string(forKey: "_id")!
    func socketConnecting() {
        getNewAccessByRefreshToken(currentViewController: self)
        let accessToken =  KeychainWrapper.standard.string(forKey: "accessToken")!
        let participantId = idWhom
        AppDelegate.socket.emit("join-room", [ "roomId": chatRoomId,
                                               "participant": participantId,
                                               "accessToken": accessToken
        ])
        AppDelegate.socket.on("delete-message"){ data, _ in
            self.chatMessages.removeAll(where: {$0.id == JSON(data)[0].string!})
            self.reloadData()
        }

        AppDelegate.socket.on("message"){ data, _ in
            if JSON(data)[0]["message"]["from"].string! != KeychainWrapper.standard.string(forKey: "_id")! {
                self.chatMessages.append(MessageModel(messages: JSON(data)[0]["message"]["text"].string ?? "PROMOTION WILL BE SOON", isBot: true, image: nil, avatar: "", isChatCell: true, timeOfMessage: JSON(data)[0]["message"]["time"].string!, isReaded: false, id: JSON(data)[0]["message"]["_id"].string!))
                self.reloadData()
            }
            else {
                self.chatMessages[self.chatMessages.count-1].id = JSON(data)[0]["message"]["_id"].string!
                self.chatMessages[self.chatMessages.count-1].isReaded = JSON(data)[0]["message"]["isNewMess"].bool!
            }
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        AppDelegate.socket.emit("leave-room")
        AppDelegate.socket.off("message")
        AppDelegate.socket.off("message-general")
        AppDelegate.socket.off("delete-message")
    }
    @IBOutlet weak var backButtonName: UIButton!
    
    func shareFirstMessageAsPromo() {
        if isPromoSharing {

            let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
            print("token: \(accessToken)")
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            let parameters: [String:Any] = [
                "participantId": idWhom,
                "promoId": promoId
            ]
            print(parameters)
            print(userId)
            AF.request("https://api.leapper.com/chats/createRoom", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                if let err = resp.error{
                    print(err)
                    return
                }
                if resp.response?.statusCode == 403 {
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.shareFirstMessageAsPromo()
                }
                else if resp.response?.statusCode == 200 {
                    let json = JSON(resp.data)["room"]["_id"].string!
                    self.chatRoomId = json
                    self.isChatExist = true
                    self.socketConnecting()
                }
                
            }
            var newTimeLabel = true
            let messageTime = Date()
            if lastDateRefernced.fullDistance(from: messageTime, resultIn: .day)! > 0 {
                lastDateRefernced = messageTime
            }
            else {
                newTimeLabel = false
            }
            
            chatMessages.append(MessageModel(messages: "PROMOTION LOADING", isBot: false, image: nil, avatar: "", isChatCell: true, isReaded: false, newDateLabel: newTimeLabel, promotion: PromotionModel(_id: "Promo name", name: "name", amount: "amount", description: "description", imageUrl: nil, senderId: "")))
            getPromoData(with: promoId, index: chatMessages.count-1)
            isPromoSharing = false
            reloadData()
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        if showKeyboard {
            showKeyboard = false
            constraintBottomBar.constant = -10
        }
    }
    
    var CHATTERPHONE = ""
    var ISPRO = false
    var chatRoomId = ""
    @IBOutlet weak var writtenMessage: UITextView!
    let colors:ColorUtils = ColorUtils()
    var chatMessages = [MessageModel]()
    var dubController = [String]()
    
    
    var linkToAvatar: String?
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var call: UIImageView!
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var fullname: UILabel!
    var fullnameText = ""
    var isOpenedFromLists = false
    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var appbar: UIView!
    
    @IBOutlet weak var bar2: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var lastSeen: UILabel!
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: writtenMessage.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        writtenMessage.constraints.forEach {(constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height + 5 < 150 {
                    constraint.constant = estimatedSize.height + 5
                }
            }
        }
        
        
    }
    
    func getChatHistoreApi() {
        let _id = chatRoomId
        
        let userId = KeychainWrapper.standard.string(forKey: "_id")!
        
        let parameters: [String:Any] = [
            "userId": userId
        ]
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        
        AF.request("https://api.leapper.com/chats/\(_id)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { [self] resp in
            if let err = resp.error{
                print(err)
                return
            }
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
            }
            else if resp.response?.statusCode == 200 {
                
                let participants = JSON(resp.data!)["room"]["participants"].array
                if participants?.count == 0 {
                    idWhom = KeychainWrapper.standard.string(forKey: "_id")!
                }
                else {
                    idWhom = participants![0]["userId"].string!
                }
                
                socketConnecting()
                    
                ApiServices.shared.getUserInfo(_id: idWhom, parentViewController: self, completion: {
                    data, error in
                    if let safeData = data {
                        setNewImage(linkToPhoto: safeData.userInfo.avatar, imageInput: self.avatar, isRounded: true)
                        self.CHATTERPHONE = "+\(safeData.userInfo.phone)" ?? ""
                        
                        DispatchQueue.main.async {
                            self.fullname.text = safeData.userInfo.name + " " + safeData.userInfo.lastName
                        }
                        self.roleWho = safeData.userInfo.role.map { UsersType(rawValue: $0)! }
                    }
                })
                let allMessages = JSON(resp.data!)["room"]["messages"].array ?? []
                print(allMessages)
                for i in 0..<allMessages.count {
                    let messageTime = convertStringToDateFormat(from: allMessages[i]["time"].string!)
                    var newTimeLabel = true
                    if lastDateRefernced.fullDistance(from: messageTime, resultIn: .day)! > 0 {
                        lastDateRefernced = messageTime
                    }
                    else {
                        newTimeLabel = false
                    }
                    let isBot = userId == allMessages[i]["from"].string!
                    if let messageText = allMessages[i]["text"].string {
                        chatMessages.append(MessageModel(messages: messageText, isBot: !isBot, image: nil, avatar: "", isChatCell: true, timeOfMessage: allMessages[i]["time"].string, isReaded: allMessages[i]["isNewMess"].bool, id: allMessages[i]["_id"].string!, newDateLabel: newTimeLabel))
                    }
                    else {
                        chatMessages.append(MessageModel(messages: "PROMOTION LOADING", isBot: !isBot, image: nil, avatar: "", isChatCell: true, timeOfMessage: allMessages[i]["time"].string, isReaded: allMessages[i]["isNewMess"].bool, id: allMessages[i]["_id"].string!, newDateLabel: newTimeLabel, promotion: PromotionModel(_id: allMessages[i]["idPromo"].string!, name: "name", amount: "amount", description: "description", imageUrl: nil, senderId: "")))
                        getPromoData(with: allMessages[i]["idPromo"].string!, index: chatMessages.count-1)
                    }
                }
                
                if isPromoSharing {
                    AppDelegate.socket.emit("send-message", ["roomId": chatRoomId,
                                                             "userId": userId,
                                                             "promoId": promoId
                    ])
                    
                    var newTimeLabel = true
                    let messageTime = Date()
                    if lastDateRefernced.fullDistance(from: messageTime, resultIn: .day)! > 0 {
                        lastDateRefernced = messageTime
                    }
                    else {
                        newTimeLabel = false
                    }
                    
                    chatMessages.append(MessageModel(messages: "PROMOTION LOADING", isBot: false, image: nil, avatar: "", isChatCell: true, isReaded: false, newDateLabel: newTimeLabel, promotion: PromotionModel(_id: "Promo name", name: "name", amount: "amount", description: "description", imageUrl: nil, senderId: "")))
                    getPromoData(with: promoId, index: chatMessages.count-1)
                    
                    isPromoSharing = false
                }
                reloadData()
            }
            else {
                print("Something went wrong, try again")
            }
        }
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    var idWhom = ""
    var roleWho: UsersType!
    
    @objc func openRecommender(_ sender: UITapGestureRecognizer? = nil) {
        if ReachabilityTest.isConnectedToNetwork() {
            switch roleWho {
            case .client:
                let cl = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
                self.present(cl!, animated: true, completion: nil)
                break
            case .professional:
                let proView = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
                proView?._id = idWhom
                proView?.NAME = fullnameText
                self.present(proView!, animated: true, completion: nil)
                break
            case .pro:
                let proView = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
                proView?._id = idWhom
                proView?.NAME = fullnameText
                self.present(proView!, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    var isChatExist = true
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        if isDeleted {
            writtenMessage.isEditable = false
            buttonForSending.isEnabled = false
        }
        else {
            writtenMessage.isEditable = true
            buttonForSending.isEnabled = true
        }
        
        if isOpenedFromLists {
            backButtonName.text(NSLocalizedString("Back", comment: "Back"))
        }
        IQKeyboardManager.shared().isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParticularChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParticularChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openRecommender(_:)))
        
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tap)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
        
        fullname.text = fullnameText
        lastSeen.text = NSLocalizedString("ParticularCharViewController.Label.LastSeenRecently", comment: "last seen recently")
        socketMessaging()
        
        if isChatExist {
            getChatHistoreApi()
        }
        else {
            shareFirstMessageAsPromo()
            socketConnecting()
        }
        writtenMessage.delegate = self
        
        writtenMessage!.layer.borderWidth = 1
        writtenMessage!.layer.cornerRadius = 17
        
        chatTableView.register(ChatMessageCell.self, forCellReuseIdentifier: "chatCell")
        
        setNewImage(linkToPhoto: linkToAvatar, imageInput: avatar, isRounded: true)
        
        let mc = UITapGestureRecognizer(target: self, action: #selector(callClicked))
        call.isUserInteractionEnabled  = true
        call.addGestureRecognizer(mc)
        
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        if !SessionManager.shared.isPro() {
            appbar.backgroundColor = colors.colorPrimaryClient
        }
        writtenMessage.becomeFirstResponder()
    }
    
    
    
    
    func firstMessageCreateChatApi(message : String) {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        var parameters: [String:Any] = [
            "message": message,
            "participantId": idWhom
        ]
        AF.request("https://api.leapper.com/chats/createRoom", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            if let err = resp.error{
                print(err)
                return
            }
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
                self.firstMessageCreateChatApi(message: message)
            }
            else if resp.response?.statusCode == 200 {
                let json = JSON(resp.data)["room"]["_id"].string!
                self.chatRoomId = json
                self.isChatExist = true
                self.socketConnecting()
            }
            
        }
    }
    @IBAction func sendMessage(_ sender: Any) {
        sendMessageAction()
    }
    
    func sendMessageAction() {
        
        let message = writtenMessage.text ?? ""
        self.writtenMessage.text = ""
        
        
        writtenMessage.constraints.forEach {(constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = 40
            }
        }
        
        
        if !isInEditing {
            if message != "" {
                if !isChatExist {
                    firstMessageCreateChatApi(message: message)
                }
                else {
                    let userId = KeychainWrapper.standard.string(forKey: "_id")!
                    AppDelegate.socket.emit(
                            "send-message",
                            [
                                "roomId": self.chatRoomId,
                                "message": message,
                                "userId": userId,
                            ]
                        )

                }
                
                var newTimeLabel = true
                let messageTime = Date()
                if lastDateRefernced.fullDistance(from: messageTime, resultIn: .day)! > 0 {
                    lastDateRefernced = messageTime
                }
                else {
                    newTimeLabel = false
                }
                
                self.chatMessages.append(MessageModel(messages: message, isBot: false, image: nil, avatar: "", isChatCell: true, isReaded: true, newDateLabel: newTimeLabel))
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                }
                self.reloadData()
            }
        }
        else {
            if message != "" {
                isInEditing = false
                
                if #available(iOS 13.0, *) {
                    let usualButtonType = UIImage(systemName: "arrow.up.circle.fill")
                    self.buttonForSending.setImage(usualButtonType, for: .normal)
                } else {
                    // Fallback on earlier versions
                }
                AppDelegate.socket.emit("edit-message",
                                        ["messageId": chatMessages[indexOfEdition].id,
                                         "text": message])
                self.chatMessages[indexOfEdition].messages = message
                self.reloadData()
            }
        }
    }
    @objc func callClicked(){
        let phoc: PhoneOverControlls = PhoneOverControlls()
        phoc.dialNumber(number: CHATTERPHONE)
    }
    
    var isInEditing = false
    var indexOfEdition = 0
    func editingMessage(index: Int) {
        self.writtenMessage.becomeFirstResponder()
        
        indexOfEdition = index
        if #available(iOS 13.0, *) {
            let confirmationImage = UIImage(systemName: "arrowshape.turn.up.left.fill")
            self.buttonForSending.setImage(confirmationImage, for: .normal)
        } else {
        }
    }
    
}
extension ParticularChatViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatMessageCell{
            
            if indexPath.row < chatMessages.count {
                self.view.hideAllToasts()
                let dataForCell = chatMessages[indexPath.row]
                cell.parent = self
                cell.chatMessage = dataForCell
                if let messageDate = dataForCell.timeOfMessage {
                    self.view.makeToast("\(setTimeFromJson(time: messageDate, isOnlyDate: true))", duration: 1.3, position: .top)
                }
                cell.selectionStyle = .none
            
                return cell
            }
        }
        return UITableViewCell()
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let chatMessageBubble = chatMessages[index]
        
        // 2
        let identifier = "\(index)" as NSString
        if !chatMessageBubble.isBot {

        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
            // 3
            let editAction = UIAction(
                title: NSLocalizedString("Promotions.Action.Edit", comment: "Edit"),
                image: UIImage(systemName: "pencil.slash")) { [self] _ in
                    isInEditing = true
                    writtenMessage.text = chatMessageBubble.messages
                    editingMessage(index: index)
                }
                
                let deleteAction = UIAction(
                    title: NSLocalizedString("MessengerViewController.Action.Delete", comment: "Delete"),
                    image: UIImage(systemName: "trash.fill"),
                    attributes: .destructive
                ) { [self] _ in
                    chatMessages.remove(at: index)
                    AppDelegate.socket.emit("delete-message", [
                                                "messageId": chatMessageBubble.id])
                    lastDateRefernced = Date(timeIntervalSinceReferenceDate: -123456789.0)
                    reloadData()
                }
                return UIMenu(title: "", image: nil, children: [editAction, deleteAction])
        }
        }
        return nil
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
                as? ChatMessageCell
        else {
            return nil
        }
        return UITargetedPreview(view: cell)
    }
}


//MARK: extension to check the distance, used in setting the date on the top
extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
}
