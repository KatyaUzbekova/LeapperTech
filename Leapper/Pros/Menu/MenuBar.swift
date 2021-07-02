//
//  MenuBar.swift
//  Leapper
//
//  Created by Kratos on 8/28/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import Kingfisher

class MenuBar: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var openHelperView: UIStackView!
    @IBOutlet weak var becomeProButton: UIButton!
    /**
     send message to email adrress of developers
     */
    @IBAction func helpMeButtonAction(_ sender: Any) {
        let recipientEmail = "leappertech@gmail.com"
        let subject = "\(NSLocalizedString("MenuBar.Text.MessageTitle", comment: ""))"
        let body = "\(NSLocalizedString("MenuBar.Text.MessageBody", comment: ""))"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody("<h4>body<h4>", isHTML: true)
            present(mail, animated: true)
        }
        else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
        else {
            let alertController = UIAlertController(title: NSLocalizedString("MenuBar.Text.ErrorEmail1", comment: ""), message: NSLocalizedString("MenuBar.Text.ErrorEmail2", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let dismissAction = UIAlertAction(title: NSLocalizedString("MenuBar.Text.OK", comment: ""), style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        else {
        }
        
        return defaultUrl
    }
    
    
    @IBOutlet weak var helpMeButton: UIButton!
    @IBOutlet weak var leappsIcon: UIImageView!
    @IBOutlet weak var commCount: UILabel!
    @IBOutlet weak var leappCount: UILabel!
    @IBOutlet weak var thanxCount: UILabel!
    @IBOutlet weak var fullname: UILabel!
    /*
     sharing - use standart share
     */
    @IBAction func share(_ sender: Any) {
        let items: [Any] = [NSLocalizedString("MenuBar.Text.ShareText", comment: ""), URL(string: "https://www.leapper.com/")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    
    @IBAction func settings(_ sender: Any) {
        let st = self.storyboard?.instantiateViewController(withIdentifier: "navSettings") as? UINavigationController
        self.present(st!, animated: true) {
        }
        
        
    }
    
    /**
     api request
     took acces token and return user info
     */
    func getSetUserBaseInfoApi() {
        /*
         method to send GET request to server and receive JSON with user information
         */
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let url = URLComponents(string: "https://api.leapper.com/api/mobi/getUser")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10000.0)
        
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.view.makeToast(error?.localizedDescription, duration: 3, position: .bottom)
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                    
                    if let safeData = data {
                        let jsonData = JSON(safeData)
                        
                        setNewImage(linkToPhoto: jsonData["userInfo"]["avatar"].string, imageInput: self.avatar, isRounded: true)
                        
                        DispatchQueue.main.async {
                            
                            self.thanxCount.text = "\(jsonData["thanksCount"])"
                            self.commCount.text = "\(jsonData["communityCount"])"
                            self.leappCount.text = "\(jsonData["leappCount"])"
                            
                            self.fullname.text = "\(jsonData["userInfo"]["name"].string ?? "") \(jsonData["userInfo"]["lastName"].string ?? "")"
                            UserDefaults.standard.setValue(self.fullname.text ?? "", forKey: "userName")
                            
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getSetUserBaseInfoApi()
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
    override func viewWillAppear(_ animated: Bool) {
        getSetUserBaseInfoApi()
    }
    @objc func openHelperViewFunc(_ sender: UITapGestureRecognizer? = nil) {
        let countV = self.storyboard?.instantiateViewController(withIdentifier: "Counters") as? InfoViewController
        self.present(countV!, animated: true, completion: nil)
}
    override func viewDidLoad() {
        super .viewDidLoad()
        //   getSetUserBaseInfoApi()
        
        
        //check if name is already in userDefaults before api request happened
        if let name = UserDefaults.standard.string(forKey: "userName") {
            self.fullname.text = name
        }
        
        if let photo = UserDefaults.standard.string(forKey: "userPhotoURL") {
            setNewImage(linkToPhoto: photo, imageInput: avatar, isRounded: true)            
        }
        
        //open informationController
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openHelperViewFunc(_:)))
        openHelperView.addGestureRecognizer(tap2)
        
        
        //hide some components if it is client
        if !SessionManager.shared.isPro() {
            leappCount.isHidden = true
            leappsIcon.isHidden = true
            becomeProButton.text(NSLocalizedString("MenuBar.Button.BecomePro", comment: ""))
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openBecomePro(_:)))
            becomeProButton.addGestureRecognizer(tap)
            
        }
        else {
            becomeProButton.text(NSLocalizedString("MenuBar.Button.Subscription", comment: ""))
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openSubscriptions(_:)))
            becomeProButton.addGestureRecognizer(tap)
        }
    }
    
    //MARK: Not realized yet
    @objc func openSubscriptions(_ sender: UITapGestureRecognizer? = nil) {
        
        let alertController = UIAlertController(title: NSLocalizedString("MenuBar.Button.Unavailable", comment: ""), message: NSLocalizedString("MenuBar.Button.PremiumAccount", comment: ""), preferredStyle: UIAlertController.Style.alert)
        let purchaseAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default){_ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(purchaseAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: become pro button for a client version
    @objc func openBecomePro(_ sender: UITapGestureRecognizer? = nil) {
        print("No functional yet")
    }
    
}
