//
//  LoginViewController.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//
import UIKit
import FlagPhoneNumber
import Toast_Swift
import SwiftKeychainWrapper
import PhoneNumberKit


class LoginViewController:  UIViewController, UITextFieldDelegate {
    
    var phoneNumber = ""
    let decoder = JSONDecoder()
    var seconds = 60
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        let maxLength = 6
        let symbolWidth = CGFloat(43)
        let font = UIFont.systemFont(ofSize: 30)
        
        if string == "" { // when user remove text
            textField.text = ""
            return false
        }
            
        if textField.text!.count + string.count - range.length > maxLength { // when user type extra text
            return false
        }
        
        let currentText = NSMutableAttributedString(attributedString: textField.attributedText ?? NSMutableAttributedString())
        currentText.deleteCharacters(in: range) // delete selected text
        var newStringLength = 0
        for char in string{
            let newSymbol = NSMutableAttributedString(string: String(char))
            newSymbol.addAttribute(.font, value: font, range: NSMakeRange(0, 1))
            let currentSymbolWidth = newSymbol.size().width
            let kern = symbolWidth - currentSymbolWidth
            if currentText.length < 5 {
                newSymbol.addAttribute(.kern, value: kern, range: NSMakeRange(0,1))
            }
            currentText.insert(newSymbol, at: range.location + newStringLength)
            newStringLength += 1
        }
        textField.attributedText = currentText
        return false
    }

    static var numberCount = 0
    @IBAction func listenPhoneUpdates(_ sender: Any) {
        if phoneInputTextField.text?.count == 1 &&  LoginViewController.numberCount >= 1 {
            DispatchQueue.main.async {
                self.phoneInputTextField.text = ""
            }
        }
        LoginViewController.numberCount = phoneInputTextField.text?.count ?? 0
        if phoneInputTextField.text?.count == 1 {
            if phoneInputTextField.text! != "+" {
                DispatchQueue.main.async {
                    self.phoneInputTextField.text = "+" + self.phoneInputTextField.text!
                }
            }
        }
    }
    
    @objc func updateTimer() {

        if seconds == 0 {
            DispatchQueue.main.async {
                self.timerLabel.isHidden = true
                self.resendTextLabel.isHidden = true
                self.resendButton.isHidden = false
            }

        }
        else {
            seconds -= 1     //This will decrement(count down)the seconds.
            DispatchQueue.main.async {
                self.timerLabel.text = "\(self.seconds)" //This will update the label.
            }
        }
    }
    @IBOutlet weak var PhoneInputLayout: UIStackView!
    @IBOutlet weak var smsCodeLayout: UIStackView!
    @IBOutlet weak var phoneInputTextField: PhoneNumberTextField!
    @IBOutlet weak var phoneHinter: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var smsCodeInput: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendTextLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBAction func sendPhoneNumber(_ sender: Any) {
        nextButton.isEnabled = false
        if let tempPhoneNumber = phoneInputTextField.phoneNumber?.numberString {
            phoneNumber = phoneInputTextField.phoneNumber!.numberString
            if phoneInputTextField.isValidNumber {
                sendPhoneNumberToServer(tempPhoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""))
            }else{
                self.view.makeToast(NSLocalizedString("Toast.Message.InvalidPhoneError", comment: ""), duration: 2.0, position: .top)
                nextButton.isEnabled = true
            }
            
        }
        else {
            self.view.makeToast(NSLocalizedString("Toast.Message.InvalidPhoneError", comment: ""), duration: 2.0, position: .top)
            nextButton.isEnabled = true
        }

    }
    
    @IBAction func resendCode(_ sender: Any) {
        sendPhoneNumberToServer(phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""))
        smsCodeInput.text = ""
        resendButton.isEnabled = false
    }
    
   
    @IBAction func signInButtonClicked(_ sender: Any) {
        self.view.endEditing(true);
        
        if smsCodeInput.text!.count == 6 {
            signIn("\(smsCodeInput.text!)")
        }else{
        }
    }
    
    var timer: Timer!
    @objc func changeMyNumber() {
        self.PhoneInputLayout.isHidden = false
        self.smsCodeLayout.isHidden = true
        self.phoneInputTextField.becomeFirstResponder()
        nextButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seconds = 60

        smsCodeLayout.isHidden = true
        smsCodeInput.delegate = self
        PhoneInputLayout.isHidden = false
        
        phoneHinter.isUserInteractionEnabled = true
        let e = UITapGestureRecognizer(target: self, action: #selector(changeMyNumber))
        self.phoneHinter.addGestureRecognizer(e)
        
    }
    func sendPhoneNumberToServer(_ phone:String){

        let parameters = ["phone": phone]
        let url = URL(string: "https://api.leapper.com/api/auth/login/mobi/getSms")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
        DispatchQueue.main.async {
                    Toast(error.localizedDescription).show(self)
                    }
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    Toast(error!.localizedDescription).show(self)
                    }
                return
            }
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 201{
                        DispatchQueue.main.async { [self] in
                            PhoneInputLayout.isHidden = true
                            seconds = 60

                            smsCodeLayout.isHidden = false
                            smsCodeInput.becomeFirstResponder()
                            phoneHinter.text = self.phoneNumber
                            resendButton.isHidden = true
                            if timer != nil {
                                timer.invalidate()
                            }
                            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(LoginViewController.updateTimer)), userInfo: nil, repeats: true)
                        }

                     return
                    }
                    else  {
                        DispatchQueue.main.async {
                            self.nextButton.isEnabled = true
                            
                            Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                            }

                    }}})
        task.resume()
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            phoneNumber =  textField.getFormattedPhoneNumber(format: .E164)!
        }else{
            phoneNumber = ""
        }
    }
    
    
    
    func signIn(_ pin:String){
        let parameters = ["phone": phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""), "codeFromSms": pin]
        print("PIN \(parameters)")
        let url = URL(string: "https://api.leapper.com/api/auth/login/mobi")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            
                DispatchQueue.main.async {
                    Toast(error.localizedDescription).show(self)
                    }
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            struct Tokens: Decodable {
                let accessToken: String
                let refreshToken: String
            }
            struct TokensId: Decodable {
                let accessToken: String
                let refreshToken: String
                let proExists: ProExistence
            }
            struct ProExistence:Decodable {
                let _id: String
            }
            
            struct TokensIdClient: Decodable {
                let accessToken: String
                let refreshToken: String
                let clientExists: ClientExistence
            }
            struct ClientExistence:Decodable {
                let _id: String
            }
            // let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            if let httpResponse = response as? HTTPURLResponse{

                if httpResponse.statusCode == 401{
                    DispatchQueue.main.async {
                        Toast("Wrong code from sms").show(self)
                        self.smsCodeInput.text = ""
                    }
                }
                else if httpResponse.statusCode == 200 {
                    DispatchQueue.global(qos: .background).async {
                            ContactsTaker.shared.takeContactsFromThePhone()
                    }
                    if let safeData = data {                        KeychainWrapper.standard.set(self.phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""), forKey: "phoneNumber")

                        do {
                            // let dataString = String(data: safeData, encoding: .utf8)
                            let decodedData = try self.decoder.decode(TokensId.self, from: safeData)
                            KeychainWrapper.standard.set(decodedData.accessToken, forKey: "accessToken")
                            KeychainWrapper.standard.set(decodedData.refreshToken, forKey: "refreshToken")
                            KeychainWrapper.standard.set(decodedData.proExists._id, forKey: "_id")
                            DispatchQueue.main.async {
                                postToUnregister() {
                                    postToRegister(deviceToken: UIDevice.current.identifierForVendor!.uuidString, registrationToken: AppDelegate.fcmTokenUser , controller: ProFeeds())
                                }
                            }
                            SessionManager.shared.loginUser(self, true)

                            
                        }
                        catch {
                            if error.localizedDescription == "The data couldn’t be read because it is missing." {
                                do {
                                let decodedData = try self.decoder.decode(TokensIdClient.self, from: safeData)
                                KeychainWrapper.standard.set(decodedData.accessToken, forKey: "accessToken")
                                KeychainWrapper.standard.set(decodedData.refreshToken, forKey: "refreshToken")
                                    KeychainWrapper.standard.set(decodedData.clientExists._id, forKey: "_id")
                                    DispatchQueue.main.async {
                                        postToUnregister() {
                                            postToRegister(deviceToken: UIDevice.current.identifierForVendor!.uuidString, registrationToken: AppDelegate.fcmTokenUser , controller: ProFeeds())
                                        }
                                    }
                                    SessionManager.shared.loginUser(self, false)

                                }
                                catch {
                                    print(error.localizedDescription)
                                }
                            }
                            print(error.localizedDescription)
                        }
                    }
                    // self.sessionManager.loginUser(self, self.phoneNumber,false)
                }
                else if httpResponse.statusCode == 201 {
                            KeychainWrapper.standard.set(self.phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""), forKey: "phoneNumber")
                            
                            DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreRegistration") as! PreRegistration
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = vc
                        }
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
}


extension LoginViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}
  func toastMessage(_ message: String){
    guard let window = UIApplication.shared.keyWindow else {return}
    let messageLbl = UILabel()
    messageLbl.text = message
    messageLbl.textAlignment = .center
    messageLbl.font = UIFont.systemFont(ofSize: 16)
    messageLbl.textColor = .white
    messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)

    let textSize:CGSize = messageLbl.intrinsicContentSize
    let labelWidth = min(textSize.width, window.frame.width - 40)

    messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: textSize.height + 20)
    messageLbl.center.x = window.center.x
    messageLbl.layer.cornerRadius = messageLbl.frame.height/2
    messageLbl.layer.masksToBounds = true
    window.addSubview(messageLbl)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

    UIView.animate(withDuration: 1, animations: {
        messageLbl.alpha = 0
    }) { (_) in
        messageLbl.removeFromSuperview()
    }
    }
}}


private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}
