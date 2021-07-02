//
//  SharingInChatApi.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 25.05.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire

func sharingInChatApiRequest() {
    
}
private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!


func checkNumberInDataBase(phone: String) {
    let url = "https://api.leapper.com/api/mobi/getId/\(phone)"
    
}

