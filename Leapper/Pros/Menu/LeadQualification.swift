//
//  LeadQualification.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire


class LeadQualification: UIViewController {
    
    var indexLeadType = 2
    var indexlocationRadius = 3
    var indexGender = 2
    var child: SpinnerViewController!

    @IBOutlet weak var radiusValue: UISlider!
    @IBAction func radiusValueChanged(_ sender: Any) {
        radius = Int(radiusValue.value)
        radiusToIndex(radius)
    }
    @IBAction func leadType(_ sender: Any) {
        indexLeadType = leadTypeController.selectedSegmentIndex
    }
    
    @IBAction func locationRadius(_ sender: Any) {
        indexlocationRadius = radiusController.selectedSegmentIndex
        indexToRadius(indexlocationRadius)
    }
    
    @IBAction func gender(_ sender: Any) {
        indexGender = genderController.selectedSegmentIndex
    }

    
    @IBOutlet weak var genderController: UISegmentedControl!
    @IBOutlet weak var radiusController: UISegmentedControl!
    @IBOutlet weak var leadTypeController: UISegmentedControl!
    @IBOutlet weak var ageFrom: UITextField!
    @IBOutlet weak var ageUpTo: UITextField!

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onlySetLeadQualificationsApi()
    }
    var radius = 0
    func radiusToIndex(_ radiusTaken: Int) {
        if radiusTaken >= 0 && radiusTaken < 50 {
            indexlocationRadius = 0
        }
        else if radiusTaken >= 50 && radiusTaken < 100 {
            indexlocationRadius = 1
        }
        else if radiusTaken >= 100 && radiusTaken < 150 {
            indexlocationRadius = 2
        }
        else {
            indexlocationRadius = 3
        }
        DispatchQueue.main.async {
            self.radiusController.selectedSegmentIndex = self.indexlocationRadius
            self.radiusValue.value = Float(radiusTaken)
        }
        
    }
    
    func indexToRadius(_ index: Int) {
        switch index {
        case 0:
            radius = 0
            break
        case 1:
            radius = 50
            break
        case 2:
            radius = 100
            break
        case 3:
            radius = 150
            break
        default:
            radius = 100
            break
        }
        radiusValue.value = Float(radius)
    }
    func colorsStyleViewDidLoad() {
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        radiusController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 252.0/255.0, green: 33/255.0, blue: 95.0/255.0, alpha:1.0)], for: .normal)
        radiusController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        genderController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 252.0/255.0, green: 33/255.0, blue: 95.0/255.0, alpha:1.0)], for: .normal)
        genderController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        leadTypeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 252.0/255.0, green: 33/255.0, blue: 95.0/255.0, alpha:1.0)], for: .normal)
        leadTypeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        colorsStyleViewDidLoad()
        getSetLQ()
    }
    func onlySetLeadQualificationsApi() {

        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        print(accessToken)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        var gender = ""
        if indexGender == 0 {
            gender = "male"
        }
        else if indexGender == 1 {
            gender = "female"
        }
        else {
            gender = "both"
        }
        
        let parameters: [String:Any] = [
            "leadType": indexLeadType,
            "radius": radius,
            "gender": gender,
            "ageMin": ageFrom.text ?? 0,
            "ageMax": ageUpTo.text ?? 0
        ]
        print(parameters)
        AF.request("https://api.leapper.com/api/mobi/leadQualification", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                print(resp)
                    if let err = resp.error{
                        print(err)
                        return
                    }
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
                self.onlySetLeadQualificationsApi()
            }
            else if resp.response?.statusCode == 200 {
            }
        
    }
    }
    
    func getSetLQ(){
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/leadQualification")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
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
                        let jsonSafeData = JSON(safeData)
                        print(jsonSafeData)
                        self.radius = jsonSafeData["leadQuality"]["radius"].int ?? 100
                        self.radiusToIndex(self.radius)
                        self.indexLeadType = jsonSafeData["leadQuality"]["leadType"].int ?? 2
                        DispatchQueue.main.async {
                            self.leadTypeController.selectedSegmentIndex = jsonSafeData["leadQuality"]["leadType"].int ?? 2
                            self.ageFrom.text = "\(jsonSafeData["leadQuality"]["ageMin"].int ?? 0)"
                            self.ageUpTo.text = "\(jsonSafeData["leadQuality"]["ageMax"].int ?? 100)"
                        }

                        let gender = jsonSafeData["leadQuality"]["gender"].string ?? "both"
                        if gender.lowercased() == "female" {
                            DispatchQueue.main.async {
                                self.indexGender = 1
                            self.genderController.selectedSegmentIndex = 1
                            }
                        }
                        else if gender.lowercased() == "male" {
                            DispatchQueue.main.async {
                                self.indexGender = 0

                            self.genderController.selectedSegmentIndex = 0
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.indexGender = 2

                            self.genderController.selectedSegmentIndex = 2
                            }
                        }

                    }
                    DispatchQueue.main.async {
                        // then remove the spinner view controller
                        self.child.willMove(toParent: nil)
                        self.child.view.removeFromSuperview()
                        self.child.removeFromParent()
                    }
                    
            }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getSetLQ()
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
