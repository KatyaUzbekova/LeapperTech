//
//  Client.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SideMenu

class ClientTabBarController: UITabBarController{
    
    var searchResultController: SearchViewFullLeapper!
    
    @IBOutlet weak var myTabs: UITabBar!
    var SearchFrame : CGRect?
    @IBAction func searchAction(_ sender: Any) {
        self.present(searchResultController!, animated: false, completion: nil)
    }
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.delegate = self
        
        searchResultController = self.storyboard?.instantiateViewController(withIdentifier: "Professional") as? SearchViewFullLeapper
        searchResultController.isPro = false
    }
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBAction func menu(_ sender: Any) {
        let next = storyboard!.instantiateViewController(withIdentifier: "MenuBar") as! MenuBar
        let sideMenu = SideMenuNavigationController(rootViewController: next)
        sideMenu.leftSide = true
        sideMenu.menuWidth = self.view.frame.width * 0.85
        sideMenu.navigationBar.isHidden = true
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage == "he" {
            SideMenuManager.default.rightMenuNavigationController = sideMenu
        }
        else {
            SideMenuManager.default.leftMenuNavigationController = sideMenu
        }
        
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        self.present(sideMenu, animated: true, completion: nil)
    }
    
    
    
}


// MARK: TabBar Extension
extension ClientTabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        let tabItem = tabBar.selectedItem
        if tabItem?.tag == 0{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            searchOutlet.isEnabled = true
            searchResultController?.searchType = "global"
        }else if tabItem?.tag == 1 {
            searchOutlet.isEnabled = true
            searchResultController?.searchType = "local"
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
        }else if tabItem?.tag == 2 {
            searchOutlet.isEnabled = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }else if tabItem?.tag == 3 {
            searchOutlet.isEnabled = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // UITabBarControllerDelegate
    private func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        
    }
    
}
