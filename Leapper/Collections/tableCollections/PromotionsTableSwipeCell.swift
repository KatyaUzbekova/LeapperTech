//
//  PromotionsTableSwipeCell.swift
//  Leapper
//
//  Created by Kratos on 9/10/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import MessageUI
import SwiftKeychainWrapper
import Alamofire

class PromotionsTableSwipeCell: UITableViewCell {
    weak var parent:Promotions!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBAction func share(_ sender: Any) {
        ApiServices.shared.sharePromotion(isShared: prom!.isShared, lastController: parent, _idPromo: prom!._id, isMy: true)
    }
    
    var prom: PromotionModel?{
        didSet{
            let url = URL(string: prom!.imageUrl!)
            if verifyUrl(urlString: prom!.imageUrl!) {
                self.icon.sd_setImage(with:url , completed: nil)
                
            }
            name.text = prom!.name!
            desc.text = prom!.description!
            amount.text = prom!.amount 
            
        }
    }
}
