//
//  PortfolioReg.swift
//  Leapper
//
//  Created by Kratos on 8/29/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import EasyPeasy
import BSImagePicker
import Photos
import PhotosUI

class PortfolioReg: UIViewController, UITextFieldDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    private var itemProviders = [NSItemProvider]()
    private var itemProvidersIterator: IndexingIterator<[NSItemProvider]>?
    private var currentItemProvider: NSItemProvider?
    var photoCount = 0
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        createUserDir(phone:  KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
        
        self.dismiss(animated: true)
        itemProviders = results.map(\.itemProvider)
        photoCount = itemProviders.count
        for itemProvider in itemProviders {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                itemProvider.loadObject(ofClass: UIImage.self) { [self] image, error in
                    if let image = image as? UIImage {
                        imagesPortfolio.append(image)
                        uploadImage(image: image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                        
                    } else {
                    }
                }
            }
            
            self.youChooseButton.isEnabled = false
            if photoCount != 1 {
                let tempChooseButton = NSLocalizedString("PortfolioReg.choseSomeImages", comment: "you chose images")
                self.youChooseButton.text(String.localizedStringWithFormat(tempChooseButton, "\(photoCount)"))
            }
            else {
                self.youChooseButton.text(NSLocalizedString("PortfolioReg.chose1Image", comment: "you chose 1 image"))
            }
            if photoCount > 0 {
                self.doneView.text(NSLocalizedString("Send", comment: "Send"))
            }
            
            DispatchQueue.main.async {
                self.youChooseButton.backgroundColor = .clear
                self.TableView.reloadData()
                let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    @IBOutlet weak var tableViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var viewResizing: UIView!
    
    @IBOutlet weak var youChooseButton: UIButton!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var editText: UITextView!
    var isPortPhotosSended = false
    @IBAction func done(_ sender: Any) {
        if isFinished {
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
            }
        }
        else {
            if imagesPortfolio.count == 0 {
                self.itemArray.append(MessageModel(messages: NSLocalizedString("PortfolioReg.Label.ThankYouUpdating", comment: "thank you for updating information"), isBot: true, image: nil, imagePathName: "liaImage.png"))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self.TableView.reloadData()
                    let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                    self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    self.finishReg()
                    
                }
            }
            else {
                youChooseButton.isEnabled = false
                createUserDir(phone:  KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
                for one_image in imagesPortfolio {
                    
                    uploadImage(image: one_image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                    let fullString = NSMutableAttributedString(string: "")
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = one_image.resize(maxWidthHeight: 20)
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    fullString.append(image1String)
                    
                    itemArray.append(MessageModel(messages: "", isBot: false, image: one_image))
                    DispatchQueue.main.async {
                        self.TableView.reloadData()
                        let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                        self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                    
                }
                
            }
            youChooseButton.isHidden = true
            
        }
    }
    var checkerFinishUpload = 0
    var isFinished = false
    @IBOutlet weak var doneView: UIButton!
    var position = 0
    
    @IBOutlet weak var messHolder: UIView!
    
    func finishReg() {
        
        let parameters: [String:Any] = [
            "jobName": userDatas["profession"]!,
            "info": userDatas["info"]!,
            "tags": [
            ],
            "photos": imagesPortfolioLinks,
            "attachments": [
            ]
        ]
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        
        AF.request("https://api.leapper.com/api/mobi/portfolio", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            if let err = resp.error{
                print(err)
                return
            }
            
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
                self.finishReg()
            }
            else if resp.response?.statusCode == 200 {
                UserDefaults.standard.set(true, forKey: "isFullyRegistered")
                self.isFinished = true
                self.doneView.text(NSLocalizedString("Finish", comment: ""))
                ProFeeds.firstLoad = false
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                }
            }
            
            
        }
    }
    
    func uploadImage(image: UIImage, phone username: String) {
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image.jpegData(compressionQuality: 0.2)!, withName: "file" , fileName: "\(image).jpeg", mimeType: "image/jpeg")
            },
            to: "https://api.leapper.com/files/api/\(username)/uploadImage", method: .post , headers: headers)
            .response { [self] resp in
                if let err = resp.error{
                    print(err)
                    return
                }
                let json = resp.data
                if (json != nil)
                {
                    do{
                        let jsonObject = try JSON(data: json!)
                        imagesPortfolioLinks.append(jsonObject["hashedFilePathes"][0].stringValue)
                        checkerFinishUpload = checkerFinishUpload + 1
                        if checkerFinishUpload == photoCount {
                            
                            itemArray.append(MessageModel(messages: NSLocalizedString("PortfolioReg.Label.ThankYouUpdating", comment: "thank you for updating information"), isBot: true, image: nil, imagePathName: "liaImage.png"))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                                TableView.reloadData()
                                let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                                TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                                isPortPhotosSended = true
                                doneView.isEnabled = true
                                finishReg()
                            }
                        }
                    }
                    catch {
                        
                    }
                }
            }
        
    }
    
    @IBAction func Send(_ sender: Any) {
        if position == 0{
            //only Profession Name
            if self.editText.text!.count > 0{
                userDatas["profession"] = self.editText.text!
                itemArray.append(MessageModel(messages: editText.text!, isBot: false, image: nil))
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                    self.editText.text = ""
                    let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                    self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                
                runStageTwo(self.editText.text!)
                
            }
        }else if position == 1{
            //OnLy profession info
            if self.editText.text!.count > 0{
                userDatas["info"] = self.editText.text!
                itemArray.append(MessageModel(messages: editText.text!, isBot: false, image: nil))
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                    self.editText.text = ""
                    let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                    self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                
                runStageThree(self.editText.text!)
                
            }
            
        }else {
            //photo
        }
    }
    
    @available(iOS 14, *)
    private func presentPicker(filter: PHPickerFilter) {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = 20
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func chooseImages(_ sender: Any) {
        
        if #available(iOS 14, *) {
            presentPicker(filter: PHPickerFilter.images)
        } else {
            
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = 20
            imagePicker.settings.selection.unselectOnReachingMax = false
            imagePicker.settings.dismiss.allowSwipe = true
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
            self.presentImagePicker(imagePicker, select: { (asset) in
            }, deselect: { (asset) in
            }, cancel: { (assets) in
            }, finish: { (assets) in
                for asset in assets {
                    self.imagesPortfolio.append(getAssetThumbnail(asset: asset))
                }
                if assets.count != 1 {
                    let tempChooseButton = NSLocalizedString("PortfolioReg.choseSomeImages", comment: "you chose images")
                    self.youChooseButton.text(String.localizedStringWithFormat(tempChooseButton, "\(assets.count)"))
                }
                else {
                    self.youChooseButton.text(NSLocalizedString("PortfolioReg.chose1Image", comment: "you chose 1 image"))
                }
                if assets.count > 0 {
                    self.doneView.text(NSLocalizedString("Send", comment: "Send"))
                }
                
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                    let indexPath = IndexPath(row: self.itemArray.count, section: 0)
                    self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                createUserDir(phone:  KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
                for one_image in self.imagesPortfolio {
                    self.uploadImage(image: one_image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                }
            })
            
        }
    }
    var imagesPortfolio = [UIImage]()
    var imagesPortfolioLinks = [String]()
    @IBOutlet weak var TableView: UITableView!
    var itemArray = [MessageModel]()
    var userDatas = [String : Any ]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editText.delegate = self
        self.isFinished = false
        
        checkerFinishUpload = 0
        editText!.layer.borderWidth = 1
        editText!.layer.cornerRadius = 17
        
        TableView.register(ChatMessageCell.self, forCellReuseIdentifier: "id")
        TableView.register(LiaPrototypeTableViewCell.self, forCellReuseIdentifier: "liaCell")
        
        TableView.delegate = self
        TableView.dataSource = self
        
        runStageOne()
    }
    
    func runStageTwo(_ userMess: String!){
        self.position = 1
        self.itemArray.append(MessageModel(messages: NSLocalizedString("botPortThree", comment: ""), isBot: true, image: nil, imagePathName: "liaImage.png"))
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            let indexPath = IndexPath(row: self.itemArray.count, section: 0)
            self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            self.TableView.reloadData()
            
        }
    }
    
    func runStageThree(_ userMess: String!){
        self.position = 99
        
        self.itemArray.append(MessageModel(messages: NSLocalizedString("botPortFour", comment: ""), isBot: true, image: nil, imagePathName: "liaImage.png"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.messHolder.isHidden = true
            self.photoView.isHidden = false
            self.TableView.reloadData()
            let indexPath = IndexPath(row: self.itemArray.count, section: 0)
            self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    func runStageOne(){
        let tempPortfolioReg = NSLocalizedString("botPortOne", comment: "")
        
        self.itemArray.append(MessageModel(messages: String.localizedStringWithFormat(tempPortfolioReg, UserDefaults.standard.string(forKey: "userName")!),isBot: true, image: nil, imagePathName: "liaImage.png"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.TableView.reloadData()
            let indexPath = IndexPath(row: self.itemArray.count, section: 0)
            self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        self.itemArray.append(MessageModel(messages: NSLocalizedString("botPortTwo", comment: ""),isBot: true, image: nil, imagePathName: "liaImage.png" ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.TableView.reloadData()
            let indexPath = IndexPath(row: self.itemArray.count, section: 0)
            self.TableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}
extension PortfolioReg: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "liaCell", for: indexPath) as! LiaPrototypeTableViewCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! ChatMessageCell
            cell.chatMessage = itemArray[indexPath.row-1]
            return cell
            
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: viewResizing.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        viewResizing.constraints.forEach {(constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height + 15 < 100 {
                    constraint.constant = estimatedSize.height + 15
                }
            }
        }
        
        
    }
    
    
}


func getAssetThumbnail(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
        thumbnail = result!
    })
    return thumbnail
}
