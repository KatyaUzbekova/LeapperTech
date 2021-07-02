//
//  PromotionModels.swift
//  Leapper
//
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
struct PromotionModel {
    var _id:String
    var name: String?
    var amount:String
    var description:String?
    var imageUrl:String?
    var isShared: Bool
    var senderId: String
    
    init(_id: String, name: String?, amount: String, description: String?, imageUrl: String?, isShared:Bool = false, senderId: String) {
        self._id = _id
        self.name = name
        self.amount = amount
        self.description = description
        self.imageUrl = imageUrl
        self.isShared = isShared
        self.senderId = senderId
    }
    
}
