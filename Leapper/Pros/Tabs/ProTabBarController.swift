//
//  MytabControllerViewController.swift
//  Leapper
//
//  Created by Kratos on 8/29/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SideMenu
class ProTabBarController: UITabBarController,UITabBarControllerDelegate {
    var searchResultController: SearchViewFullLeapper!
    @IBOutlet weak var myTabs: UITabBar!
    var SearchFrame : CGRect?
    @IBAction func searchAction(_ sender: Any) {
        self.present(searchResultController!, animated: false, completion: nil)
    }
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        nextController = storyboard!.instantiateViewController(withIdentifier: "MenuBar") as? MenuBar
        
        self.delegate = self
        
        searchResultController = self.storyboard?.instantiateViewController(withIdentifier: "Professional") as? SearchViewFullLeapper
    }
    

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
            print("leapp_dialog_view")
        }else if tabItem?.tag == 3 {
            searchOutlet.isEnabled = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }else if tabItem?.tag == 4{
            searchOutlet.isEnabled = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var nextController: MenuBar!
    
    @IBAction func menu(_ sender: Any) {
        let sideMenu = SideMenuNavigationController(rootViewController: nextController)
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
    
    
    // UITabBarControllerDelegate
    private func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        
    }
    
}

