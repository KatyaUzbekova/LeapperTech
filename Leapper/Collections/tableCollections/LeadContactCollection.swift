//
//  LeadContactCollection.swift
//  Leapper
//
//  Created by Kratos on 9/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import DLRadioButton
import ContactsUI
import Contacts
class LeadContactCollection: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var checkbox: DLRadioButton! {
        didSet {
            checkbox.isMultipleSelectionEnabled = true;
        }
    }
    
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var name: UILabel!
    var contact: CNContact?{
        
        didSet{
            name.text = contact?.givenName
            for ctcNum: CNLabeledValue in contact!.phoneNumbers {
                if let fulPhone = ctcNum.value as? CNPhoneNumber {
                    if let ph = fulPhone.value(forKey: "digits") as? String{
                        self.phone.text = ph
                    }
                }
            }
            
            
            if contact!.imageData != nil{
                self.avatar.image = UIImage(data: contact!.imageData!)
                self.avatar.setRounded()
            }
            else {
                self.avatar.image = UIImage(named: "leappIcon")
                self.avatar.layer.cornerRadius = 0
            }
            
           
        }
    }
    
}
