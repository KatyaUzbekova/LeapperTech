//
//  Favorites.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class Favorites: UIViewController {
    
    @IBOutlet weak var favorites: UITableView!
    var myFavorites = [ClientsModel]()
    var child: SpinnerViewController!
    
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var favoritesNavBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        if !SessionManager.shared.isPro() {
            favoritesNavBar.isHidden = true
            constraintTop.constant = 5
        }
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        
        
        self.favorites.separatorStyle = .none
        self.favorites.dataSource = self
        self.favorites.delegate  = self
        
        getMyFavoritesApi()
        
    }
    
    func getMyFavoritesApi(){
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/favorites")! //change the url
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
                        let decodedData = JSON(safeData)["favoriteUsers"].array ?? []
                        for i in 0..<decodedData.count {
                            self.myFavorites.append(ClientsModel(isPro: decodedData[i]["role"].string.map{UsersType(rawValue: $0)! }, _id: "\(decodedData[i]["_id"])", thanksCount: "\(decodedData[i]["thanksCount"])", leappsCount: "\(decodedData[i]["leappsCount"])", fullname: "\(decodedData[i]["name"].string ?? "Leapper") " + "\(decodedData[i]["lastName"].string ?? "User")", avatar: "\(decodedData[i]["avatar"])", leappTime: nil, leadsCount: nil, communityCount: "\(decodedData[i]["communityCount"])", clientLeadModel: [], profession: "\(decodedData[i]["job"])"))
                        }
                        
                        if decodedData.count == 0 {
                            DispatchQueue.main.async {
                               
                                
                                let alertController = UIAlertController(title: NSLocalizedString( "Favorites.Action.NoFavYet", comment: "No favorites yet"), message: NSLocalizedString("Favorites.Action.PromoText", comment: "Fav text"), preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Favorites.Action.GoToProfile", comment: "Go to profile"), style: .cancel, handler: {
                                    action in
                                    self.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alertController, animated: true, completion: nil)
                            }

                        }
                        DispatchQueue.main.async {
                            self.favorites.reloadData()
                        }
                    }
                    
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getMyFavoritesApi()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
                
                DispatchQueue.main.async {
                    self.child.willMove(toParent: nil)
                    self.child.view.removeFromSuperview()
                    self.child.removeFromParent()
                }
                
            }
        })
        task.resume()
    }
    
    
}

extension Favorites:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myFavorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "Favs", for: indexPath) as? FavoritesCollection {
            itemCell.parent = self
            itemCell.user = myFavorites[indexPath.row]
            return itemCell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FavoritesCollection {
            cell.didSelect(indexPath: indexPath as NSIndexPath)
        }
    }
    
}
