//
//  SearchFullLeapperData.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 06.01.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation


struct ResultsGlobalSearch: Decodable{
    var search: [UserGlobalResults]
}

struct UserGlobalResults: Decodable {
    var phone: CLong
    var name: String?
    var lastName: String?
    var fullName:String?
    var portfolio: PortfolioStruct?
    var _id:String
    var avatar: String?
    var role: String
    var mutualsCount: Int?
}

struct PortfolioStruct: Decodable {
    var jobName: String?
    var photos: [String]?
    var photo: [String]?
}

