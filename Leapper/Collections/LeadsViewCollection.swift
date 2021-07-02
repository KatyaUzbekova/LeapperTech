//
//  LeadsViewCollection.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class LeadsViewCollection: UITableViewCell {
    weak var parent:UIViewController!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var time: UILabel!
    var leads:clientLeadModel?{
        didSet{
            setFirst(leads!)
            
        }
    }
    
    
    
    func setFirst(_ leads:clientLeadModel){
        self.fullname.text = leads.fullName
        self.avatar.setRounded()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let timeInDateFormat = dateFormatter.date(from: leads.recieveTime) {
        
            if Calendar.autoupdatingCurrent.isDateInToday(timeInDateFormat) {
            dateFormatter.dateFormat = "HH:mm"
                time.text = dateFormatter.string(from: timeInDateFormat)
        }
        else {
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            time.text = dateFormatter.string(from: timeInDateFormat)
        }
        }
    }
}
