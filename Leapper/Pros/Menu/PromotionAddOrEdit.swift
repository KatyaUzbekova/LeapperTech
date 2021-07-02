//
//  PromotionAddOrEdit.swift
//  Leapper
//
//  Created by Kratos on 9/9/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import YPImagePicker

class PromotionAddOrEdit: UIViewController, UITextViewDelegate {
    @IBOutlet weak var nameofaction: UITextView!
    @IBOutlet weak var icon: UIImageView!
    
    weak var parentView: Promotions!
    @IBAction func uploadIcon(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                createUserDir(phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!, self)
                if let image = photo.modifiedImage {
                    self.uploadImage(image: image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                }
                else {
                    self.uploadImage(image: photo.image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var desc: UITextView!
    
    @IBAction func saveProm(_ sender: Any) {
        
        if !isEdit {
            addPromotion()
            dismiss(animated: true, completion: nil)
        }
        else {
            editPromotion()
        }
    }
    
    @IBOutlet weak var amount: UITextView!
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var isEdit = false
    var promKey:String?
    var profKey:String?
    
    func editPromotion() {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: [String:Any] = [
            "imageUrl": self.imageUrl,
            "title": self.nameofaction.text!,
            "description": self.desc.text!,
            "discount": self.amount.text!
        ]
        
        if self.nameofaction.text! != "" && self.desc.text! != "" && self.amount.text != "" {
            
            AF.request("https://api.leapper.com/api/mobi/patchPromo/\(idPromo)", method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                
                if let err = resp.error{
                    print(err)
                    return
                }
                let json = resp.data
                do {
                    let jsonObject = try JSON(data: json!)
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
                    
                }
                catch {
                }
                
            }
        }
    }
    
    @IBOutlet weak var uploadImageOutlet: UIButton!
    var idPromo = ""
    
    func uploadImage(image: UIImage, phone username: String) {
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image.jpegData(compressionQuality: 0.2)!, withName: "file" , fileName: "\(image).jpeg", mimeType: "image/jpeg")
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
                        self.imageUrl = jsonObject["hashedFilePathes"][0].stringValue
                        DispatchQueue.main.async {
                            self.uploadImageOutlet.text(NSLocalizedString("PromotionAddOrEdit.Action.ChangeSelection", comment: ""))
                            setNewImage(linkToPhoto: self.imageUrl, imageInput: self.icon, isRounded: false)
                        }
                        
                    }
                    catch {
                    }
                }
            }
        
    }
    var imageUrl = ""
    var nameOfActionValue = ""
    var discountValue = ""
    var descValue = ""
    
    func addPromotion() {
        
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        if self.nameofaction.text! != "" && self.desc.text! != "" && self.amount.text != "" {
            
            let parameters: [String:Any] = [
                "imageUrl": self.imageUrl,
                "title": self.nameofaction.text!,
                "description": self.desc.text!,
                "discount": self.amount.text!
            ]
            AF.request("https://api.leapper.com/api/mobi/postPromo", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                
                if let err = resp.error{
                    print(err)
                    return
                }
                let json = resp.data
                do {
                    let jsonObject = try JSON(data: json!)
                    NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                catch {
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.amount.delegate = self
        self.desc.delegate = self
        self.nameofaction.delegate = self
        
        amount!.layer.borderWidth = 1
        amount!.layer.cornerRadius = 17
        desc!.layer.borderWidth = 1
        desc!.layer.cornerRadius = 17
        nameofaction!.layer.borderWidth = 1
        nameofaction!.layer.cornerRadius = 17
        
        if isEdit {
            desc.text = descValue
            nameofaction.text = nameOfActionValue
            amount.text = discountValue
            self.icon.sd_setImage(with: URL(string:self.imageUrl), completed: nil)
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach {(constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height + 5 < 100 {
                    constraint.constant = estimatedSize.height + 5
                }
            }
        }
        
        
    }
}
