//
//  InitialViewController.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON


func getSetProfileViewProApi(parentViewController: UIViewController) {
    
    /*
     method to send GET request to server and receive JSON with user data
     */
    
    let _id = KeychainWrapper.standard.string(forKey: "_id")!

    ApiServices.shared.getUserInfo(_id: _id, parentViewController: parentViewController) { data, error in
        if error == nil {
            InitialViewController.isFullyChecked = true
            if let safeData = data {
                if safeData.userInfo.portfolio?.jobName != nil {
                    UserDefaults.standard.set(true, forKey: "isFullyRegistered")
                }
                else {
                    UserDefaults.standard.set(false, forKey: "isFullyRegistered")
                }
            }

        }
    }
    
}

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    static var isFullyChecked = false
    

    
    override func viewDidAppear(_ animated: Bool) {
        if !SessionManager.shared.isLoggedIn() {
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
            }
        }else{
            DispatchQueue.global(qos: .background).async {
                ContactsTaker.shared.takeContactsFromThePhone()
            }
            if SessionManager.shared.isPro() {
                getSetProfileViewProApi(parentViewController: self)
                SessionManager.shared.loginUser(self, true)
            }
            else {
                SessionManager.shared.loginUser(self, false)
            }
        }
    }


}

