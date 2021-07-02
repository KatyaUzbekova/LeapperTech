//
//  LeappmeDialog.swift
//  Leapper
//
//  Created by Katya Uzbekova on 3/3/21.
//  Copyright © 2020 Leapper Technologies. All rights reserved.


import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import AVFoundation
import Social

class LeappmeDialog: UIViewController {
    
    var PHONENUMBER = KeychainWrapper.standard.string(forKey: "phoneNumber")!
    var fullname = ""
    var leappText:String!;
    var thanxOne:ThankYouOne!
    var whichNext = true
    var vc: LeadsInformationViewController!
    
    var _idSender = ""
    var _id = ""
    
    func setupNextControllers() {
        /*
         Setup next controllers
         */
        thanxOne = self.storyboard?.instantiateViewController(withIdentifier: "ThanxOne") as? ThankYouOne
        thanxOne.fullname = fullname
        thanxOne._id = _id
        vc = self.storyboard?.instantiateViewController(withIdentifier: "leadsLeappQualificationViewController") as? LeadsInformationViewController
    }
    
    func addAnimation() {
        
        /*
         Add Nice Gravity Leapp Animation with not-system sound
         */
        
        view.layer.addSublayer(confettiLayer)
        addGravityAnimation(to: confettiLayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.confettiLayer.birthRate = 0
        }
        playSound()
    }
    override func viewWillAppear(_ animated: Bool) {
        addAnimation()
    }
    override func viewDidLoad() {
        super .viewDidLoad()
        
        //check if we need to open LeadQualification window or fastly (skip LeadQualification) go to Leads Selection
        
        setupNextControllers()
        DispatchQueue.global().async {
            // Leapp Text
            let leappSharingText = NSLocalizedString("LeappmeDialog.Text.TextForSharing", comment: "Text for sharing")
            self.leappText = String.localizedStringWithFormat(leappSharingText, self.fullname)
            self.getLeadInfoApi()
        }
    }
    
