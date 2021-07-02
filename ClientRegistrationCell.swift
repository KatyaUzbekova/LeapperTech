//
//  ClientRegistrationCell.swift
//  
//
//  Created by Екатерина Узбекова on 06.01.2021.
//

import UIKit
import SDWebImage
class ClientRegistrationCell: UITableViewCell {
    var messageLeading: NSLayoutConstraint!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var UIVIEW: UIView!
    
    var trailingConstraints: NSLayoutConstraint!
    var leadingConstraints: NSLayoutConstraint!
    var parent:UIViewController!
    
    
    
    
    var form:Register?{
        didSet{
            messageLeading = message.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 80)
            trailingConstraints = UIVIEW.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
            leadingConstraints = UIVIEW.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
           
            message.layer.cornerRadius = 16
            UIVIEW.clipsToBounds = true
            if form!.amI!{
                setUserLayout(form)
            }else {
                setBotLayout(form)
            }
        }
        
    }
    func setUserLayout(_ form:Register!){
        messageLeading.isActive = false
        message.textAlignment = .right
        trailingConstraints.isActive = true
        message.text = form.messages
        avatar.isHidden = true
        message.backgroundColor = UIColor(red: 238, green: 216, blue: 242)
        if form.link!.count > 5{
                   // set icon
                   icon.isHidden = false
            message.isHidden = true
            icon.setRounded()
                    icon.sd_setImage(with: URL(string: form.link!), completed: nil)
               }else {
             message.isHidden = false
                   message.text = form.messages
                   icon.isHidden = true
               }
    }
    func setBotLayout(_ form:Register!){
        message.backgroundColor = UIColor(red: 240, green: 240, blue: 240)
        messageLeading.isActive = true
        message.textAlignment = .left
        trailingConstraints.isActive = false
        leadingConstraints.isActive = true
        if form.link!.count > 5{
            // set icon
            icon.isHidden = false
        }else {
            message.text = form.messages
            icon.isHidden = true
        }
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
