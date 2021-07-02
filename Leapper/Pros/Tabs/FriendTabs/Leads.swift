//
//  Leads.swift
//  Leapper
//
//  Created by Kratos on 1/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class Leads: UIViewController {
    
    
    @IBOutlet weak var noLeadsLabel: UILabel!
    @IBOutlet weak var leadsTableView: UITableView!
    var child: SpinnerViewController!
    
    var leadsArray = [ClientsModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLeads()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        
        if (parent?.parent!.restorationIdentifier) != nil {
            leadsTableView.dataSource = self
            leadsTableView.delegate = self
        }
        else {
            let alertController = UIAlertController(title: NSLocalizedString("MenuBar.Button.Unavailable", comment: ""), message: NSLocalizedString("Purchases.ActionRemainder", comment: ""), preferredStyle: UIAlertController.Style.alert)
            let purchaseAction = UIAlertAction(title: NSLocalizedString("Purchases.Purchase", comment: ""), style: UIAlertAction.Style.default){_ in
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "navClient") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc                    }
            }
            alertController.addAction(purchaseAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func getLeads() {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        leadsArray = []
        DispatchQueue.main.async {
            self.leadsTableView.reloadData()
        }
        let url = URL(string: "https://api.leapper.com/api/mobi/contacts/leads")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        let decodedData = JSON(safeData)
                        let allClients = decodedData["leappsList"]
                        for i in 0..<allClients.count {
                            
                            var clientsLeads = [clientLeadModel]()
                            for j in 0..<allClients[i]["leads"].count {
                                clientsLeads.append(clientLeadModel(recall: allClients[i]["leads"][j]["recall"].boolValue, recieveTime: allClients[i]["leads"][j]["recieveTime"].stringValue, phone: allClients[i]["leads"][j]["phone"].stringValue, fullName: "\(allClients[i]["leads"][j]["fullName"].string ?? "Deleted User")", isContacted: allClients[i]["leads"][j]["isContacted"].boolValue, leadStatus: allClients[i]["leads"][j]["leadStatus"].stringValue, _id: allClients[i]["leads"][j]["_id"].stringValue ))
                            }
                            self.leadsArray.append(ClientsModel(isPro: decodedData[i]["role"].string.map{UsersType(rawValue: $0)! }, _id: "\(allClients[i]["_id"])", thanksCount: nil, leappsCount: nil, fullname: "\(allClients[i]["who"]["name"].string ?? "Leapper") " + "\(allClients[i]["who"]["lastName"].string ?? "User")", avatar: "\(allClients[i]["who"]["avatar"])", leappTime: "\(allClients[i]["time"])", leadsCount: "\(allClients[i]["leadsCount"])", communityCount: nil, clientLeadModel: clientsLeads, profession: nil))
                        }
                        
                        
                        if self.leadsArray.count == 0 {
                            DispatchQueue.main.async {
                                self.noLeadsLabel.isHidden = false
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.noLeadsLabel.isHidden = true
                                self.leadsTableView.reloadData()
                            }
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getLeads()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
            }
            DispatchQueue.main.async {
                // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
            }
        })
        task.resume()
        
        DispatchQueue.main.async {
            self.leadsTableView.reloadData()
        }
    }
    
}
extension Leads: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leadsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "leadCell", for: indexPath) as? LeadsCollection{
            itemCell.parent = self
            itemCell.leadCollection = leadsArray[indexPath.row]
            return itemCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
            })
    }
}
