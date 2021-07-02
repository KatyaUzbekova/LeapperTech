//
//  BusinessCardViewController.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftKeychainWrapper

class BusinessCardViewController: UIViewController {
    var _id = ""
    var fullNameText = ""
    var avatarLink: String?
    
    var mutualsItemArray=[ServiceUsersModel]()
    var nonMutualsItemArray = [ServiceUsersModel]()
    
    
    @IBOutlet weak var nonMutualsCollectionView: UICollectionView!
    @IBOutlet weak var mutualsCollectionView: UICollectionView!
    @IBOutlet weak var community: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var leappsIcon: UIImageView!
    @IBOutlet weak var thanx: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var noMutuals: UILabel!
    @IBOutlet weak var noNonMutuals: UILabel!
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func shoProfile(_ sender: Any) {
        var pvp:ProfileViewPro!
        pvp = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
        pvp._id = _id
        self.present(pvp, animated: true, completion: nil)
    }
    
    @objc func tappedMe()
    {
        var pvp:ProfileViewPro!
        pvp = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
        pvp._id = _id
        pvp.NAME = fullNameText
        self.present(pvp, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullname.text = fullNameText
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedMe))
        avatar.addGestureRecognizer(tap)
        avatar.isUserInteractionEnabled = true
        
        mutualsCollectionView.dataSource = self
        mutualsCollectionView.delegate = self
        nonMutualsCollectionView.dataSource = self
        nonMutualsCollectionView.delegate = self
        self.noNonMutuals.isHidden = true
        self.noMutuals.isHidden = true
        
        getSetProfileViewProApi()
        getMutualsApi() 
    }
    
    func getSetProfileViewProApi() {
        
        /*
         method to send GET request to server and receive JSON with user data
         */
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        print("id \(accessToken)")
        let url = URL(string: "https://api.leapper.com/api/mobi/getUser/\(_id)")! //change the url
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
                            let json = JSON(safeData)
                            DispatchQueue.main.async {
                                self.thanx.text = "\(json["thanksCount"])"
                                self.leapps.text = "\(json["leappCount"])"
                                self.community.text = "\(json["communityCount"])"
                                
                                let imgUrl = "\(json["userInfo"]["avatar"])"
                                if verifyUrl(urlString: imgUrl) {
                                    self.avatar.sd_setImage(with: URL(string:imgUrl), completed: nil)
                                    self.avatar.setRounded()
                                }
                            }
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getSetProfileViewProApi()
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
    func getMutualsApi() {
        
        /*
         method to send GET request to server and receive JSON with mutuals users
         */
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        var url = URLComponents(string: "https://api.leapper.com/api/mobi/getMutuals/")! //change the url
        let session = URLSession.shared
        url.queryItems = [URLQueryItem(name: "nextId", value: _id)]
        var request = URLRequest(url: url.url!)
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
                        let jsonMutualsData = JSON(safeData)["idList"]["mutuals"]
                        for i in 0..<jsonMutualsData.count {
                            self.mutualsItemArray.append(ServiceUsersModel(userRole: jsonMutualsData[i]["role"].string.map{ UsersType(rawValue: $0)!},  _id: jsonMutualsData[i]["_id"].string, avatarLink: jsonMutualsData[i]["avatar"].string ))
                            DispatchQueue.main.async {
                                self.noMutuals.isHidden = true
                            }
                            
                        }
                        if jsonMutualsData.count == 0 {
                            DispatchQueue.main.async {
                                self.noMutuals.isHidden = false
                            }
                        }
                        DispatchQueue.main.async {
                            self.mutualsCollectionView.reloadData()
                        }
                        
                        let jsonNonMutualsData = JSON(safeData)["idList"]["others"]
                        for i in 0..<jsonNonMutualsData.count {
                            self.nonMutualsItemArray.append(ServiceUsersModel(userRole: jsonNonMutualsData[i]["role"].string.map{ UsersType(rawValue: $0)!},  _id: jsonNonMutualsData[i]["_id"].string, avatarLink: jsonNonMutualsData[i]["avatar"].string ))
                            DispatchQueue.main.async {
                                self.noNonMutuals.isHidden = true
                            }
                            
                        }
                        if jsonNonMutualsData.count == 0{
                            DispatchQueue.main.async {
                                self.noNonMutuals.isHidden = false
                            }
                            
                        }
                        DispatchQueue.main.async {
                            self.nonMutualsCollectionView.reloadData()
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getMutualsApi()
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

// MARK: Mutuals and Nonmutuals Delegates
extension BusinessCardViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mutualsCollectionView{
            return mutualsItemArray.count
        }else{
            return nonMutualsItemArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mutualsCollectionView{
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Mutuals", for: indexPath) as? ServiceUsersCollections{
                
                itemCell.users = mutualsItemArray[indexPath.row]
                return itemCell
            }
            return UICollectionViewCell()
        }else{
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "nonMutuals", for: indexPath) as? ServiceUsersCollections{
                
                itemCell.users = nonMutualsItemArray[indexPath.row]
                return itemCell
            }
            return UICollectionViewCell()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mutualsCollectionView {
            let su = mutualsItemArray[indexPath.row]
            switch su.userRole {
            case .client:
                let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
                pvc?._id = su._id!
                self.present(pvc!, animated: true, completion: nil)
                break
            case .professional:
                let pvp = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
                pvp?._id = su._id!
                pvp?.NAME = fullNameText
                self.present(pvp!, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        else {
//            let su = nonMutualsItemArray[indexPath.row]
//            switch su.userRole {
//            case .client:
//                let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
//                pvc?._id = su._id!
//                self.present(pvc!, animated: true, completion: nil)
//                break
//            case .professional:
//                let pvp = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
//                pvp?._id = su._id!
//                self.present(pvp!, animated: true, completion: nil)
//                break
//            default:
//                break
//            }
        }
    }
}
