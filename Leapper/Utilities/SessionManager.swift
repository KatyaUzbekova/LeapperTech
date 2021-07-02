//
//  SessionManager.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import UIKit
import Foundation
import SwiftKeychainWrapper
class SessionManager{
    static let shared = SessionManager()
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLogged")
    }
    
    func isPro() -> Bool {
        return UserDefaults.standard.bool(forKey: "isPro")
    }
    
    func logOutUser(_ parent: UIViewController){
        AppDelegate.socket.disconnect()
        KeychainWrapper.standard.removeObject(forKey: "PhoneNumber")
        UserDefaults.standard.removeObject(forKey: "isPro")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userPhotoURL")
        UserDefaults.standard.removeObject(forKey: "isFullyRegistered")
        KeychainWrapper.standard.removeObject(forKey: "_id")
        
        UserDefaults.standard.set(false, forKey: "isLogged")
        postToUnregister() {
        }
        
        DispatchQueue.main.async {
            let vc = parent.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
        
    }
    
    func notificationCountStart() {
        let userId = KeychainWrapper.standard.string(forKey: "_id")!
        AppDelegate.socket.emit("notifications-count",
                                ["userId": userId])
        AppDelegate.socket.on("notifications-count") { data,_  in
            let userIdJson = data[1] as? String ?? ""
            let messagesCount = data[0] as? Int ?? 0
            UIApplication.shared.applicationIconBadgeNumber = messagesCount
            let userInfo:[String: String] = ["messages-count": "\(messagesCount)"]
            if userId == userIdJson{
                NotificationCenter.default.post(name: NSNotification.Name("newMessage"), object: nil, userInfo: userInfo)
            }
        }
    }
    
    func loginUser(_ parent: UIViewController, _ isPro:Bool){
        
        UserDefaults.standard.set(isPro, forKey: "isPro")
        UserDefaults.standard.set(true, forKey: "isLogged")
        
        AppDelegate.socket.connect()
        notificationCountStart()
        
        if isPro {
            DispatchQueue.main.async {
                let vc = parent.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                // parent.present(vc, animated: true, completion: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
                
            }
        }else {
            DispatchQueue.main.async {
                let vc = parent.storyboard?.instantiateViewController(withIdentifier: "navClient") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
            }
        }
        
    }
}
