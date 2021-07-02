//
//  PortoCollCell.swift
//  Leapper
//
//  Created by Kratos on 9/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import ImageViewer
import BSImagePicker
import Photos
import PhotosUI


class PortoCollCell: UICollectionViewCell {
    
    var imagesPortfolio = [UIImage]()
    
    @IBOutlet weak var content:UIImageView!
    @IBOutlet weak var close:UIButton!
    weak var parent:Portfolio!
    var indexOfPhoto: Int!
    
    @IBAction func closeButton(_ sender: Any) {
        self.parent.portItemsLinksUpload.remove(at: indexOfPhoto-1)
        self.parent.portItemsLinks.remove(at: indexOfPhoto)
        DispatchQueue.main.async {
            self.parent.collections.reloadData()
        }
    }
    
    
    var pem:String?{
        didSet{
            content.isUserInteractionEnabled = true
            let im:UITapGestureRecognizer!
            if pem! == "add"{
                self.close.isHidden = true
                self.content.image = UIImage(named: "add")
                im = UITapGestureRecognizer(target: self, action: #selector(addNew))
                content.addGestureRecognizer(im)

            }else {
                self.close.isHidden = false
                setNewImage(linkToPhoto: pem, imageInput: content, isRounded: false)
            }
            content.layer.cornerRadius = 30
        }
        
    }
    @available(iOS 14, *)
    private func presentPicker(filter: PHPickerFilter) {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = 20
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        parent.present(picker, animated: true)
    }
    @objc func addNew(){
        
        if #available(iOS 14, *) {
            presentPicker(filter: PHPickerFilter.images)
        } else {
            
                    let imagePicker = ImagePickerController()
                    imagePicker.settings.selection.max = 20
                    imagePicker.settings.selection.unselectOnReachingMax = false
                    imagePicker.settings.dismiss.allowSwipe = true
                    imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
                    parent.presentImagePicker(imagePicker, select: { (asset) in
                        print("Selected: \(asset)")
                    }, deselect: { (asset) in
                        print("Deselected: \(asset)")
                    }, cancel: { (assets) in
                        print("Canceled with selections: \(assets)")
                    }, finish: { (assets) in
                        print("Finished with selections: \(assets)")
                        for asset in assets {
                            self.imagesPortfolio.append(getAssetThumbnail(asset: asset))
                        }
            
                        createUserDir(phone:  KeychainWrapper.standard.string(forKey: "phoneNumber")!, self.parent)
                        for one_image in self.imagesPortfolio {
                            self.uploadImage(image: one_image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)
                        }
                    })
            
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
            .response { resp in
                if let err = resp.error{
                    print(err)
                    return
                }
                let json = resp.data
                if (json != nil)
                {
                    do{
                        let jsonObject = try JSON(data: json!)
                        self.parent.portItemsLinksUpload.insert(contentsOf: [jsonObject["hashedFilePathes"][0].stringValue], at: 0)
                        self.parent.portItemsLinks.insert(contentsOf: [jsonObject["hashedFilePathes"][0].stringValue], at: 1)
                        DispatchQueue.main.async {
                            self.parent.collections.reloadData()
                        }
                    }
                    catch {
                        
                    }
                }
            }
        
    }
    
    private var itemProviders = [NSItemProvider]()
    private var itemProvidersIterator: IndexingIterator<[NSItemProvider]>?
    private var currentItemProvider: NSItemProvider?
}


@available(iOS 14, *)
extension PortoCollCell: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        createUserDir(phone:  KeychainWrapper.standard.string(forKey: "phoneNumber")!, self.parent)

        parent.dismiss(animated: true)
        itemProviders = results.map(\.itemProvider)
        for itemProvider in itemProviders {
        if itemProvider.canLoadObject(ofClass: UIImage.self) {

            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        self!.uploadImage(image: image, phone: KeychainWrapper.standard.string(forKey: "phoneNumber")!)

                    } else {
            }
            }
            }
    }
    }
    
}
