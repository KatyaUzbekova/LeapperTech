//
//  File.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 09.01.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation

struct FeedsDataModel:Decodable {
    var feed: [FeedDataModel]
}
struct FeedDataModel:Decodable {
    var time: String
    var who: FeedWhoData
    var whom: FeedWhoData
    var socialNetwork: String?
}

struct FeedWhoData: Decodable {
    var _id:String
    var name: String?
    var lastName: String?
    var fullName: String?
    var portfolio: FeedPortfolio?
    var avatar: String?
    var role: String?
}

struct FeedPortfolio: Decodable {
    var photos: [String]?
    var jobName: String?
}
