//
//  CommunityVC.swift
//  Leapper
//
//  Created by Kratos on 1/24/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class CommunityVC: UIViewController {
    var communityItemViewArray = [ClientsModel]()

    @IBOutlet weak var communityCollection: UITableView!
    
    var child: SpinnerViewController!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        communityCollection.separatorStyle = UITableViewCell.SeparatorStyle.none
        communityCollection.dataSource = self
        communityCollection.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCommunity()
    }
    @IBOutlet weak var noCommunityLabel: UILabel!
    func getCommunity() {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!        
        let url = URL(string: "https://api.leapper.com/api/mobi/contacts/community")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
                        do {
                            let decodedData = JSON(safeData)
                            let allClients = decodedData["community"]["allCommunity"]
                            self.communityItemViewArray = []

                            for i in 0..<allClients.count {
                                self.communityItemViewArray.append(ClientsModel(isPro: allClients[i]["role"].string.map{UsersType(rawValue: $0)! }, _id: "\(allClients[i]["_id"])", thanksCount: "\(allClients[i]["thanksCount"])", leappsCount: "\(allClients[i]["leappsCount"])", fullname: "\(allClients[i]["name"].string ?? "Leapper") " + "\(allClients[i]["lastName"].string ?? "User")", avatar: "\(allClients[i]["avatar"])", leappTime: nil, leadsCount: nil, communityCount: "\(allClients[i]["communityCount"])", clientLeadModel: [], profession: nil ))
                                DispatchQueue.main.async {
                                    self.noCommunityLabel.isHidden = true
                                    self.communityCollection.reloadData()
                                }
                            }
                            
                            if allClients.count == 0 {
                                DispatchQueue.main.async {
                                    self.noCommunityLabel.isHidden = false
                                }
                            }
                            // wait two seconds to simulate some work happening
                            DispatchQueue.main.async {
                                // then remove the spinner view controller
                                self.child.willMove(toParent: nil)
                                self.child.view.removeFromSuperview()
                                self.child.removeFromParent()
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                    
            }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getCommunity()
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
            self.communityCollection.reloadData()
        }
    }
}
extension CommunityVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return communityItemViewArray.count
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "communityCells", for: indexPath) as? CommunityCollectionView{
            itemCell.parent = self
            if communityItemViewArray.count > indexPath.row {
                itemCell.communityUsers = communityItemViewArray[indexPath.row]
            }
            return itemCell
        }
        
        return UITableViewCell()
    }

}


