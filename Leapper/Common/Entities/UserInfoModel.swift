//
//  UserInfoModel.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 24.04.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation

struct UserInfoModel: Decodable {
    let _id: String
    
    let email: String
    let name: String
    let lastName: String
    let avatar: String?
    let gender: String
    let coverPhoto: String?
    let role: String?
    let phone: CLong
    let webSite: String?
    let portfolio: PortfolioDataModel?
    let location: LocationModel?
}

struct LocationModel: Decodable {
    let latitude: CDouble
    let longitude: CDouble
}
