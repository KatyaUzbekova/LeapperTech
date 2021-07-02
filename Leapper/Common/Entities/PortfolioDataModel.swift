//
//  PortfolioDataModel.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 24.04.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation

struct PortfolioDataModel: Decodable {
    let jobName: String?
    let photos: [String]?
    let info: String?
}
