//
//  Navigator.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 07.12.2020.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit


struct Navigator {
    
    func getDestination(for url: URL) -> UIViewController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let navController = storyboard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
        //  navController.tabBarController?.selectedIndex = 2
        let destination = Destination(for: url)
        switch destination {
        
        case .users:
            appDelegate.window?.rootViewController = navController
            appDelegate.window?.makeKeyAndVisible()
            return navController
            
        case .userDetails(let userId):
            
            guard let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro else {
                return nil }
            userDetailsVC._id = userId!
            navController.pushViewController(userDetailsVC, animated: false)
            
            appDelegate.window?.rootViewController = navController
            // window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
            //   navController.present(userDetailsVC, animated: false, completion: nil)
            
            return userDetailsVC
            
        case .safari: return nil
        }
        
    }
    
    enum Destination {
        
        case users
        
        case userDetails(String?)
        
        case safari
        
        init(for url: URL) {
            
            let userId = (url.lastPathComponent)
            if userId == "/" || userId == "" {
                
                self = .users
                
            } else  {
                
                self = .userDetails(userId)
                
            }
        }
    }
    
}
