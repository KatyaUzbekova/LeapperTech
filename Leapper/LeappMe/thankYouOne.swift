//
//  thankYouOne.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class ThankYouOne: UIViewController {
    var fullname = ""
    var whichNext = false
    var leadsTypeData = ""
    var radiusData = ""
    var ageData = ""
    var _id = ""
    
    var vc: LeadsInformationViewController!

    @IBOutlet weak var giveLeadButton: UIButton!
    @IBAction func giveLeads(_ sender: Any) {
        if whichNext {
            vc!._id = _id
            vc!.fullname = fullname
            self.vc!.leadsTypeData = self.leadsTypeData
            self.vc!.radiusData = self.radiusData
            self.vc!.ageData = self.ageData
            present(vc!, animated: true, completion: nil)
        }
        else {
            let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "LeadContactSelector") as? LeadContactSelector
            vc2!.fullname = self.fullname
            vc2!._id = _id
            present(vc2!, animated: true, completion: nil)
        }


    }
    @IBOutlet weak var thankyoutext: UILabel!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        vc = self.storyboard?.instantiateViewController(withIdentifier: "leadsLeappQualificationViewController") as? LeadsInformationViewController
        self.giveLeadButton.layer.cornerRadius = 15
        thankyoutext.text = NSLocalizedString("ThankYouOne.Label.ThankYouForSharing", comment: "")
    }
}
