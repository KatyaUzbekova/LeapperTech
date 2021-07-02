//
//  EditProfilePro.swift
//  Leapper
//
//  Created by Kratos on 9/15/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import YPImagePicker
import CoreLocation
import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import LocationPicker
import Kingfisher

class EditProfilePro: UIViewController, UITextFieldDelegate {
    var bday = 0 as Double
    var locationManager:CLLocationManager!
    var userDatas = [String : Any ]()
    var latitude:Double = 0
    var longitude:Double = 0
    var avatarLink: String?
    var coverLink: String?
    @IBOutlet weak var coverPhoto: UIImageView!
    
    @IBAction func changeCover(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                createUserDir(phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
                if let image = photo.modifiedImage {
                    self.uploadImage(image: image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, isAvatar: false)
                }
                else {
                    self.uploadImage(image: photo.image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, isAvatar: false)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    @IBOutlet weak var avatar: UIImageView!
    
    @IBAction func changeAvatar(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                createUserDir(phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
                if let image = photo.modifiedImage {
                    self.uploadImage(image: image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, isAvatar: true)
                }
                else {
                    self.uploadImage(image: photo.image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, isAvatar: true)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var birthday: DateTextField!
    
    @IBAction func saveAction(_ sender: Any) {
        saveButtonAction()
    }
    func saveButtonAction() {
        if ReachabilityTest.isConnectedToNetwork() {
            let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            var bd = ""
            if let bdTemp = birthday.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                bd = dateFormatter.string(from: bdTemp)
            }
            var parameters = [String : Any ]()
            
            if name.text == "" {
                parameters["name"] =  userDatas["name"]!
            }
            else {
                parameters["name"] =  name.text
            }
            
            if lastName.text == "" {
                parameters["lastName"] = userDatas["lastName"]!
            }
            else {
                parameters["lastName"] =  lastName.text
            }
            
            if SessionManager.shared.isPro() {
                
                if email.text == "" {
                    parameters["email"] =  userDatas["email"]!
                }
                else {
                    parameters["email"] =  email.text
                }
                
                parameters["avatar"] = userDatas["avatarLink"] ?? ""
                
                parameters["coverPhoto"] = userDatas["coverPhoto"] ?? ""
                
                if website.text == "" {
                    parameters["webSite"] = userDatas["webSite"]!
                }
                else {
                    parameters["webSite"] = website.text
                }
                
                if bd == "" {
                    parameters["birthday"] = userDatas["birthDay"]!
                }
                else {
                    parameters["birthday"] = bd
                }
                
                parameters["lon"] = location?.coordinate.longitude
                parameters["lat"] = location?.coordinate.latitude
                
            }
            AF.request("https://api.leapper.com/api/mobi/patchUser", method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                
                if let err = resp.error{
                    print(err)
                    return
                }
                
                if resp.response?.statusCode == 403 {
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.saveButtonAction()
                }
                else if resp.response?.statusCode == 200 {
                    if SessionManager.shared.isPro() {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                        // parent.present(vc, animated: true, completion: nil)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = vc
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navClient") as! UINavigationController
                            // parent.present(vc, animated: true, completion: nil)
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = vc
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
                
                
            }
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            // parent.present(vc, animated: true, completion: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
            self.dismiss(animated: true, completion: nil)        }
    }
    
    func uploadImage(image: UIImage, phone username: String, isAvatar: Bool) {
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image.jpegData(compressionQuality: 0.2)!, withName: "file" , fileName: "\(image)", mimeType: "image/jpeg")
            },
            to: "https://api.leapper.com/files/api/\(username)/uploadImage", method: .post , headers: headers)
            .response { resp in
                if let err = resp.error{
                    print(err)
                    return
                }
                let json = resp.data
                if (json != nil)
                {
                    do {
                        let jsonObject = try JSON(data: json!)
                        if isAvatar {
                            setNewImage(linkToPhoto: jsonObject["hashedFilePathes"][0].stringValue, imageInput: self.avatar, isRounded: true)
                            self.userDatas["avatarLink"] = jsonObject["hashedFilePathes"][0].stringValue
                            
                        }
                        else {
                            setNewImage(linkToPhoto: jsonObject["hashedFilePathes"][0].stringValue, imageInput: self.coverPhoto, isRounded: false, placeholderPic: "topbg.png")
                            self.userDatas["coverPhoto"] = jsonObject["hashedFilePathes"][0].stringValue
                            
                            
                        }
                    }
                    catch {
                    }
                }
            }
        
    }
    
    
    func getSetProfileViewProApi() {
        
        /*
         method to send GET request to server and receive JSON with user data
         */
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/getUser")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            print(response)
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        do {
                            let json = JSON(safeData)
                            print(json)
                            setNewImage(linkToPhoto: json["userInfo"]["avatar"].string, imageInput: self.avatar, isRounded: true)
                            
                            setNewImage(linkToPhoto: json["userInfo"]["coverPhoto"].string, imageInput: self.coverPhoto, isRounded: false, placeholderPic: "topbg.png")
                            
                            self.userDatas["name"] = "\(json["userInfo"]["name"].string ?? "")"
                            self.userDatas["lastName"] = "\(json["userInfo"]["lastName"].string ?? "")"
                            self.userDatas["avatarLink"] = "\(json["userInfo"]["avatar"])"
                            self.userDatas["birthDay"] = json["userInfo"]["birthday"].string ?? ""
                            self.userDatas["coverPhoto"] = "\(json["userInfo"]["coverPhoto"])"
                            self.userDatas["email"] = "\(json["userInfo"]["email"].string ?? "")"
                            self.userDatas["webSite"] = "\(json["userInfo"]["webSite"].string ?? "https://")"
                            
                            DispatchQueue.main.async {
                                self.name.text = self.userDatas["name"] as! String
                                self.lastName.text = self.userDatas["lastName"] as! String
                                // Set User Locality
                                if json["userInfo"]["location"]["latitude"].double != nil {
                                    self.latitude =  json["userInfo"]["location"]["latitude"].double!
                                    if json["userInfo"]["location"]["longitude"].double != nil {
                                        self.longitude =  json["userInfo"]["location"]["longitude"].double!
                                        getCity(latitude: self.latitude, longitude:self.longitude ,locationLabel:  self.adressLabel)
                                    }
                                    else {
                                        self.location = nil
                                    }
                                }
                                else {
                                    self.location = nil
                                }
                                
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                if let timeInDateFormat = dateFormatter.date(from: self.userDatas["birthDay"] as! String) {
                                    dateFormatter.dateFormat = "dd MM yyyy"
                                    self.birthday.text = dateFormatter.string(from: timeInDateFormat)
                                }
                                self.email.text = self.userDatas["email"] as! String
                                self.website.text = self.userDatas["webSite"] as! String
                            }
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getSetProfileViewProApi()
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
    
    
    
    @objc func tapBirthday(sender:UITapGestureRecognizer){
        
    }
    
    
    
    @objc
    func tapGetLocation(sender:UITapGestureRecognizer) {
        
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let locationPicker = LocationPickerViewController()
        locationPicker.completion = { self.location = $0 }
        locationPicker.mapType = .standard
        locationPicker.location = location
        locationPicker.showCurrentLocationButton = true
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.selectCurrentLocationInitially = true
        self.navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    var location: Location? {
        didSet {
            adressLabel.text = location.flatMap({ $0.title }) ?? NSLocalizedString("ReusableFuncation.Label.LocationNotDefined", comment: "")
        }
    }
    
    @IBOutlet weak var emailNameLabel: UILabel!
    @IBOutlet weak var websiteNameLabel: UILabel!
    @IBOutlet weak var birthdayNameLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
        lastName.delegate = self
        getSetProfileViewProApi()

        if !SessionManager.shared.isPro() {
            adressLabel.isHidden = true
            email.isHidden = true
            emailNameLabel.isHidden = true
            websiteNameLabel.isHidden = true
            birthdayNameLabel.isHidden = true
            addressNameLabel.isHidden = true
            
            website.isHidden = true
            birthday.isHidden = true
        }
        
        else {
            birthday.dateFormat = .dayMonthYear
            birthday.separator = "  "
            birthday.placeholder = "dd mm yyyy"            
            
            email.delegate = self
            website.delegate = self
            adressLabel.isUserInteractionEnabled = true
            let tapLoc = UITapGestureRecognizer(target: self, action: #selector(tapGetLocation(sender:)))
            adressLabel.addGestureRecognizer(tapLoc)
        }
        
    }
    
    var datePickerD:UIDatePicker!
    
    @objc func handleDatPicker(sender: UIDatePicker){
        self.bday = Double(sender.date.timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        birthday.text = dateFormatter.string(from: sender.date)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    func editRequest() {
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request("https://api.leapper.com/api/mobi/portfolio", method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
            }
            else if resp.response?.statusCode == 200 {
                UserDefaults.standard.set(true, forKey: "isFullyRegistered")
                self.dismiss(animated: true, completion: nil)
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.first) != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
}

extension EditProfilePro:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
}

