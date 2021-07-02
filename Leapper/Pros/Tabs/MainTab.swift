//
//  MainTab.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class MainTab: UITabBarController {
     lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    override func viewDidLoad() {
        super .viewDidLoad()
           let searchBar = UISearchBar()
       searchBar.sizeToFit()
       searchBar.placeholder = ""
       self.navigationController?.navigationBar.topItem?.titleView = searchBar}
}
