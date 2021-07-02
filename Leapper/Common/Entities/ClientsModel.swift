//
//  ClientsModel.swift
//  Leapper
//
//  Created by Kratos on 1/24/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
struct ClientsModel {
    
    var isPro: UsersType?
    var _id: String
    var thanksCount: String?
    var leappsCount: String?
    var fullname: String
    var avatar: String
    var leappTime: String?
    var leadsCount: String?
    var communityCount: String?
    var clientModel: [clientLeadModel]
    var profession: String?
    
    init(isPro:UsersType?, _id:String, thanksCount: String?, leappsCount: String?, fullname: String, avatar: String, leappTime: String?, leadsCount: String?, communityCount: String?, clientLeadModel: [clientLeadModel], profession: String?) {
        self.isPro  = isPro
        self._id = _id
        self.thanksCount = thanksCount
        self.leappsCount = leappsCount
        self.fullname = fullname
        self.avatar = avatar
        self.leappTime = leappTime
        self.leadsCount = leadsCount
        self.communityCount = communityCount
        self.clientModel = clientLeadModel
        self.profession = profession
    }
}

struct clientLeadModel {
    var recall : Bool
    var recieveTime : String
    var phone : String
    var fullName : String
    var isContacted : Bool
    var leadStatus : String
    var _id:String
}
