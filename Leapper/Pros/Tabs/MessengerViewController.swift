//
//  MessengerViewController.swift
//  Leapper
//
//  Created by Kratos on 1/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import Kingfisher
import SocketIO

class MessengerViewController: UIViewController {
    
    var chatListItems = [ChatListsModel]()
    
    @IBOutlet weak var chatlist: UITableView!
    
    @IBOutlet weak var labelNoChatsYet: UILabel!
    
    func socketConnect() {
        let userId = KeychainWrapper.standard.string(forKey: "_id")!
        
        AppDelegate.socket.emit("join-rooms", [
            "userId": userId
        ])
        
        AppDelegate.socket.on("join-rooms") { [self]data,_ in
            let allData = JSON(data)[0]
            
//            AppDelegate.socket.emit("notifications-count",
//                                    ["userId":
//                                        KeychainWrapper.standard.string(forKey: "_id")!])
            
            if _id == JSON(data)[1].string ?? "" {
                for i in 0..<allData.count {
                    
                    let index = chatListItems.firstIndex(where: {$0.chatId == allData[i]["roomId"].string!})
                    if let realIndex = index {
                        chatListItems[realIndex].unreadedMess = allData[i]["roomNewMessCounter"].intValue
                    }
                    DispatchQueue.main.async {
                        self.chatlist.reloadData()
                    }
                }
            }
        }
        
        AppDelegate.socket.on("message-general") { [self]data, _ in
            
            AppDelegate.socket.emit("join-rooms", [
                "userId": userId
            ])
            let jsonData = JSON(data)
            let index = chatListItems.firstIndex(where: { (chatListItem) -> Bool in
                return chatListItem.chatId == jsonData[0]["room"].string!
            }
            )
            if let indexSafe = index {
                chatListItems[indexSafe].lastMessage = jsonData[0]["text"].string ?? NSLocalizedString( "MessengerViewController.Action.PromoWillBeSoon", comment: "")
                chatListItems[indexSafe].lastUpdateTime = jsonData[0]["time"].string ?? ""
                let tempData = chatListItems[indexSafe]
                chatListItems.remove(at: indexSafe)
                chatListItems.insert(tempData, at: 0)
                DispatchQueue.main.async {
                    self.chatlist.reloadData()
                }
            }
            else {
                getAllChatRoomsById()
            }
        }
    }
    func reloadTableView() {
        if self.chatListItems.count == 0 {
            DispatchQueue.main.async {
                self.labelNoChatsYet.isHidden = false
                self.chatlist.reloadData()
            }
        }
        else {
            DispatchQueue.main.async {
                self.labelNoChatsYet.isHidden = true
                self.chatlist.reloadData()
            }
        }
    }
    static var isConnected = false
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.socket.off("message-general")
        AppDelegate.socket.off("join-rooms")
    }
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    
    func getProfileInfo(by userId: String, index: Int) {
        let profileInfoLink = "https://api.leapper.com/api/mobi/getUser/\(userId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        AF.request(profileInfoLink, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { dataResponse in
            
            if dataResponse.error != nil {
                DispatchQueue.main.async {
                    self.view.makeToast(dataResponse.error?.localizedDescription, duration: 3, position: .bottom)
                }
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                
                let jsonData = JSON(data)
                print("NAMING \(jsonData["userInfo"]["lastName"])")
           //     60b607d790856e00362e6811
                if self.chatListItems.count > index {
                    self.chatListItems[index].avatar = jsonData["userInfo"]["avatar"].string
                    self.chatListItems[index].fullname = "\(jsonData["userInfo"]["name"].string ?? "Deleted User") \(jsonData["userInfo"]["lastName"].string ?? "")"
                    self.chatListItems[index].phoneNumber = "\(jsonData["userInfo"]["phone"].int64 ?? 0)"
                }
                else {
                    self.chatListItems[index].isDeleted = true
                }
                self.reloadTableView()
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getProfileInfo(by: userId, index: index)
                break
            default:
                self.chatListItems[index].isDeleted = true
                self.chatListItems[index].fullname = "Deleted User"
                break
            }
            
        }
    }
    private let _id = KeychainWrapper.standard.string(forKey: "_id")!
    
    func getAllChatRoomsById() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        
        let getAllChatRoomsByIdUrl = URL(string: "https://api.leapper.com/chats/getRooms/\(_id)")!
        
        AF.request(getAllChatRoomsByIdUrl, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { dataResponse in
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                let decodedData =  JSON(data)["rooms"].array ?? []
                self.chatListItems = []
                print("token \(decodedData)")
                for i in 0..<decodedData.count {
                    if let chatId = decodedData[i]["_id"].string {
                        if let idWhom = decodedData[i]["participants"][0]["userId"].string {
                            self.chatListItems.append(ChatListsModel(chatId: chatId,  lastUpdateTime: decodedData[i]["lastMessage"]["time"].string ?? decodedData[i]["createdAt"].string!, fullname: "Leapper User", lastMessage: decodedData[i]["lastMessage"]["text"].string ?? "SHARED PROMOTION", idWhomUser: idWhom, roleWhomUser: decodedData[i]["participants"][0]["role"].string.map { UsersType(rawValue: $0)!}, phoneNumber: decodedData[i]["participants"][0]["phone"].string, unreadedMess: 0, isReaded: decodedData[i]["lastMessage"]["isNewMess"].bool ?? true))
                            DispatchQueue.global(qos: .utility).sync {
                                self.getProfileInfo(by: idWhom, index: i)
                            }
                        }
                        else {
                            self.chatListItems.append(ChatListsModel(chatId: chatId,  lastUpdateTime: decodedData[i]["lastMessage"]["time"].string ?? decodedData[i]["createdAt"].string!, fullname: "Deleted User", lastMessage: decodedData[i]["lastMessage"]["text"].string ?? "SHARED PROMOTION", idWhomUser: "", roleWhomUser: decodedData[i]["participants"][0]["role"].string.map { UsersType(rawValue: $0)!}, phoneNumber: decodedData[i]["participants"][0]["phone"].string, unreadedMess: 0, isReaded: decodedData[i]["lastMessage"]["isNewMess"].bool ?? true, isDeleted: true))
                        }
                    }
                }
                if self.chatListItems.count == 0 {
                    DispatchQueue.main.async {
                        self.labelNoChatsYet.isHidden = false
                        self.chatlist.reloadData()
                    }
                }
                self.socketConnect()
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getAllChatRoomsById()
                break
            default:
                break
            }
        }
    }
    @objc func gotNewMessage(notification: NSNotification) {
        if let notifCount = notification.userInfo?["messages-count"] as? String {
            if notifCount == "0" || notifCount == "" {
                tabBarItem.badgeValue = nil
            }
            else {
                tabBarItem.badgeValue = notifCount
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(gotNewMessage(notification:)), name: NSNotification.Name(rawValue: "newMessage"), object: nil)
        

        chatlist.separatorStyle = UITableViewCell.SeparatorStyle.none
        chatlist.delegate = self
        chatlist.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllChatRoomsById()
    }
    
    func deleteChatApi(at id: String, index: Int) {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        AF.request(ApiServices.shared.deleteChatApiUrl(by:id), method: .delete, parameters: nil, headers: headers).responseJSON { data in
            DispatchQueue.main.async {
                self.chatListItems.remove(at: index)
                self.chatlist.reloadData()
            }
            
        }
        
    }
    
}
extension MessengerViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatListItems.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell   = tableView.dequeueReusableCell(withIdentifier: "chatlist", for: indexPath) as? ChatListCollection {
            
            itemCell.parent = self
            let index = indexPath.row
            
            if chatListItems.count > index {
                let currentCellData = chatListItems[index]
                itemCell.chats = currentCellData
            }
            else {
                return UITableViewCell()
            }
            return itemCell
        }
        return UITableViewCell()
    }
    
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
            
            let deleteAction = UIAction(
                title: NSLocalizedString("MessengerViewController.Action.Delete", comment: ""),
                image: UIImage(systemName: "trash.fill"),
                attributes: .destructive
            ) { _ in
                self.deleteChatApi(at: self.chatListItems[indexPath.row].chatId, index: indexPath.row)
            }
                let muteAction = UIAction(
                    title: NSLocalizedString("MessengerViewController.Action.MuteChat", comment: ""),
                    image: UIImage(systemName: "sound.fill")
                ) { _ in
                    self.deleteChatApi(at: self.chatListItems[indexPath.row].chatId, index: indexPath.row)
                }
                
                return UIMenu(title: "", image: nil, children: [deleteAction,muteAction])
        }
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
