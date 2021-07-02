//
//  FavoritesCollection.swift
//  Leapper
//
//  Created by Kratos on 9/8/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class FavoritesCollection: UITableViewCell {
    
    weak var parent:UIViewController!
    
    
    @IBOutlet weak var leappsIcon: UIImageView!
    @IBOutlet weak var thanksIcon: UIImageView!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var communityIcon: UIImageView!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var communities: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var thanks: UILabel!
    @IBOutlet weak var profession: UILabel!
    
    
    var user: ClientsModel?{
        didSet{
            fullname.text = user?.fullname ?? ""
            profession.text = user?.profession ?? ""
            leapps.text = user?.leappsCount ?? "0"
            thanks.text = user?.thanksCount ?? "0"
            communities.text = user?.communityCount ?? "0"
            if verifyUrl(urlString: user?.avatar) {
                avatar.sd_setImage(with: URL(string: user!.avatar), completed: nil)
                avatar.setRounded()
            }
            else {
                avatar.image = UIImage(named: "placeholderPic.png")
            }       
        }
    }
    
    func didSelect(indexPath: NSIndexPath) {
        
        
        switch user?.isPro {
        case .client:
            let cl = parent.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            parent.present(cl!, animated: true, completion: nil)
            break
        case .professional:
            let proView = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            proView?._id = user!._id
            proView?.NAME = user!.fullname
            parent.present(proView!, animated: true, completion: nil)
            break
        default:
            break
        }

    }
    
    
}
