//
//  LeapperDialog.swift
//  Leapper
//
//  Created by Kratos on 2/21/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import EFQRCode
import AVFoundation
import ContactsUI
import PhoneNumberKit
import SwiftKeychainWrapper
import Toast_Swift
import QRCodeReader

class QrReaderController: UIViewController, FPNTextFieldDelegate,QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        if cameraName == newCaptureDevice.device.localizedName {
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
        
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.25, width: 0.6, height: 0.4)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
            
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
            
    }
    
    func fpnDisplayCountryList() {
            
    }
    
    @IBAction func inviteWhatsApp(_ sender: Any) {
        let fpnPhone = phoneInputField.text!
        if phoneInputField.isValidNumber {
            self.whatsAppInvite(fpnPhone)
        }else{
            self.view.makeToast(NSLocalizedString("Toast.Message.InvalidPhoneError", comment: "Invalid Phone Error"), duration: 2.0, position: .center)
        }
    }
    @IBAction func inviteSMS(_ sender: Any) {
        let fpnPhone = phoneInputField.text!
        if phoneInputField.isValidNumber {
                self.sendSMS(fpnPhone)
               }else{
                self.view.makeToast(NSLocalizedString("Toast.Message.InvalidPhoneError", comment: "Invalid Phone Error"), duration: 2.0, position: .center)
               }
    }
    
    func generateURLShare(_ phone:String?)->String{
        return "https://leapper.com/a/pro/\(KeychainWrapper.standard.string(forKey: "_id")!)"

    }
    
    @IBAction func typicalShare(_ sender: Any) {
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, generateDeepLink(""))
        let items: [Any] = [textString]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func shareFB(_ sender: Any) {
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, generateDeepLink(""))
        let items: [Any] = [textString]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)

        
//        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
//        let textString = String.localizedStringWithFormat(recommendedString, "")
//        var components = URLComponents(string: "https://www.facebook.com/sharer/sharer.php")!
//        components.queryItems = [
//            URLQueryItem(name: "u", value: "\(Leapper.generateURLShare(id: KeychainWrapper.standard.string(forKey: "_id")!))"),
//            URLQueryItem(name: "quote", value: textString)
//        ]
//        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        let url = components.url!
//        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    @objc
    func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        contactPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
        contactPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'")
        contactPicker.modalPresentationStyle = .fullScreen
        self.present(contactPicker, animated: true, completion: nil)
    }

    @IBOutlet weak var contactPicker: UIButton! {
        didSet {
            contactPicker.addTarget(self, action: #selector(openContactPicker), for: .touchUpInside)
        }
    }
    @IBAction func shareTW(_ sender: Any) {
        let fpnPhone = KeychainWrapper.standard.string(forKey: "phoneNumber")!
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, generateDeepLink(fpnPhone)).replacingOccurrences(of: "\n", with: "%0A")
        let tempLink = "https://twitter.com/intent/tweet?text=\(textString)".replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: " ", with: "%20")
        let linkURL = NSURL(string: tempLink)
        if UIApplication.shared.canOpenURL(linkURL! as URL) {
            UIApplication.shared.open(linkURL! as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(NSURL(string: tempLink)! as URL, options: [:], completionHandler: nil)                       }
    }
    
    @IBAction func scanQR(_ sender: Any) {
        readerVC.delegate = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            let res = result!
            let value = res.value
            
            let allowedCharset = CharacterSet.urlPathAllowed

            let filteredText = String(value.unicodeScalars.filter(allowedCharset.contains))
            let _idAdded = filteredText.components(separatedBy: "/").last!

            let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as! ProfileViewPro
            pvc._id = _idAdded
            self.dismiss(animated: true, completion: nil)
            self.present(pvc, animated: true, completion: nil)

        }

        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
        
    }
    
    @IBAction func shareLN(_ sender: Any) {
        let fpnPhone = KeychainWrapper.standard.string(forKey: "phoneNumber")!
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, "").replacingOccurrences(of: "\n", with: "%0A")
        let link = "https://www.linkedin.com/shareArticle?mini=true&url=\(generateDeepLink(fpnPhone).replacingOccurrences(of: "+", with: "%2B"))&title=Leapper%20App&summary=\(textString)".replacingOccurrences(of: " ", with: "%20")
        let linkURL = NSURL(string: link)
                   if UIApplication.shared.canOpenURL(linkURL! as URL) {
                    UIApplication.shared.open(linkURL! as URL, options: [:], completionHandler: nil)                       } else {
                    UIApplication.shared.open(NSURL(string: link)! as URL, options: [:], completionHandler: nil)
                    }
    }
   
    @IBOutlet weak var phoneInputField: PhoneNumberTextField!
    let phoneNumberKit = PhoneNumberKit()

    @IBOutlet weak var qrCode: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            self.generateQR()
        }
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    func generateQR(){
        if let qrImage = EFQRCode.generate(
            content:  "https://leapper.com/a/pro/\(KeychainWrapper.standard.string(forKey: "_id")!)"
        ) {
            DispatchQueue.main.async {
                self.qrCode.image = UIImage.init(cgImage: qrImage)
            }
        } else {
        }
    }
    
    func whatsAppInvite(_ phone:String?){
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, generateDeepLink(""))
        let leappT = "https://api.whatsapp.com/send?phone=\(phone!.replacingOccurrences(of: "+", with: ""))&text=\(textString)"
        let strURL: String = leappT.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
    
    
    func sendSMS(_ phone:String?){
        let recommendedString = NSLocalizedString("QrReaderController.Action.SharingText", comment: "Typical share text")
        let textString = String.localizedStringWithFormat(recommendedString, generateDeepLink(""))
        let sms: String = "sms:\(phone!)&body=\(textString)"
      let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
    
    
    func generateDeepLink(_ phone:String)->String{
        return "https://leapper.com/a/pro/\(KeychainWrapper.standard.string(forKey: "_id")!)"

    }
}
extension QrReaderController: CNContactPickerDelegate {

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        if let phoneNumber = contactProperty.contact.phoneNumbers.first?.value.stringValue {
            phoneInputField.text = phoneNumber
        }
    }
}
