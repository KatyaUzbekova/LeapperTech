//
//  leadsLeappQualificationViewController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 02.02.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//
import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire

class LeadsInformationViewController: UIViewController {
    var fullname = ""
    var _id = ""
    var _idSender = ""
    var phoneNumber = ""
    var ageData = ""
    var radiusData = ""
    var leadsTypeData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leadsType.text = leadsTypeData
        radius.text = radiusData
        age.text = ageData
    }
    @IBOutlet weak var leadsType: UILabel!
    
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var radius: UILabel!
    @IBAction func introduceButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LeadContactSelector") as? LeadContactSelector
        vc!.fullname = self.fullname
        vc!._id = _id
        vc!._idSender = _idSender
        present(vc!, animated: true, completion: nil)
    }
}
