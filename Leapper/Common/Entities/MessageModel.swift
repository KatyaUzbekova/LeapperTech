//
//  Register.swift
//  Leapper
//
//  Created by Kratos on 3/5/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit

struct MessageModel {
    var messages:String
    var isBot:Bool
    var image: UIImage?
    var avatar: String?
    var isChatCell: Bool
    var isAgreement: Bool
    var timeOfMessage: String?
    var isReaded: Bool?
    var caseNumber: Int?
    var id: String
    var newDateLabel: Bool
    var promotion: PromotionModel?
    var imagePathName: String?
    
    init(messages:String, isBot:Bool, image: UIImage?, avatar: String? = nil, isChatCell: Bool = false, isAgreement: Bool = false, timeOfMessage: String? = nil, isReaded: Bool? = nil, caseNumber: Int? = nil, id:String = "0", newDateLabel: Bool = false, promotion: PromotionModel? = nil, imagePathName: String? = nil) {
        self.messages = messages
        self.isBot = isBot
        self.image = image
        self.avatar = avatar
        self.isChatCell = isChatCell
        self.isAgreement = isAgreement
        self.timeOfMessage = timeOfMessage
        self.isReaded = isReaded
        self.caseNumber = caseNumber
        self.id = id
        self.newDateLabel = newDateLabel
        self.promotion = promotion
        self.imagePathName = imagePathName
    }
}
