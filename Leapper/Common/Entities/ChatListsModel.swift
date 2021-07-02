//
//  ChatListsModel.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 12.04.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation

class ChatListsModel {
    var lastUpdateTime: String
    var fullname: String
    var avatar: String?
    var lastMessage: String
    var chatId:String
    var idWhomUser: String
    var roleWhomUser: UsersType?
    var phoneNumber: String?
    var unreadedMess: Int
    var isReaded: Bool
    var isDeleted: Bool
    
    init(chatId: String, lastUpdateTime:String, fullname:String, avatar:String? = nil, lastMessage: String, idWhomUser: String, roleWhomUser: UsersType?, phoneNumber: String?, unreadedMess: Int = 0, isReaded: Bool, isDeleted: Bool = false) {
        self.chatId = chatId
        self.avatar = avatar
        self.fullname = fullname
        self.lastUpdateTime  = lastUpdateTime
        self.lastMessage = lastMessage
        self.idWhomUser = idWhomUser
        self.roleWhomUser = roleWhomUser
        self.phoneNumber = phoneNumber
        self.unreadedMess = unreadedMess
        self.isReaded = isReaded
        self.isDeleted = isDeleted
    }
}
