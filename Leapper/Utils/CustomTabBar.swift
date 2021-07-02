//
//  CustomTabBar.swift
//  Leapper
//
//  Created by Kratos on 1/24/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class CustomTabBar: SwipeableTabBarController {
  
  
    
    override func viewDidLoad() {
        isCyclingEnabled = false
        
        let appearance = UITabBarItem.appearance()

        let attributes = [NSAttributedString.Key.font:UIFont(name: "roboto", size: 15)]
        
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
    }
  override func viewDidLayoutSubviews() {
       tabBar.frame = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 30)

       super.viewDidLayoutSubviews()
   }
}
