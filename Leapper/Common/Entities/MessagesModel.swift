//
//  MessagesModel.swift
//  Leapper
//
//  Created by Kratos on 8/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation

class MessagesModel {
    
    var message:String?
    var sendersID:String?
    var isSeen:Bool?
    var senderUserType:String?
    var time:Double?
    var toUserType:String?
    var messageType:Int?
    var link:String?
    var promotionKey:String?
    var promotionOwner:String?
    var messageKey:String?
    init() {
    }
    
    var getMessage:String{
        return message!
    }
    
    var getSenderID:String{
        return sendersID!
    }
    
    var getIsSeen:Bool{
        return isSeen!
    }
    var getSenderUserType:String{
        return senderUserType!
    }
    var getTime:Double{
        return time!
    }
    var getToUserType:String{
        return toUserType!
    }
    var getMessageType:Int{
        return messageType!
    }
    var getLink:String{
        return link!
    }
    var getPromotionKey:String{
        return promotionKey!
    }
    var getPromotionOwner:String{
        return promotionOwner!
    }
    var getMessageKey:String{
        return messageKey!
    }
}
