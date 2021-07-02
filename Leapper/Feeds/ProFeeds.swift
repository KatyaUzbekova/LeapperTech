//
//  ProFeeds.swift
//  Leapper
//
//  Created by Katya Uzbekova on 1/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import AVFoundation
import Combine
import CoreData
import Kingfisher

class ProFeeds: UIViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    var feedItemViewArray = [FeedsModel]()
    var context = NSManagedObjectContext()
    var isNewPresent = false
    let refreshControl = UIRefreshControl()
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
    
    func checkIsFullyRegistered() {
        if SessionManager.shared.isPro() {
            getSetProfileViewProApi(parentViewController: self)
        }
    }

    @objc func gotNewMessage(notification: NSNotification) {
        self.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(gotNewMessage(notification:)), name: NSNotification.Name(rawValue: "ReloadFeed"), object: nil)

        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
        feedTableView.register(FeedUsualWithPhotoTableViewCell.self, forCellReuseIdentifier: "feedPhoto")
        feedTableView.register(MockPostTableViewCell.self, forCellReuseIdentifier: "mockPost")
        feedTableView.register(FeedRecommendedYouCell.self, forCellReuseIdentifier: "feedYou")
        feedTableView.register(FeedUsualTableViewCell.self, forCellReuseIdentifier: "feed")
        feedTableView.register(FeedPromoTableViewCell.self, forCellReuseIdentifier: "promo")
        
        
        if #available(iOS 10.0, *) {
            feedTableView.refreshControl = refreshControl
        }
        else {
            feedTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        feedItemViewArray = []
        feedTableView.reloadData()
        
        DispatchQueue.global(qos: .utility).async {
            self.getFeeds()
        }
    }
    
    
    lazy var confettiTypes: [ConfettiType] = {
        let confettiColors = [
            (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
            (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
            (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
        ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }
        
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
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "notif", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            
            guard let player = player else { return }
            UIDevice.vibrate()
            player.play()
            
        } catch {
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
    var isMockPostNeeded = false
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    func reloadData() {
        if feedItemViewArray.count == 0 {
            isMockPostNeeded = true
        }
        else {
            isMockPostNeeded = false
        }
        DispatchQueue.main.async {
            self.feedTableView.isHidden = false
            self.feedTableView.reloadData()
        }
    }
    func getFeeds(){
        let url = URL(string: "https://api.leapper.com/api/mobi/feed")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10000.0)
        
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    view.makeToast(error?.localizedDescription, duration: 3, position: .center)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    ProFeeds.firstLoad = true
                    if let safeData = data {
                        let json = JSON(safeData)
                        if let isNewPresentJson = json["isNewPresent"].bool{
                            isNewPresent = isNewPresentJson
                        }
                        let decodedData = json["feed"].array ?? []
                        for i in 0..<decodedData.count {
                            let time = "\(decodedData[i]["time"].string ?? "")"
                            
                            if let isPromo = decodedData[i]["promotion"].bool {
                                if isPromo {
                                    
                                    let namecheck = decodedData[i]["userPro"]["name"].string ?? ""
                                    let lastcheck = decodedData[i]["userPro"]["lastName"].string ?? ""
                                    
                                    let fullnameApiWho = "\(namecheck + " " + lastcheck)"
                                    let feedModelItem = FeedsModel(time: time, fullname: fullnameApiWho, proName: " ", _idWho: decodedData[i]["userPro"]["_id"].string!, _idWhom: "", profession: "", isWhoAvatar: decodedData[i]["userPro"]["avatar"].string, roleWho: decodedData[i]["userPro"]["role"].string.map { UsersType(rawValue: $0)! }, isNew: decodedData[i]["isNew"].bool ?? true, isPromo: true, promPic: decodedData[i]["imageUrl"].string, promName: decodedData[i]["title"].string, promDesc: decodedData[i]["description"].string, promAmount: "\(decodedData[i]["discount"].string ?? " ")", idPromo: decodedData[i]["_id"].string!, isShared:  decodedData[i]["isShared"].bool!)
                                    feedItemViewArray.append(feedModelItem)
                                }
                                
                            }
                            else {
                                
                                
                                var namecheck = decodedData[i]["who"]["name"].string ?? ""
                                var lastcheck = decodedData[i]["who"]["lastName"].string ?? ""
                                
                                let fullnameApiWho = "\(namecheck + " " + lastcheck)"
                                
                                
                                
                                namecheck = decodedData[i]["whom"]["name"].string ?? ""
                                lastcheck = decodedData[i]["whom"]["lastName"].string ?? ""
                                let fullnameApiWhom = "\(namecheck + " " + lastcheck)"
                                
                                var portPhotos = [String]()
                                
                                let portfolioLinks = decodedData[i]["whom"]["portfolio"]["photos"]
                                for linkPortfolio in 0..<portfolioLinks.count {
                                    portPhotos.append("\(portfolioLinks[linkPortfolio])")
                                }
                                
                                let leadsArray = decodedData[i]["leads"].array
                                var leadsArrayPut = [clientLeadModel]()
                                if leadsArray != nil {
                                    for lead in 0..<leadsArray!.count {
                                        leadsArrayPut.append(clientLeadModel(recall: leadsArray![lead]["recall"].bool!, recieveTime: leadsArray![lead]["recieveTime"].string!, phone: "\(leadsArray![lead]["phone"].int!)", fullName: leadsArray![lead]["fullName"].string!, isContacted: leadsArray![lead]["isContacted"].bool!, leadStatus: leadsArray![lead]["leadStatus"].string!, _id: leadsArray![lead]["_id"].string!))
                                    }
                                }
                                
                                if let myId = KeychainWrapper.standard.string(forKey: "_id") {
                                    feedItemViewArray.append(FeedsModel(time: time, fullname: fullnameApiWho, proName: fullnameApiWhom, _idWho: "\(decodedData[i]["who"]["_id"])", _idWhom: "\(decodedData[i]["whom"]["_id"])", profession: "\(decodedData[i]["whom"]["portfolio"]["jobName"].string ?? NSLocalizedString("ProfileViewPro.Label.ProfessionNotDefined", comment: "profession not defined"))", socialNetwork: decodedData[i]["socialNetwork"].string,photosForSliderView: portPhotos, isWhoAvatar: decodedData[i]["who"]["avatar"].string, isWhomAvatar: decodedData[i]["whom"]["avatar"].string, roleWho: decodedData[i]["who"]["role"].string.map { UsersType(rawValue: $0)! }, roleWhom: decodedData[i]["whom"]["role"].string.map { UsersType(rawValue: $0)! }, isNew: decodedData[i]["isNew"].bool ?? true, isPromo: false, isMeRecommended: myId  == "\(decodedData[i]["whom"]["_id"])", leads: leadsArrayPut))
                                }

                            }
                        }
                        
                        self.reloadData()
                    }
                
                    if isNewPresent {
                        DispatchQueue.main.async {
                            addAnimation()
                        }
                        isNewPresent = false
                    }
                    
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getFeeds()
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
    
    
    @objc func refreshData(){
        feedItemViewArray = []
        getFeeds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    static var firstLoad = false
}



//MARK: TableView DataSource and Delegate
extension ProFeeds: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + feedItemViewArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var indexCurrent = indexPath.row
        
        if !UserDefaults.standard.bool(forKey: "isFullyRegistered") {
            if !ProFeeds.firstLoad {
                if indexCurrent == feedItemViewArray.count {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "mockPost") as? MockPostTableViewCell {
                        cell.secondPost = true
                        cell.parent = self
                        return cell
                    }
                }
            }
            
            var mockPostCompareValue = 0        // id of default cell
            if (!SessionManager.shared.isPro()) {   // if pro account -> showing portfolio registration on top
                mockPostCompareValue = feedItemViewArray.count
            }
            
            if indexCurrent == mockPostCompareValue {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "mockPost") as? MockPostTableViewCell {
                    cell.secondPost = false
                    cell.parent = self
                    return cell
                }
            } else if (SessionManager.shared.isPro()) {
                indexCurrent -= 1
            }
        }
        else {
            if indexCurrent == feedItemViewArray.count {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "mockPost") as? MockPostTableViewCell {
                    cell.secondPost = true
                    cell.parent = self
                    return cell
                }
            }
        }
        
        if feedItemViewArray.count > indexCurrent {
            if self.feedItemViewArray[indexCurrent].isPromo {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "promo") as? FeedPromoTableViewCell {
                    cell.selectionStyle = .none
                    cell.parent = self
                    cell.chatMessage = self.feedItemViewArray[indexCurrent]
                    return cell
                }
            }
            else {
                if self.feedItemViewArray[indexCurrent].isMeRecommended {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "feedYou") as? FeedRecommendedYouCell {
                        cell.selectionStyle = .none
                        cell.parent = self
                        cell.chatMessage = self.feedItemViewArray[indexCurrent]
                        return cell
                    }
                }
                else {
                    if self.feedItemViewArray[indexCurrent].photosForSliderView?.count == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "feed") as? FeedUsualTableViewCell {
                            cell.selectionStyle = .none
                            cell.parent = self
                            cell.isYouRecommended = false
                            cell.chatMessage = self.feedItemViewArray[indexCurrent]
                            return cell
                        }
                    }
                    else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "feedPhoto") as? FeedUsualWithPhotoTableViewCell {
                            cell.selectionStyle = .none
                            cell.parent = self
                            cell.isYouRecommended = false
                            cell.chatMessage = self.feedItemViewArray[indexCurrent]
                            return cell
                        }
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if feedItemViewArray.count > indexPath.row {
            let indexCurrent: Int?
            
            if (SessionManager.shared.isPro()) {
                if (UserDefaults.standard.bool(forKey: "isFullyRegistered")) {
                    indexCurrent = indexPath.row
                } else {
                    if (indexPath.row > 0) {
                        indexCurrent = indexPath.row - 1
                    } else { return }
                }
            } else {
                indexCurrent = !UserDefaults.standard.bool(forKey: "isFullyRegistered") ? indexPath.row : indexPath.row+1
            }
            
            guard let indexCurrent = indexCurrent else { return }
            
            if !feedItemViewArray[indexCurrent].isPromo && !feedItemViewArray[indexCurrent].isMeRecommended || (feedItemViewArray[indexCurrent].isMeRecommended && feedItemViewArray[indexCurrent].leads?.count == 0) {
                let proView = self.storyboard?.instantiateViewController(withIdentifier: "ProServiceUsers") as? BusinessCardViewController
                proView?._id = feedItemViewArray[indexCurrent]._idWhom
                proView?.fullNameText = feedItemViewArray[indexCurrent].proName
                proView?.avatarLink = feedItemViewArray[indexCurrent].isWhomAvatar
                if ReachabilityTest.isConnectedToNetwork() {
                    self.present(proView!, animated: true, completion: nil)
                }
            }
            else if feedItemViewArray[indexCurrent].isMeRecommended{
                let leadView = (self.storyboard?.instantiateViewController(withIdentifier: "LeadView") as! LeadView)
            //    leadView._id = leadCollection!._id
                leadView.lf = (feedItemViewArray[indexCurrent].leads)!
                leadView.fullname = feedItemViewArray[indexCurrent].fullname
                if ReachabilityTest.isConnectedToNetwork() {
                    self.present(leadView, animated: true, completion: nil)
                }
            }
        }
        
    }
}
