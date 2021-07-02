//
//  ServiceUsersCollections.swift
//  Leapper
//
//  Created by Kratos on 2/29/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class ServiceUsersCollections: UICollectionViewCell {
 
    
    @IBOutlet weak var avatar: UIImageView!
    
    var users: ServiceUsersModel?{
        didSet{
            if verifyUrl(urlString: users?.avatarLink) {
                avatar.sd_setImage(with: URL(string:(users?.avatarLink)!))
                avatar.setRounded()
            }
            else {
                avatar.image = UIImage(named: "placeholderPic.png")
            }
        }
    }
    
    
}
