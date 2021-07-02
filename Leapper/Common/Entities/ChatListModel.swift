//
//  ChatListModel.swift
//  Leapper
//
//  Created by Kratos on 8/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import Foundation

class ChatListModel {
    var lastUpdateTime:CLong?
    var chatRoomID:String?
    var otherUserID:String?
    
    init(_ chatRoomID:String?,_ otherUserID:String?,_ lastUpdateTime:CLong?) {
        self.lastUpdateTime = lastUpdateTime
        self.chatRoomID = chatRoomID
        self.otherUserID = otherUserID
    }
}
