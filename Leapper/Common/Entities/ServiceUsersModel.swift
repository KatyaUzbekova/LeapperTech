//
//  ServiceUsers.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 13.03.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation

struct ServiceUsersModel {
    
    var userRole: UsersType?
    var _id:String?
    var avatarLink: String?
    
    init(userRole:UsersType?,_id:String?, avatarLink:String?) {
        self.userRole = userRole
        self._id = _id
        self.avatarLink = avatarLink
    }
}
