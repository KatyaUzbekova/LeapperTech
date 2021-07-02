//
//  SearchTableView.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    weak var parent:UIViewController!
  
    @IBOutlet weak var mutualsCount: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var profession_: UILabel!
    @IBOutlet weak var fullname: UILabel!
    
    var user:AllUsers?{
        didSet{
          //  avatar.image = user?.linkToAvatar
            mutualsCount.text = user?.mutualsCount
            if user?.role == "professional" {
                profession_.text = user?.profession ?? NSLocalizedString("ProfileViewPro.Label.ProfessionNotDefined", comment: "")
            }
            else if user?.role == "client" {
                profession_.text = NSLocalizedString("Leapper.Client", comment: "")
            }
            
            fullname.text = user?.fullName
            setNewImage(linkToPhoto: user?.linkToAvatar, imageInput: self.avatar, isRounded: true)
        }
    }
    
}
