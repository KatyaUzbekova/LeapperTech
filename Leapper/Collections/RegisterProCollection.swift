//
//  RegisterProCollection.swift
//  Leapper
//
//  Created by Kratos on 3/5/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SDWebImage
class RegisterProCollection: UITableViewCell {
    var messageLeading: NSLayoutConstraint!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var UIVIEW: UIView!
    
    var trailingConstraints: NSLayoutConstraint!
    var leadingConstraints: NSLayoutConstraint!
    weak var parent:UIViewController!
    
    
    
    
    var form:MessageModel?{
        didSet{
             message.layer.cornerRadius = 15
             UIVIEW.clipsToBounds = true
            
            messageLeading = message.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 80)
            trailingConstraints = UIVIEW.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
            leadingConstraints = UIVIEW.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)

            if form!.isBot{
                setUserLayout(form)
            }else {
                setBotLayout(form)
            }
        }
        
    }
    func setUserLayout(_ form:MessageModel!){
        messageLeading.isActive = false
        message.textAlignment = .right
        trailingConstraints.isActive = true
        message.text = form.messages
        avatar.isHidden = true
        message.backgroundColor = UIColor(red: 238, green: 216, blue: 242)

    }
    func setBotLayout(_ form:MessageModel!){
        message.backgroundColor = UIColor(red: 240, green: 240, blue: 240)
        messageLeading.isActive = true
        message.textAlignment = .left
        trailingConstraints.isActive = false
        leadingConstraints.isActive = true

        avatar.isHidden = false
        avatar.setRounded()
    }
    override func prepareForReuse() {
        super .prepareForReuse()
        message.text = nil
        avatar.isHidden = true
        icon.isHidden = true
        
    }

   
}
