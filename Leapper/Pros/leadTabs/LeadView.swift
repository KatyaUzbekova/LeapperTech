//
//  LeadView.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit


class LeadView: UIViewController {
    var _id = ""
    var fullname = ""
    var lf = [clientLeadModel]()
    @IBOutlet weak var leadsTable: UITableView!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        leadsTable.dataSource = self
        leadsTable.delegate = self
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage == "he" {
            self.navTitle.title = NSLocalizedString("LeadView.Label.LeadTitle", comment: "")
        }
        else {
            let recommendedString = NSLocalizedString("LeadView.Label.LeadsFrom", comment: "")
            self.navTitle.title = String.localizedStringWithFormat(recommendedString, fullname)
        }
        let recommendedString = NSLocalizedString("LeadView.Label.LeadsFrom", comment: "")
        self.navTitle.title = String.localizedStringWithFormat(recommendedString, fullname)
    }
    var index = 0
    
}
extension LeadView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lf.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "leads", for: indexPath) as? LeadsViewCollection{
            itemCell.parent = self
            itemCell.leads = lf[indexPath.row]
            return itemCell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextController: LeadInformationController!
        nextController = self.storyboard?.instantiateViewController(withIdentifier: "LeadInformationController") as? LeadInformationController
        nextController.leadsFromFullname = fullname
        nextController.fullname = lf[indexPath.row].fullName
        nextController._id = lf[indexPath.row]._id
        nextController.phoneNumber = lf[indexPath.row].phone
        self.index = indexPath.row
        self.present(nextController, animated: true, completion: nil)
    }
    
    
}
