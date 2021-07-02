//
//  LeadsCollection.swift
//  Leapper
//
//  Created by Kratos on 2/14/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class LeadsCollection: UITableViewCell {
    
    @IBOutlet weak var mainLay: UIView!
    var leadView:LeadView!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var fullname: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var leadsCount: UILabel!
    weak var parent: UIViewController!
    
    var leadCollection: ClientsModel?{
        didSet{
            fullname.text = leadCollection?.fullname
            time.text = leadCollection?.leappTime!
            leadsCount.text = leadCollection?.leadsCount!
            
            setNewImage(linkToPhoto: leadCollection?.avatar, imageInput: self.avatar, isRounded: true)
            // Set time in a appropriate format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let timeInDateFormat = dateFormatter.date(from: (leadCollection?.leappTime)!) {
                dateFormatter.dateFormat = "dd.MM.yyyy"
                time.text = dateFormatter.string(from: timeInDateFormat)
            }

            setClickListener()
        }
        
   
    }

    func setClickListener(){
        
        leadView = parent.storyboard?.instantiateViewController(withIdentifier: "LeadView") as? LeadView
        leadView._id = leadCollection!._id
        leadView.lf = (leadCollection?.clientModel)!
        leadView.fullname = fullname.text!
        mainLay.isUserInteractionEnabled = true
        let mc = UITapGestureRecognizer(target: self, action: #selector(proViewClicked))
        mainLay.addGestureRecognizer(mc)
        
    }
    @objc func proViewClicked(){
        parent.present(leadView, animated: true, completion: nil)
    }
    
    
   
}
