//
//  UserDataModel.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 23.04.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation


struct UserDataModel: Decodable {
    let thanksCount: CLong
    let leappCount: CLong
    let communityCount: CLong
    let userInfo: UserInfoModel
    let leappsGiven: LeappsGivenModel
}
