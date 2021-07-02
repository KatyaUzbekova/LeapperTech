//
//  Portfolio.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import ImageViewer_swift

class Portfolio: UIViewController {    
    var portItems = [PortfolioEditModel]()
    var portItemsLinks = [String]()
    var portItemsLinksUpload = [String]()
    var child: SpinnerViewController!
    var linksToPhotos = [URL]()
    var tags = [String]()
    
    @IBOutlet weak var tableWithTags: UITableView!
    @IBOutlet weak var collections:UICollectionView!
    @IBAction func save(_ sender: Any) {
        tags = tags.filter(){$0 != ""}
        let parameters: [String:Any] = [
            "jobName": self.profNameInput.text ?? "",
            "info": self.profInfo.text ?? "",
            "tags": tags,
            "photos": Array(portItemsLinks[1..<portItemsLinks.count]),
            "attachments": [
            ]
        ]
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        
        AF.request("https://api.leapper.com/api/mobi/portfolio", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
            }
            else if resp.response?.statusCode == 200 {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                }
            }
            
            
        }
        
    }
    
    @IBOutlet weak var profInfo: UITextView!
    
    @IBOutlet weak var profNameInput: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profInfo.dataDetectorTypes = .link
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        
        tableWithTags.delegate = self
        tableWithTags.dataSource = self
        
        collections.delegate  = self
        collections.dataSource = self
        collections.reloadData()
        getSetPorfolio()
    }
    
    
    func getSetPorfolio(){
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/portfolio")! //change the url
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
                        let decodedData =  JSON(safeData)["portfolio"]
                        let photos = decodedData["photos"].array
                        for i in 0..<photos!.count {
                            self.portItemsLinks.insert(contentsOf: [photos![i].string!], at: 0)
                            self.portItemsLinksUpload.insert(contentsOf: [photos![i].string!], at: 0)
                            self.linksToPhotos.insert(contentsOf: [URL(string: photos![i].string ?? "")!], at: 0)
                        }
                        self.portItemsLinks = self.portItemsLinks.reversed()
                        let tagsJSON = decodedData["tags"].array
                        
                        for i in 0..<tagsJSON!.count {
                            self.tags.append(tagsJSON![i].string!)
                        }
                        self.tags.append("")
                        self.portItemsLinks.insert(contentsOf: ["add"], at: 0)
                        
                        DispatchQueue.main.async {
                            self.profNameInput.text = decodedData["jobName"].string ?? ""
                            self.profInfo.text = decodedData["info"].string ?? ""
                            self.collections.reloadData()
                            self.tableWithTags.reloadData()
                            
                        }
                        DispatchQueue.main.async {
                            self.child.willMove(toParent: nil)
                            self.child.view.removeFromSuperview()
                            self.child.removeFromParent()
                        }
                    }
                    
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getSetPorfolio()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
                
            }
        })
        task.resume()
    }
    
}

extension Portfolio: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        portItemsLinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Portos", for: indexPath) as? PortoCollCell {
            itemCell.parent = self
            itemCell.indexOfPhoto = indexPath.row
            itemCell.pem = portItemsLinks[indexPath.row]
            if indexPath.row != 0 {
                itemCell.content.setupImageViewer(urls: linksToPhotos, initialIndex: indexPath.item-1)
            }
            
            return itemCell
        }
        return UICollectionViewCell()
    }
    
    
}

extension Portfolio: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "editPortTags", for: indexPath) as? TagTableViewCell {
            
            
            if indexPath.row == tags.count-1 {
                itemCell.deleteButton.isHidden = true
                itemCell.textField.text = tags[indexPath.row]
                itemCell.textField.isHidden = true
                itemCell.addNewItemButton.isHidden = false
                itemCell.index = indexPath.row
                itemCell.parent = self
            }
            else {
                itemCell.deleteButton.isHidden = false
                itemCell.addNewItemButton.isHidden = true
                itemCell.textField.isHidden = false
                
                itemCell.textField.text = tags[indexPath.row]
                itemCell.index = indexPath.row
                itemCell.parent = self
            }
            return itemCell
        }
        return UITableViewCell()
    }
    
    
    
}



class PortfolioEditModel {
    var key:String?
    var link:String?
    var portKey:String?
    init(portKeys:String?,keys:String?, links:String?) {
        self.key = keys
        self.portKey = portKeys
        self.link  = links
    }
}
