//
//  PreRegistration.swift
//  Leapper
//
//  Created by Kratos on 8/18/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit

class PreRegistration: UIViewController {
    
    @IBOutlet weak var profStack: UIStackView!
    @IBOutlet weak var clientStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mc = UITapGestureRecognizer(target: self, action: #selector(clientClicked))
        clientStack.isUserInteractionEnabled  = true
        clientStack.addGestureRecognizer(mc)
        
        let mp = UITapGestureRecognizer(target: self, action: #selector(profClicked))
        profStack.isUserInteractionEnabled  = true
        profStack.addGestureRecognizer(mp)
    }
    @objc func clientClicked(){
    DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "registrationClientNavBar") as! UINavigationController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
    }
    
    @objc func profClicked(){
        DispatchQueue.main.async {
            
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "registrationProNavBar") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    }
    }
}