    lazy var confettiTypes: [ConfettiType] = {
        let confettiColors = [
            (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
            (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
            (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
        ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }
        
        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    lazy var confettiCells: [CAEmitterCell] = {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            
            cell.beginTime = 0.00
            cell.birthRate = 7
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 100
            cell.yAcceleration = 150
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            cell.name = confettiType.name
            
            return cell
        }
    }()
    
    var player: AVAudioPlayer?
    @IBAction func returnToMainScreen() {
        
        if SessionManager.shared.isPro() {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
        else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navClient") as! UINavigationController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
    }
    func playSound() {
        guard let url = Bundle.main.url(forResource: "notif", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            UIDevice.vibrate()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func addGravityAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.duration = 6
        animation.keyTimes = [0.05, 0.1, 0.5, 1]
        animation.values = [0, 100, 2000, 4000]
        
        for image in confettiTypes {
            layer.add(animation, forKey: "emitterCells.\(image.name).yAcceleration")
        }
    }
    
    lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterCells = confettiCells
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 500)
        emitterLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 500)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.frame = view.bounds
        
        emitterLayer.beginTime = CACurrentMediaTime()
        
        for emitterCell in emitterLayer.emitterCells ?? [] {
            emitterCell.scale = 0.7
        }
        emitterLayer.speed = 0.95
        
        return emitterLayer
    }()
    
    
    func getLeadInfoApi() {
        
        /*
         method to send GET request to server and receive JSON with lead info of user by ID
         */
        
        let url = URL(string: "https://api.leapper.com/api/mobi/leadQualification/\(_id)")! //change the url
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
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    if !JSON(data!)["leadQuality"].isEmpty{
                        let dataJson = JSON(data!)["leadQuality"]
                        var leadTypeJson = NSLocalizedString("LeappmeDialog.Label.OnlyBusiness", comment: "Only business")
                        if dataJson["leadType"] == 1 {
                            leadTypeJson = NSLocalizedString("LeappmeDialog.Label.OnlyPersonal", comment: "Only personal")
                        }
                        else if dataJson["leadType"] == 2 {
                            leadTypeJson = NSLocalizedString("LeappmeDialog.Label.BothPersonalBusiness", comment: "Both personal and business")
                        }
                        
                        DispatchQueue.main.async {
                            self.vc.leadsTypeData = leadTypeJson
                            self.thanxOne.leadsTypeData = leadTypeJson
                            
                            let tempRadiusData = NSLocalizedString("LeappmeDialog.Label.RadiusAroundMe", comment: "Radius around me")
                            self.vc.radiusData = String.localizedStringWithFormat(tempRadiusData, self.fullname)
                            
                            self.thanxOne.radiusData = self.vc.radiusData
                            
                            if dataJson["gender"] == "both" {
                                let tempRadiusData = NSLocalizedString("LeappmeDialog.Label.MaleFemale", comment: "male and female")
                                                            
                                self.vc.ageData = String.localizedStringWithFormat(tempRadiusData, "\(JSON(data!)["leadQuality"]["ageMin"].int ?? 0)", "\(JSON(data!)["leadQuality"]["ageMax"].int ?? 100)")
                                self.thanxOne.ageData = String.localizedStringWithFormat(tempRadiusData, "\(JSON(data!)["leadQuality"]["ageMin"].int ?? 0)", "\(JSON(data!)["leadQuality"]["ageMax"].int ?? 100)")
                                
                            }
                            else {
                                let tempRadiusData = NSLocalizedString("LeappmeDialog.Label.OnlyOneGender", comment: "only male or only female")
                                
                                self.vc.ageData = String.localizedStringWithFormat(tempRadiusData, dataJson["gender"].string ?? "male","\(JSON(data!)["leadQuality"]["ageMin"].int ?? 0)", "\(JSON(data!)["leadQuality"]["ageMax"].int ?? 100)")
                                self.thanxOne.ageData = String.localizedStringWithFormat(tempRadiusData, dataJson["gender"].string ?? "male","\(JSON(data!)["leadQuality"]["ageMin"].int ?? 0)", "\(JSON(data!)["leadQuality"]["ageMax"].int ?? 100)")
                            }
                        }
                        
                    }
                    else {
                        self.whichNext = false
                    }
                    self.thanxOne.whichNext = self.whichNext
                    
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getLeadInfoApi()
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
    @IBAction func intoduce(_ sender: Any) {
        vc!.phoneNumber = PHONENUMBER
        vc!.fullname = fullname
        vc!._id = _id
        vc!._idSender = _idSender
        
        if whichNext {
            present(vc!, animated: true, completion: nil)
        }
        else {
            let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "LeadContactSelector") as? LeadContactSelector
            vc2!.fullname = self.fullname
            vc2!._id = _id
            vc2!._idSender = _idSender
            present(vc2!, animated: true, completion: nil)
        }
    }
    
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    
    func leappingApi(socialNetwork: String) {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: [String:Any] = [
            "senderId": "\(_idSender)", "getterId": "\(_id)",
            "leads": [
            ],
            "socialNetwork": socialNetwork
        ]
        AF.request("https://api.leapper.com/api/mobi/giveLeapp", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            let json = resp.data
            _ = String(data: json!, encoding: .utf8)
            do {
                _ = try JSON(data: json!)
            }
            catch {
            }
            
        }
    }
    @IBAction func whatsapp(_ sender: Any) {
        let sms: String = "whatsapp://send?text=\(self.leappText!)\(generateURLShare(id: self._id))".replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "%0A", with: "\n")
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        self.present(thanxOne, animated: true, completion: nil)
        leappingApi(socialNetwork: "WhatsApp")
    }
    
    
    @IBAction func linkedin(_ sender: Any) {
        var components = URLComponents(string: "https://www.linkedin.com/shareArticle")!
        components.queryItems = [
            URLQueryItem(name: "mini", value: "true"),
            URLQueryItem(name: "url", value: "\(generateURLShare(id: self._id))"),
            URLQueryItem(name: "title", value: "Leapper App"),
            URLQueryItem(name: "summary", value: self.leappText!)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let url = components.url!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        self.present(thanxOne, animated: true, completion: nil)
        leappingApi(socialNetwork: "Linkedin")
    }
    
    
    @IBAction func twitter(_ sender: Any) {
        var components = URLComponents(string: "https://twitter.com/intent/tweet")!
        components.queryItems = [
            URLQueryItem(name: "url", value: generateURLShare(id: self._id))
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let url = components.url!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        self.present(thanxOne, animated: true, completion: nil)
        leappingApi(socialNetwork: "Twitter")
    }
    
    
    @IBAction func facebook(_ sender: Any) {
        
        let items: [Any] = [self.leappText!, "\(generateURLShare(id: self._id))"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        leappingApi(socialNetwork: "Facebook")

        
//        var components = URLComponents(string: "https://www.facebook.com/sharer/sharer.php")!
//        components.queryItems = [
//            URLQueryItem(name: "u", value: "\(generateURLShare(id: self._id))"),
//            URLQueryItem(name: "quote", value: self.leappText!)
//        ]
//        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        let url = components.url!
//        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//        self.present(thanxOne, animated: true, completion: nil)
    }
}


extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


