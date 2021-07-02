//
//  CustomTabBarViewController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 18.03.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class CustomTabBarViewController: SwipeableTabBarController {


        override func viewDidLoad() {
            isCyclingEnabled = false
            isSwipeEnabled = false
//            let appearance = UITabBarItem.appearance()
//            print(appearance)
//            let attributes = [NSAttributedString.Key.font:UIFont(name: "roboto", size: 15)]
//
//            appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "roboto", size: 11)], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "roboto", size: 15)], for: .selected)

        }
      override func viewDidLayoutSubviews() {
           tabBar.frame = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 30)

           super.viewDidLayoutSubviews()
    }


}
