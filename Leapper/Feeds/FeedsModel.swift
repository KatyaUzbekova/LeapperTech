//
//  FeedsModel.swift
//  Leapper
//
//  Created by Kratos on 1/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
struct FeedsModel {
    
    var _idWho: String
    var _idWhom: String
    var proName: String
    var fullname: String
    var time:String;
    var profession: String
    var socialNetwork: String?
    var photosForSliderView: [String]?
    var isNew: Bool
        
    var isWhoAvatar: String?
    var isWhomAvatar: String?
    var roleWho: UsersType?
    var roleWhom: UsersType?
    var isPromo: Bool
    var isMeRecommended: Bool
    
    var promPic: String?
    var promName: String?
    var promDesc : String?
    var promAmount: String?
    var idPromo: String?
    var isShared: Bool
    var leads: [clientLeadModel]?
    init(time:String, fullname:String, proName: String, _idWho: String, _idWhom: String, profession: String, socialNetwork: String? = nil, photosForSliderView: [String]? = nil, isWhoAvatar: String?, isWhomAvatar:String? = nil, roleWho: UsersType?, roleWhom: UsersType? = nil, isNew: Bool, isPromo:Bool = false, isMeRecommended: Bool = false, promPic: String? = nil, promName: String? = nil, promDesc: String? = nil, promAmount:String? = nil, idPromo:String? = nil, isShared: Bool = false, leads: [clientLeadModel]? = nil ) {
        self.time = time
        self.fullname = fullname
        self.proName = proName
        self._idWho = _idWho
        self.profession = profession
        self._idWhom = _idWhom
        self.socialNetwork = socialNetwork
        self.photosForSliderView = photosForSliderView
        self.isWhomAvatar = isWhomAvatar
        self.isWhoAvatar = isWhoAvatar
        
        self.roleWho = roleWho
        self.roleWhom = roleWhom
        self.isNew = isNew
        self.isPromo = isPromo
        self.isMeRecommended = isMeRecommended
        self.promPic = promPic
        self.promName = promName
        self.promDesc = promDesc
        self.promAmount = promAmount
        self.idPromo = idPromo
        self.isShared = isShared
        self.leads = leads
    }
    
    
}
