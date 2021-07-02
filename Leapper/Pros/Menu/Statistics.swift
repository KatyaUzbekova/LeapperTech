//
//  Statistics.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class Statistics: UIViewController {
    var leapsToInviteRatio =  [String]()
    var leadsToInviteRatio =  [String]()
    var newLeads = [String]()
    var leappsReceived = [String]()
    var socialMedia = [String]()
    var leappMe = [String]()
    var child: SpinnerViewController!
    
    var customerSendLeads = [String]()
    @IBOutlet weak var socialMediaOutlet: UILabel!
    @IBOutlet weak var leappsReceivedOutlet: UILabel!
    
    
    @IBOutlet weak var customerSendLeadsOutlet: UILabel!
    @IBOutlet weak var weeklyStatOutlet: UIButton!
    
    @IBOutlet weak var leappMeOutlet: UILabel!
    @IBAction func weeklyStatAction(_ sender: Any) {
        sliderOutlet.value = sliderOutlet.minimumValue
        leapsToInviteOutlet.text = leapsToInviteRatio[0]
        leadsToInviteOutlet.text = leadsToInviteRatio[0]
        newLeadsOutlet.text = newLeads[0]
        leappsReceivedOutlet.text = leappsReceived[0]
        socialMediaOutlet.text = socialMedia[0]
        customerSendLeadsOutlet.text = customerSendLeads[0]
        leappMeOutlet.text = leappMe[0]
        
    }
    @IBOutlet weak var sliderOutlet: CustomSlider!
    @IBOutlet weak var monthlyStatOutlet: UIButton!
    
    @IBAction func monthlyStatAction(_ sender: Any) {
        sliderOutlet.value = (sliderOutlet.maximumValue)/2
        leapsToInviteOutlet.text = leapsToInviteRatio[1] 
        leadsToInviteOutlet.text = leadsToInviteRatio[1]
        newLeadsOutlet.text = newLeads[1]
        leappsReceivedOutlet.text = leappsReceived[1]
        socialMediaOutlet.text = socialMedia[1]
        customerSendLeadsOutlet.text = customerSendLeads[1]
        leappMeOutlet.text = leappMe[1]
        
        
    }
    
    @IBOutlet weak var yearStatOutlet: UIButton!
    @IBAction func yearStatAction(_ sender: Any) {
        sliderOutlet.value = sliderOutlet.maximumValue
        leapsToInviteOutlet.text = leapsToInviteRatio[2]
        leadsToInviteOutlet.text = leadsToInviteRatio[2]
        newLeadsOutlet.text = newLeads[2]
        leappsReceivedOutlet.text = leappsReceived[2]
        socialMediaOutlet.text = socialMedia[2]
        customerSendLeadsOutlet.text = customerSendLeads[2]
        leappMeOutlet.text = leappMe[2]
        
    }
    
    @IBOutlet weak var leadsToInviteOutlet: UILabel!
    
    @IBOutlet weak var leapsToInviteOutlet: UILabel!
    
    @IBOutlet weak var newLeadsOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        getMyStats()
    }
    
    func getMyStats(){
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/getDetailedStats")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10000.0)
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        let decodedData = JSON(safeData)
                        let yearly = decodedData["statistics"]["yearly"]
                        let monthly = decodedData["statistics"]["monthly"]
                        let weekly = decodedData["statistics"]["weekly"]
                        self.leapsToInviteRatio = ["\(weekly["leappsRatio"].int ?? 0)", "\(monthly["leappsRatio"].int ?? 0)", "\(yearly["leappsRatio"].int ?? 0)"]
                        self.leadsToInviteRatio = ["\(weekly["leadsRatio"].int ?? 0)", "\(monthly["leadsRatio"].int ?? 0)", "\(yearly["leadsRatio"].int ?? 0)"]
                        self.newLeads = ["\(weekly["leadsCount"].int ?? 0)", "\(monthly["leadsCount"].int ?? 0)", "\(yearly["leadsCount"].int ?? 0)"]
                        self.leappsReceived = ["\(weekly["leappsRecievedCount"].int ?? 0)", "\(monthly["leappsRecievedCount"].int ?? 0)", "\(yearly["leappsRecievedCount"].int ?? 0)"]
                        self.socialMedia = ["\(weekly["socialRecommendsCount"].int ?? 0)", "\(monthly["socialRecommendsCount"].int ?? 0)", "\(yearly["socialRecommendsCount"].int ?? 0)"]
                        self.leappMe = ["\(weekly["invitesCount"].int ?? 0)", "\(monthly["invitesCount"].int ?? 0)", "\(yearly["invitesCount"].int ?? 0)"]
                        self.customerSendLeads = ["\(weekly["customersLeadsCount"].int ?? 0)", "\(monthly["customersLeadsCount"].int ?? 0)", "\(yearly["customersLeadsCount"].int ?? 0)"]
                        
                        DispatchQueue.main.async {
                            self.sliderOutlet.value = self.sliderOutlet.minimumValue
                            self.leapsToInviteOutlet.text = self.leapsToInviteRatio[0]
                            self.leadsToInviteOutlet.text = self.leadsToInviteRatio[0]
                            self.newLeadsOutlet.text = self.newLeads[0]
                            self.leappsReceivedOutlet.text = self.leappsReceived[0]
                            self.socialMediaOutlet.text = self.socialMedia[0]
                            self.customerSendLeadsOutlet.text = self.customerSendLeads[0]
                            self.leappMeOutlet.text = self.leappMe[0]
                            
                        }
                        DispatchQueue.main.async {
                            // then remove the spinner view controller
                            self.child.willMove(toParent: nil)
                            self.child.view.removeFromSuperview()
                            self.child.removeFromParent()
                        }
                        
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getMyStats()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
                
            }
        })
        task.resume()
    }
}


class CustomSlider: UISlider {
    
}

