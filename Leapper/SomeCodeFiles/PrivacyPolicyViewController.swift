//
//  PrivacyPolicyViewController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 21.03.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var textPrivacyPolicy: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") // file path for file "data.txt"
        print("PRIVACY: \(path)")
        do {
            let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            textPrivacyPolicy.text = string
        }
        catch {
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PRIVACY")
    }
}
