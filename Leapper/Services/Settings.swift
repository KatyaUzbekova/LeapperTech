//
//  Settings.swift
//  Leapper
//
//  Created by Kratos on 9/14/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import UIKit

class Settings: UIViewController {

    @IBOutlet weak var hebrewToEnglish: UIButton!
    
    @IBAction func logOut(_ sender: Any) {
        SessionManager.shared.logOutUser(self)
    }
    
    @IBAction func changeLanguage2(_ sender: Any) {
        let alertController = UIAlertController(title: "Coming Soon", message: "This feature will coming soon", preferredStyle: UIAlertController.Style.alert)
        let purchaseAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default){_ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(purchaseAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func openSubscriptions() {
        let alertController = UIAlertController(title: "Unavailable", message: "You already have premium account", preferredStyle: UIAlertController.Style.alert)
        let purchaseAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default){_ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(purchaseAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteProfile(_ sender: Any) {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let alertController = UIAlertController(title: NSLocalizedString("Settings.Action.Title.DeleteAccount", comment: "Delete Account"), message: NSLocalizedString("Settings.Action.Body.DeleteAccount", comment: "Delete Account, are you sure?"), preferredStyle: UIAlertController.Style.alert)
        
        
        let yesAction  = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertAction.Style.default){ _ in
            if ReachabilityTest.isConnectedToNetwork() {

            AF.request("https://api.leapper.com/api/mobi/deleteUser", method: .delete, parameters: nil, headers: headers).responseJSON { AFdata in
                do {
                    guard let jsonObject = try JSONSerialization.jsonObject(with: AFdata.data!) as? [String: Any] else {
                        return
                    }
                    guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                        return
                    }
                    guard String(data: prettyJsonData, encoding: .utf8) != nil else {
                        return
                    }
                    postToUnregister() {
                    }
                    
                    KeychainWrapper.standard.removeObject(forKey: "PhoneNumber")
                    UserDefaults.standard.removeObject(forKey: "isPro")
                    UserDefaults.standard.removeObject(forKey: "userName")
                    UserDefaults.standard.removeObject(forKey: "userPhotoURL")
                    UserDefaults.standard.removeObject(forKey: "isFullyRegistered")
                    
                    UserDefaults.standard.set(false, forKey: "isLogged")
                    KeychainWrapper.standard.removeObject(forKey: "_id")
                      
                    AppDelegate.socket.disconnect()


                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                      let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = vc
                } catch {
                    print("Error: Trying to convert JSON data to string")
                    return
                }
            }
            }
        }
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: UIAlertAction.Style.default)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        present(alertController, animated: true, completion: nil)
        
        

    }
    
    @IBAction func changeLanguage(_ sender: UIButton) {

        if preferredLanguage == "he" {
            hebrewToEnglish.text(NSLocalizedString("Settings.Action.Body.ChangeLanguageToEnglish", comment: "Change to English"))
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        else {
            hebrewToEnglish.text(NSLocalizedString("Settings.Action.Body.ChangeLanguageToHebrew", comment: "Change to Hebrew"))
            UserDefaults.standard.set(["he"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Settings.Action.Title.Restarting", comment: "Restarting"), message: NSLocalizedString("Settings.Action.Body.Restarting", comment: "Restarting body"), preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default))
        present(alertController, animated: true, completion: nil)
    }
    let preferredLanguage = NSLocale.preferredLanguages[0]

    override func viewDidLoad() {
        super.viewDidLoad()

        if !SessionManager.shared.isPro() {
            self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 106/256, green: 27/256, blue: 154/256, alpha: 1)
        }
        
        if preferredLanguage == "he" {
            hebrewToEnglish.text(NSLocalizedString("Settings.Action.Body.ChangeLanguageToEnglish", comment: "Change to English"))
        }
        else {
            hebrewToEnglish.text(NSLocalizedString("Settings.Action.Body.ChangeLanguageToHebrew", comment: "Change to Hebrew"))

        }
    }
    
}
