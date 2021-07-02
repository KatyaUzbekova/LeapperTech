//
//  Clients.swift
//  Leapper
//
//  Created by Kratos on 1/6/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class Clients: UIViewController {
   
    @IBOutlet weak var noClientsUserLabel: UILabel!
    @IBOutlet weak var clientsTableView: UITableView!
        
    var clientsArray = [ClientsModel]()
    var child: SpinnerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        clientsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        clientsTableView.dataSource = self
        clientsTableView.dataSource = self
        clientsTableView.allowsSelection = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getClients()
    }
    
    func getClients() {
        let url = URL(string: "https://api.leapper.com/api/mobi/contacts/clients")! //change the url
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

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
                DispatchQueue.main.async {
                    // then remove the spinner view controller
                    self.child.willMove(toParent: nil)
                    self.child.view.removeFromSuperview()
                    self.child.removeFromParent()
                }
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        do {
                            let decodedData = JSON(safeData)
                            let allClients = decodedData["clients"]["allClients"]
                            self.clientsArray = []
                            
                            for i in 0..<allClients.count {
                                self.clientsArray.append(ClientsModel(isPro: allClients[i]["role"].string.map{UsersType(rawValue: $0)! }, _id: "\(allClients[i]["_id"])", thanksCount: "\(allClients[i]["thanksCount"])", leappsCount: "\(allClients[i]["leappsCount"])", fullname: "\(allClients[i]["name"].string ?? "Leapper") " + "\(allClients[i]["lastName"].string ?? "User")", avatar: "\(allClients[i]["avatar"])", leappTime: nil, leadsCount: nil, communityCount: "\(allClients[i]["communityCount"])", clientLeadModel: [], profession: nil ))
                            }
                            if allClients.count == 0 {
                                DispatchQueue.main.async {
                                    self.noClientsUserLabel.isHidden = false
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.noClientsUserLabel.isHidden = true
                                    self.clientsTableView.reloadData()
                                }
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                    
            }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getClients()
                }
                else {
                    DispatchQueue.main.async {
                            Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                        }
                }
                
            }
        })
        task.resume()
        
        DispatchQueue.main.async {
            self.clientsTableView.reloadData()
        }
    }
        
}
extension Clients: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "clientsCell", for: indexPath) as? ClientsTableViewCell{
            itemCell.parent = self
            if clientsArray.count > indexPath.row {
                itemCell.clients = clientsArray[indexPath.row]
            }
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
