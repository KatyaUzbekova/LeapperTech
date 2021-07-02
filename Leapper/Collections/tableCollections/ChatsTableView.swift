//
//  ChatsTableView.swift
//  Leapper
//
//  Created by Kratos on 8/2/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit

class ChatsTableView: UITableViewCell {
    var trailingConstraints:NSLayoutConstraint!
    var leadingConstraints:NSLayoutConstraint!
    weak var parent:UIViewController!
    
    @IBOutlet weak var promIcon: UIImageView!
    @IBOutlet weak var promDiscount: UILabel!
    @IBOutlet weak var promDesc: UILabel!
    @IBOutlet weak var isRead: UIImageView!
    @IBOutlet weak var promTitle: UILabel!
    @IBOutlet weak var isSent: UIImageView!
    @IBOutlet weak var myChat: UIView!
    @IBOutlet weak var mymessage: UILabel!
    @IBOutlet weak var mypromview: UIView!
    @IBOutlet weak var mytime: UILabel!
    
    
    var message:MessagesModel?{
        didSet{
           updateMessageView(message)
        }
    }
    
    
    func updateMessageView(_ message:MessagesModel!){
        myChat.layer.cornerRadius = 15
        myChat.clipsToBounds = true
        trailingConstraints = myChat.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25)
        leadingConstraints = myChat.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25)
        mymessage.text = message.getMessage
        if message.getMessageType == 1{
                   mypromview.isHidden = false
               }
        
        if message.getIsSeen == false {
            isRead.isHidden = true
            isSent.isHidden = false

        }
        else {
            isSent.isHidden = true
            isRead.isHidden = false
        }
    }
    
    
    override func prepareForReuse() {
        super .prepareForReuse()
        mymessage.text = nil
        mypromview.isHidden = true
        leadingConstraints!.isActive = false
        trailingConstraints!.isActive  = false
        mytime.text = nil
    
    }
    
}
