//
//  ProfileViewPro.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import AddressBook
import Contacts
import UIKit
import MapKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import Kingfisher
import ImageViewer_swift
import Nantes

class ProfileViewPro: UIViewController {
    var child: SpinnerViewController!
    @IBOutlet weak var countersField: UIStackView!
    var leappmeDialog:LeappmeDialog!
    
    var phoneNumber = ""
    var NAME = ""
    var _id = ""
    @IBOutlet weak var phone: UIStackView!
    
    @IBOutlet weak var aboutMeTextUIView: UIView!
    @IBOutlet weak var aboutMeTextLabel: UILabel!
    @IBOutlet weak var email: UIStackView!
    @IBOutlet weak var chat: UIStackView!
    
    @IBOutlet weak var navigate: UIStackView!
    
    @IBOutlet weak var adress: UIStackView!
    
    @IBOutlet weak var portfolioLabelHidden: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var website: UIStackView!
    @IBOutlet weak var portfolioCollections: UICollectionView!
    
    
    @IBOutlet weak var leadsQualificationLabel: UILabel!
    @IBOutlet weak var leadsQualificationUIView: UIView!
    @IBOutlet weak var community: UILabel!
    @IBOutlet weak var leapps: UILabel!
    @IBOutlet weak var thanx: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var locality: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var aboutme: NantesLabel! 
    @IBOutlet weak var leadqualification: UILabel!
    @IBOutlet weak var portfolioCollecttionUIView: UIView!
    
    
    
    @IBOutlet weak var noMutualsLabel: UILabel!
    @IBOutlet weak var noNonmutualsLabel: UILabel!
    
    @IBOutlet weak var promotionsNotCreatedLabel: UILabel!
    @IBOutlet weak var nonMutualsConnectionView: UICollectionView!
    @IBOutlet weak var MutualsCollectionView: UICollectionView!
    
    var mutualsItemarray = [ServiceUsersModel]()
    var nonMutualsItemArray = [ServiceUsersModel]()
    var portfolioItemViewArray = [String]()
    var promotionItemsList = [PromotionModel]()
    var images = [UIImage]()
    var ss:ProfileViewClient!
    var lat = 0.0
    var long = 0.0
    
    @IBOutlet weak var lbutton:UIButton!
    static var isAnimationGoes = false
    var messenger:ParticularChatViewController!
    
    var countV:UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        child = createSpinnerView(controllerParent: self, viewParent: self.view)
        
