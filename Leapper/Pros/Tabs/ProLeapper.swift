//
//  ProLeapper.swift
//  Leapper
//
//  Created by Kratos on 1/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import MapKit


class ProLeapper: UIViewController {
    var portReg: UIViewController!
    
    @IBOutlet weak var coverPhoto: UIImageView!
    
    @IBOutlet weak var portfolio: ViewWithBorders!
    
    @IBAction func editProfile(_ sender: Any) {
        let ep = self.storyboard?.instantiateViewController(withIdentifier: "navEditPort") as? UINavigationController
        self.present(ep!, animated: true, completion: nil)
    }
    @IBOutlet weak var promotions: ViewWithBorders!
    @IBOutlet weak var statistics: ViewWithBorders!
    @IBOutlet weak var leadQual: ViewWithBorders!
    @IBOutlet weak var myCard: ViewWithBorders!
    @IBOutlet weak var editPro: UIButton!
    @IBOutlet weak var community: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var leappsIcon: UIImageView!
    @IBOutlet weak var thanx: UILabel!
    @IBOutlet weak var locality: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var favorites: ViewWithBorders!
    
    @IBOutlet weak var contentView: UIView!
    var bday = 0 as CLong
    var datePickerD:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = UserDefaults.standard.string(forKey: "userName") {
            self.fullname.text = name
        }
        if let photo = UserDefaults.standard.string(forKey: "userPhotoURL") {
            setNewImage(linkToPhoto: photo, imageInput: avatar, isRounded: true)
        }
        
        editPro.layer.cornerRadius = 15
        editPro.clipsToBounds = true
        setGestures()
        self.portReg = self.storyboard?.instantiateViewController(withIdentifier: "navPortfolioReg") as! UINavigationController
        getSetProfileViewProApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSetProfileViewProApi()
    }
    
    @IBOutlet weak var counters: UIStackView!
    
    func getSetProfileViewProApi() {
        
        /*
         method to send GET request to server and receive JSON with user data
         using function from ApiServices
         */
        
        ApiServices.shared.getUserInfo(_id: KeychainWrapper.standard.string(forKey: "_id")!, parentViewController: self) {
            data, error in
            InitialViewController.isFullyChecked = true
            
            if error != nil {
                DispatchQueue.main.async {
                    self.view.makeToast(error?.localizedDescription, duration: 3, position: .bottom)
                }
                return
            }
            
            if let safeData = data {
                let fullName = "\(safeData.userInfo.name) \(safeData.userInfo.lastName)"
                UserDefaults.standard.setValue(safeData.userInfo.avatar, forKey: "userPhotoURL")
                setNewImage(linkToPhoto: safeData.userInfo.avatar, imageInput: self.avatar, isRounded: true)
                setNewImage(linkToPhoto: safeData.userInfo.coverPhoto, imageInput: self.coverPhoto, isRounded: false, placeholderPic: "topbg.png")
                UserDefaults.standard.setValue(fullName, forKey: "userName")
                if safeData.userInfo.portfolio?.jobName != nil {
                    UserDefaults.standard.set(true, forKey: "isFullyRegistered")
                }
                else {
                    UserDefaults.standard.set(false, forKey: "isFullyRegistered")
                }
                
                if let location = safeData.userInfo.location {
                    getCity(latitude: location.latitude, longitude: location.longitude, locationLabel: self.locality)
                }
                else {
                    self.locality.text = NSLocalizedString("ReusableFuncation.Label.LocationNotDefined", comment: "")
                }
                
                DispatchQueue.main.async {
                    self.thanx.text = "\(safeData.thanksCount)"
                    self.leapps.text = "\(safeData.leappCount)"
                    self.community.text = "\(safeData.communityCount)"
                    self.fullname.text = fullName
                }
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                }
            }
        }
    }
    
    func setGestures(){
        myCard.isUserInteractionEnabled = true
        let mc = UITapGestureRecognizer(target: self, action: #selector(mycard))
        myCard.addGestureRecognizer(mc)
        statistics.isUserInteractionEnabled = true
        let st = UITapGestureRecognizer(target: self, action: #selector(stats))
        statistics.addGestureRecognizer(st)
        promotions.isUserInteractionEnabled = true
        let pr = UITapGestureRecognizer(target: self, action: #selector(proms))
        promotions.addGestureRecognizer(pr)
        leadQual.isUserInteractionEnabled = true
        let lq = UITapGestureRecognizer(target: self, action: #selector(leadq))
        leadQual.addGestureRecognizer(lq)
        portfolio.isUserInteractionEnabled = true
        let pt = UITapGestureRecognizer(target: self, action: #selector(port))
        portfolio.addGestureRecognizer(pt)
        favorites.isUserInteractionEnabled = true
        let fv = UITapGestureRecognizer(target: self, action: #selector(favorite))
        favorites.addGestureRecognizer(fv)
        let cv = UITapGestureRecognizer(target: self, action: #selector(openCounter))
        counters.addGestureRecognizer(cv)
        
    }
    
    @objc func mycard(){
        let pVP =  self.storyboard?.instantiateViewController(withIdentifier: "ProView") as! ProfileViewPro
        pVP._id = KeychainWrapper.standard.string(forKey: "_id")!
        self.present(pVP, animated: true, completion: nil)
    }
    
    @objc func port(){
        if InitialViewController.isFullyChecked {
            if UserDefaults.standard.value(forKey: "isFullyRegistered") as! Bool {
                let ptST = self.storyboard?.instantiateViewController(withIdentifier: "Portfolio") as! Portfolio;
                
                self.present(ptST, animated: true, completion: nil)
                
            }
            else {
                self.present(self.portReg, animated: true, completion: nil)
            }
            
        }
        else {
            getSetProfileViewProApi()
        }
        
    }
    
    @objc func stats(){
        let stST = self.storyboard?.instantiateViewController(withIdentifier: "Statistics") as! Statistics;
        self.present(stST, animated: true, completion: nil)
    }
    
    
    @objc func favorite(){
        let fvST = self.storyboard?.instantiateViewController(withIdentifier: "Favorites") as! Favorites;
        self.present(fvST, animated: true, completion: nil)
    }
    
    @objc func openCounter(){
        let countV = self.storyboard?.instantiateViewController(withIdentifier: "Counters") as! InfoViewController;
        self.present(countV, animated: true, completion: nil)
        
    }
    
    
    @objc func leadq(){
        let lqST = self.storyboard?.instantiateViewController(withIdentifier: "LeadQualification") as! LeadQualification;
        self.present(lqST, animated: true, completion: nil)
    }
    
    
    @objc func proms(){
        let pmST = self.storyboard?.instantiateViewController(withIdentifier: "Promotions") as! Promotions;
        pmST.fullname = fullname.text!
        pmST.location = locality.text!
        pmST.leappCount = leapps.text!
        self.present(pmST, animated: true, completion: nil)
    }
    
}