        addToContactsButton.layer.borderWidth = 1
        aboutme.delegate = self
        aboutme.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 6/255, green: 69/255, blue: 173/255, alpha: 1), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        aboutme.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 11/255, green: 0, blue: 128/255, alpha: 1)]
        self.messenger = (self.storyboard?.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController)
        
        getSetProfileViewProApi()
        setOnClicks()
        leappmeDialog = self.storyboard?.instantiateViewController(withIdentifier: "LeappMeDialog") as? LeappmeDialog
        ss = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient        
        sU = self.storyboard?.instantiateViewController(withIdentifier: "ProServiceUsers") as? BusinessCardViewController
        countV = self.storyboard?.instantiateViewController(withIdentifier: "Counters") as? InfoViewController
        let cv = UITapGestureRecognizer(target: self, action: #selector(openCounter))
        countersField.addGestureRecognizer(cv)
        
        promsTableView.dataSource = self
        promsTableView.delegate = self
        getLeadInfoApi()
        getPromotionApi()
        
        portfolioCollections.dataSource = self
        portfolioCollections.delegate  = self
        
        
        
        MutualsCollectionView.dataSource = self
        MutualsCollectionView.delegate = self
        
        
        nonMutualsConnectionView.dataSource = self
        nonMutualsConnectionView.delegate = self
        getMutualsApi()
    }
    var linksToPhotos = [URL]()
    private let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    
    func getSetProfileViewProApi() {
        
        /*
         method to send GET request to server and receive JSON with user data
         */
        
        ApiServices.shared.getUserInfo(_id: _id, parentViewController: self) {
            data, error in
            
            self.child.willMove(toParent: nil)
            self.child.view.removeFromSuperview()
            self.child.removeFromParent()
            
            if error != nil {
                Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
            }
            else {
                if let safeData = data {
                    setNewImage(linkToPhoto: safeData.userInfo.avatar, imageInput: self.avatar, isRounded: true)
                    setNewImage(linkToPhoto: safeData.userInfo.coverPhoto, imageInput: self.coverPhoto, isRounded: false, placeholderPic: "topbg.png")
                    if let location = safeData.userInfo.location {
                        self.lat = location.latitude
                        self.long = location.longitude
                        getCity(latitude: self.lat, longitude:self.long ,locationLabel:  self.locality)
                    }
                    self.portfolioItemViewArray.removeAll()
                    
                    DispatchQueue.main.async {
                        self.phoneNumber = "+\(safeData.userInfo.phone)"
                        self.fullname.text = "\(safeData.userInfo.name) \(safeData.userInfo.lastName)"
                        self.messenger.linkToAvatar = safeData.userInfo.avatar
                        self.messenger.fullnameText = self.fullname.text ?? ""
                        self.messenger.idWhom = self._id
                        
                        self.messenger.roleWho = UsersType.professional
                        self.messenger.isOpenedFromLists = true
                        self.messenger.CHATTERPHONE = self.phoneNumber
                        self.chat.isUserInteractionEnabled = true
                        
                        self.thanx.text = "\(safeData.thanksCount)"
                        self.leapps.text = "\(safeData.leappCount)"
                        self.community.text = "\(safeData.communityCount)"
                        if let portfoilo = safeData.userInfo.portfolio {
                            
                            if portfoilo.info != nil {
                                self.aboutme.text = portfoilo.info!
                            }
                            else {
                                self.aboutMeTextLabel.isHidden = true
                                self.aboutMeTextUIView.isHidden = true
                                self.aboutme.isHidden = true
                            }
                            
                            self.profession.text = portfoilo.jobName ?? NSLocalizedString("ProfileViewPro.Label.ProfessionNotDefined", comment: "")
                            
                            //  Get Portfolio Pics
                            let portfolioLinks = portfoilo.photos
                            
                            for linkPortfolio in portfolioLinks ?? [] {
                                self.portfolioItemViewArray.append(linkPortfolio)
                                self.linksToPhotos.append(URL(string: linkPortfolio)!)
                                
                                DispatchQueue.global(qos: .background).async {
                                    do
                                        {
                                            let data = try Data.init(contentsOf: URL.init(string: linkPortfolio)!)
                                            self.images.append(UIImage(data: data)!)
                                        }
                                    catch {
                                    }
                                }
                            }
                            
                            if self.portfolioItemViewArray.count == 0 {
                                self.portfolioCollections.isHidden = true
                                self.portfolioLabelHidden.isHidden = true
                                self.portfolioCollecttionUIView.isHidden = true
                            }
                            self.portfolioCollections.reloadData()
                        }
                        else {
                            self.profession.text = NSLocalizedString("ProfileViewPro.Label.ProfessionNotDefined", comment: "")
                        }
                        self.emailUser = safeData.userInfo.email
                        self.webSiteUser = safeData.userInfo.webSite ?? ""
                    }
                }
            }
        }
    }
    @IBAction func leapping(_ sender: Any) {
        if _id == KeychainWrapper.standard.string(forKey: "_id")! || _id == "" {
            self.view.makeToast(NSLocalizedString("ProfileViewPro.Label.LeappYourself", comment: ""), duration: 2.0, position: .top)
        }
        else {
            leappingApi()
            self.present(self.leappmeDialog, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBOutlet weak var promsTableView: UITableView!
    @objc func openCounter(){
        self.present(self.countV, animated: true, completion: nil)
    }
    var sU:BusinessCardViewController!
    
    @IBOutlet weak var addToContactsButton: UIButton!
    @IBAction func addToContacts(_ sender: Any) {
        let newContact = CNMutableContact()
        newContact.givenName = fullname.text ?? NSLocalizedString("Leapper.LeapperUser", comment: "")
        newContact.phoneNumbers = [CNLabeledValue(
                                    label:CNLabelPhoneNumberiPhone,
                                    value:CNPhoneNumber(stringValue:phoneNumber))]
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            try AppDelegate.getAppDelegate().contactStore.execute(saveRequest)
        } catch {
            AppDelegate.getAppDelegate().showMessage(NSLocalizedString("ProfileViewPro.Action.SaveContact", comment: ""))
        }
        addToContactsButton.text(NSLocalizedString("ProfileViewPro.Action.AddedContact", comment: ""))
        addToContactsButton.isUserInteractionEnabled = false
    }
    @IBAction func seeAll(_ sender: Any) {
        sU.fullNameText = fullname.text!
        sU._id = _id
        if mutualsItemarray.count > 0 || nonMutualsItemArray.count > 0 {
            self.present(sU, animated: true,completion: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !ProfileViewPro.isAnimationGoes {
            let pulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 100, postion: CGPoint(x:self.view.center.x, y:lbutton.center.y))
            
            pulse.animationDuration = 1.0
            pulse.backgroundColor = #colorLiteral(red: 0.8993218541, green: 0.1372507513, blue: 0.2670814395, alpha: 1)
            pulse.setupAnimationGroup()
            self.contentView.layer.insertSublayer(pulse, below: self.contentView.layer)
            ProfileViewPro.isAnimationGoes = true
            
        }
        
    }
    
    func leappingApi() {
        
        let _idSender = KeychainWrapper.standard.string(forKey: "_id")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: [String:Any] = [
            "senderId": "\(_idSender)", "getterId": "\(_id)",
            "leads": [
            ]
        ]
        
        self.leappmeDialog._id = _id
        self.leappmeDialog._idSender = _idSender
        self.leappmeDialog.fullname = fullname.text ?? NSLocalizedString("Leapper.LeapperUser", comment: "")
        
        AF.request("https://api.leapper.com/api/mobi/giveLeapp", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            let json = resp.data
            _ = String(data: json!, encoding: .utf8)
            do {
                let jsonObject = try JSON(data: json!)
            }
            catch {
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProfileViewPro.isAnimationGoes = false
        
    }
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    
    func setOnClicks(){
        self.phone.isUserInteractionEnabled = true
        let p = UITapGestureRecognizer(target: self, action: #selector(phoneCall))
        self.phone.addGestureRecognizer(p)
        self.chat.isUserInteractionEnabled = true
        let c = UITapGestureRecognizer(target: self, action: #selector(chatOpen))
        self.chat.addGestureRecognizer(c)
        self.email.isUserInteractionEnabled = true
        let e = UITapGestureRecognizer(target: self, action: #selector(emailSend))
        self.email.addGestureRecognizer(e)
        self.adress.isUserInteractionEnabled = true
        let ad = UITapGestureRecognizer(target: self, action: #selector(locate))
        self.adress.addGestureRecognizer(ad)
        self.navigate.isUserInteractionEnabled = true
        let n = UITapGestureRecognizer(target: self, action: #selector(navigateTo))
        self.navigate.addGestureRecognizer(n)
        self.website.isUserInteractionEnabled = true
        let w = UITapGestureRecognizer(target: self, action: #selector(openWebsite))
        self.website.addGestureRecognizer(w)
    }
    @objc func phoneCall(){
        if let url = URL(string: "tel://\(phoneNumber)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @objc func chatOpen(){
        chat.isUserInteractionEnabled = false
        
        if _id != KeychainWrapper.standard.string(forKey: "_id") {
            getAllChatRoomsById()
        }
        else {
            let alertController = UIAlertController(title: "Unavailable", message: "You can not text yourself", preferredStyle: UIAlertController.Style.alert)
            let purchaseAction2 = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel){_ in
            }
            alertController.addAction(purchaseAction2)
            present(alertController, animated: true, completion: nil)
        }
    }
    var emailUser = ""
    @objc func emailSend(){
        if let url = URL(string: "mailto:\(emailUser)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @objc func locate(){
        openMapForPlace()
    }
    @objc func navigateTo(){
        openMapAsRoute()
    }
    var webSiteUser = ""
    @objc func openWebsite(){
        guard let url = URL(string: webSiteUser) else { return }
        UIApplication.shared.open(url)
    }
    
    func openMapForPlace() {
        
        let latitude:CLLocationDegrees =  lat
        let longitude:CLLocationDegrees =  long

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(NAME)"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func openMapAsRoute() {
        let coordinate = CLLocationCoordinate2DMake(lat,long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = "\(NAME)"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func getMutualsApi() {
        
        /*
         method to send GET request to server and receive JSON with mutuals users
         */
        
        var url = URLComponents(string: "https://api.leapper.com/api/mobi/getMutuals/")! //change the url
        let session = URLSession.shared
        url.queryItems = [URLQueryItem(name: "nextId", value: _id)]
        var request = URLRequest(url: url.url!)
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
                    if let safeData = data {
                        let jsonMutualsData = JSON(safeData)["idList"]["mutuals"]
                        for i in 0..<jsonMutualsData.count {
                            self.mutualsItemarray.append(ServiceUsersModel(userRole: jsonMutualsData[i]["role"].string.map{ UsersType(rawValue: $0)!},  _id: jsonMutualsData[i]["_id"].string, avatarLink: jsonMutualsData[i]["avatar"].string ))
                        }
                        
                        DispatchQueue.main.async {
                            if self.mutualsItemarray.count > 0 {
                                self.noMutualsLabel.isHidden = true
                            }
                            self.MutualsCollectionView.reloadData()
                        }
                        
                        let jsonNonMutualsData = JSON(safeData)["idList"]["others"]
                        for i in 0..<jsonNonMutualsData.count {
                            self.nonMutualsItemArray.append(ServiceUsersModel(userRole: jsonNonMutualsData[i]["role"].string.map{ UsersType(rawValue: $0)!},  _id: jsonNonMutualsData[i]["_id"].string, avatarLink: jsonNonMutualsData[i]["avatar"].string ))
                        }
                        
                        DispatchQueue.main.async {
                            if self.nonMutualsItemArray.count > 0 {
                                self.noNonmutualsLabel.isHidden = true
                            }
                            self.nonMutualsConnectionView.reloadData()
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getMutualsApi()
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
                        DispatchQueue.main.async {
                            
                            
                            let recommendedString = NSLocalizedString("ProfileViewPro.Text.LeadQualificationText", comment: "Lead Qualification Text")
                            let finalString = String.localizedStringWithFormat(recommendedString, JSON(data!)["leadQuality"]["gender"].string ?? "man","\(JSON(data!)["leadQuality"]["ageMin"].int ?? 0)", "\(JSON(data!)["leadQuality"]["ageMax"].int ?? 100)")
                            self.leadqualification.text = finalString
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.leadsQualificationLabel.isHidden = true
                            self.leadsQualificationUIView.isHidden = true
                            self.leadqualification.isHidden = true
                        }
                    }
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
    func getPromotionApi() {
        
        /*
         method to send GET request to server and receive JSON with mutuals users
         */
        
        let promotionsApiURL = "https://api.leapper.com/api/mobi/getPromo/\(_id)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        AF.request(promotionsApiURL, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { dataResponse in
            
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                if let jsonPromotionsData = JSON(data)["promo"]["promotions"].array {
                    for item in jsonPromotionsData {
                        self.promotionItemsList.append(PromotionModel(_id: item["_id"].string!, name: item["title"].string, amount: item["discount"].string!, description: item["description"].string, imageUrl: item["imageUrl"].string, senderId: ""))
                    }
                    DispatchQueue.main.async {
                        
                        if self.promotionItemsList.count > 0 {
                            self.promotionsNotCreatedLabel.isHidden = true
                        }
                        self.promsTableView.reloadData()
                    }
                    
                }
                
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getSetProfileViewProApi()
                break
            default:
                break
            }
        }
    }
    
    func getAllChatRoomsById() {
        let _idMy = KeychainWrapper.standard.string(forKey: "_id")!
        
        let allChatRoomsURL = "https://api.leapper.com/chats/getRooms/\(_idMy)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        AF.request(allChatRoomsURL, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { dataResponse in
            
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                let decodedData = JSON(data)["rooms"].array ?? []
                for i in 0..<decodedData.count {
                    let participants = decodedData[i]["participants"].array ?? []
                    if participants.count == 0 && _idMy == self._id {
                        let chatId = decodedData[i]["_id"].string
                        DispatchQueue.main.async {
                            if let existingChatId = chatId{
                                self.messenger.isChatExist = true
                                self.messenger.chatRoomId = existingChatId
                                self.present(self.messenger, animated: true, completion: nil)
                            }
                        }
                        return
                    }
                    for participant in 0..<participants.count {
                        if participants[participant]["userId"].string ?? "" == (self._id) {
                            let chatId = decodedData[i]["_id"].string
                            DispatchQueue.main.async {
                                if let existingChatId = chatId{
                                    self.messenger.isChatExist = true
                                    self.messenger.chatRoomId = existingChatId
                                    self.present(self.messenger, animated: true, completion: nil)
                                }
                            }
                            return
                        }
                        
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.messenger.isChatExist = false
                    self.present(self.messenger, animated: true, completion: nil)
                }
                
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: self)
                self.getAllChatRoomsById()
                break
            default:
                break
            }
            self.chat.isUserInteractionEnabled = true
        }
    }
}


// MARK: Delegates for Mutuals and NonMutuals Collection Views
extension ProfileViewPro: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == portfolioCollections{
            return portfolioItemViewArray.count
        }else if collectionView == MutualsCollectionView{
            return mutualsItemarray.count
        }else {
            return nonMutualsItemArray.count
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == portfolioCollections{
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "port", for: indexPath) as? PortfolioCollections{
                
                itemCell.parent = self
                itemCell.link = portfolioItemViewArray[indexPath.row]
                itemCell.photos.setupImageViewer(urls: linksToPhotos, initialIndex: indexPath.item, from: self)
                
                return itemCell
            }
            return UICollectionViewCell()
        }else if collectionView == MutualsCollectionView{
            if let itemCe = collectionView.dequeueReusableCell(withReuseIdentifier: "Mutuals", for: indexPath)as? ServiceUsersCollections{
                itemCe.users = mutualsItemarray[indexPath.row]
                return itemCe
            }
            return UICollectionViewCell()
        }else{
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotMutuals", for: indexPath)as? ServiceUsersCollections{
                itemCell.users = nonMutualsItemArray[indexPath.row]
                
                return itemCell
            }
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == MutualsCollectionView || collectionView==nonMutualsConnectionView {
            var su: ServiceUsersModel!
            if collectionView == MutualsCollectionView {
                su = mutualsItemarray[indexPath.row]
            }
            else {
                su = nonMutualsItemArray[indexPath.row]
            }
            switch su.userRole {
            case .client:
                let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
                pvc!._id = su._id!
                self.present(pvc!, animated: true, completion: nil)
                break
            case .professional:
                let pvp = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
                pvp?._id = su._id!
                self.present(pvp!, animated: true, completion: nil)
                break
            default:
                break
            }
            collectionView.reloadData()
        }
    }
}

//MARK: PromotionsList
extension ProfileViewPro: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countPromotions = promotionItemsList.count
        if countPromotions == 0 {
            constraintBottom.constant = aboutme.layer.frame.height + leadqualification.layer.frame.height +  CGFloat(-400)
        }
        else {
            constraintBottom.constant = CGFloat(-400) + CGFloat(205*countPromotions) + aboutme.layer.frame.height + leadqualification.layer.frame.height
        }
        
        return countPromotions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "Proms", for: indexPath) as? PromotionsTableView{
            itemCell.parent = self
            itemCell.phone = phoneNumber
            itemCell.userName = fullname.text!
            itemCell.userId = _id
            itemCell.promotions = promotionItemsList[indexPath.row]
            return itemCell
        }
        return UITableViewCell()
    }
    
    
}

extension ProfileViewPro: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(link)
        }
    }
}

