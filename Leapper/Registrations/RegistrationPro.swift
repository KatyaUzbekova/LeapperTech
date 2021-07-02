//  RegistrationPro.swift
//  Leapper
//
//  Created by Kratos on 3/5/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//


import UIKit
import CoreLocation
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import MessageKit
import YPImagePicker
import SwiftKeychainWrapper

class RegistrationPro: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var viewWithOgjects: UIView!
    @IBAction func approveButtonClicked(_ sender: Any) {
        APPROVEBUTTON.isEnabled = false
        textMessages.append(MessageModel(messages: NSLocalizedString("finishReg", comment: "Finished"), isBot: true, image: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chatBotTable.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        finishReg()
    }
    
    func isHiddenApprove() {
        viewWithOgjects.isHidden = true
        APPROVEBUTTON.isHidden = false
    }
    @IBOutlet weak var APPROVEBUTTON: UIButton!
    fileprivate var cellId = "id"
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var chatHolder: UIView!
    @IBOutlet weak var chatBotTable: UITableView!
    @IBOutlet weak var genderView: UIStackView!
    @IBOutlet weak  var imagePicker: UIStackView!
    @IBOutlet weak  var imagePickerButton: UIButton!
    @IBOutlet weak  var skipButton: UIButton!
    
    @IBOutlet weak var datePickerTextField: DateTextField!
    
    var textMessages = [MessageModel]()
    var locationManager:CLLocationManager!
    var userDatas = [String : Any ]()
    var position = 1
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            sendFunctionCode()
        }
        return true
    }
    override func viewDidLoad() {
        super .viewDidLoad()
        
        editText.isScrollEnabled = false
        editText.delegate = self
        
        self.editText.textContentType = .name
        editText.textContainer.maximumNumberOfLines = 1
        
        datePickerTextField.isHidden = true
        datePickerTextField.dateFormat = .dayMonthYear
        datePickerTextField.separator = "  "
        datePickerTextField.placeholder = "dd mm yyyy"
        
        chatBotTable.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        chatBotTable.register(YairPrototypeCell.self, forCellReuseIdentifier: "idYair")
        
        editText!.layer.borderWidth = 1
        editText!.layer.cornerRadius = 10
        userDatas["phone"] = KeychainWrapper.standard.string(forKey: "phoneNumber")
        chatBotTable.delegate = self
        chatBotTable.dataSource = self
        
        genderView.isHidden = true
        chatHolder.isHidden = true
        imagePicker.isHidden = true
        APPROVEBUTTON.isHidden = true
        
        skipButton.layer.borderColor = UIColor(red: 126/256, green: 133/256, blue: 145/256, alpha: 1).cgColor
        callStageOne();
    }
    
    
    
    func uploadImage(image: UIImage, phone username: String) {
        self.skipButton.isEnabled = false
        self.imagePickerButton.isEnabled = false
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image.jpegData(compressionQuality: 0.2)!, withName: "file" , fileName: "avatar.jpeg", mimeType: "image/jpeg")
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
                        self.userDatas["avatar"] = jsonObject["hashedFilePathes"][0].stringValue
                        self.skipButton.isEnabled = true
                        self.skipButton.text(NSLocalizedString("Finish", comment: ""))
                        self.imagePickerButton.isEnabled = false
                        
                        self.textMessages.append(MessageModel(messages: NSLocalizedString("botRegProSix", comment: "one"), isBot: false, image: image))
                        DispatchQueue.main.async {
                            self.chatBotTable.reloadData()
                            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                            self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                        
                    }
                    catch {
                    }
                }
            }
        
    }
    
    func finishReg(){
        let parameters = userDatas
        let url = URL(string: "https://api.leapper.com/api/auth/register/mobi/pro")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            Toast(error.localizedDescription).show(self)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in
            guard error == nil else {
                return
            }
            
            struct MessageID: Decodable {
                let id: String
                let accessToken: String
                let refreshToken: String
            }
            let decoder = JSONDecoder()
            
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 201{
                    
                    if let safeData = data {
                        do {
                            
                            //         let dataString = String(data: safeData, encoding: .utf8)
                            let decodedData = try decoder.decode(MessageID.self, from: safeData)
                            KeychainWrapper.standard.set(decodedData.id, forKey: "_id")
                            KeychainWrapper.standard.set(decodedData.refreshToken, forKey: "refreshToken")
                            KeychainWrapper.standard.set(decodedData.accessToken, forKey: "accessToken")
                            UserDefaults.standard.set(false, forKey: "isFullyRegistered")
                            UserDefaults.standard.set(userDatas["name"], forKey: "userName")

                            SessionManager.shared.loginUser(self, true)
                            DispatchQueue.main.async {
                                postToRegister(deviceToken: UIDevice.current.identifierForVendor!.uuidString, registrationToken: AppDelegate.fcmTokenUser , controller: ProFeeds())
                            }
                            DispatchQueue.global(qos: .background).async {
                                    ContactsTaker.shared.takeContactsFromThePhone()
                            }
                        }
                        catch {
                            Toast(NSLocalizedString("Toast.Message.CheckInternetConnection", comment: "")).show(self)
                        }
                    }
                    
                }
                
                else {
                    DispatchQueue.main.async {
                        self.APPROVEBUTTON.isEnabled = true
                        Toast(NSLocalizedString("Toast.Message.CheckInternetConnection", comment: "")).show(self)
                    }
                }
                
            }
        })
        task.resume()
    }
    
    @IBAction func maleClicked(_ sender: Any) {
        self.genderChosen(true)
    }
    
    @IBAction func female(_ sender: Any) {
        self.genderChosen(false)
    }
    
    @IBAction func othersGender(_ sender: Any) {
        self.genderChosen(false, others: true)
    }
    
    
    func genderChosen(_ isMale:Bool = false, others: Bool = false){
        if isMale{
            userDatas["gender"] = "male"
        }else{
            if others {
                userDatas["gender"] = "skipped"
            }
            else {
                userDatas["gender"] = "female"
            }
        }
        textMessages.append(MessageModel(messages: NSLocalizedString(userDatas["gender"] as! String, comment: "Male"), isBot:false, image: nil))

        self.chatBotTable.reloadData()
        self.editText.text = ""
        self.editText.textContentType = .emailAddress
        self.chatBotTable.reloadData()
        self.textMessages.append(MessageModel(messages: NSLocalizedString("botRegProSeven", comment: "one"),isBot: true, image: nil))
        self.position = 7
        self.actualPose = 7
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            
            chatBotTable.reloadData()
            let indexPath = IndexPath(row: textMessages.count - 1, section: 0)
            chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
            chatHolder.isHidden = false
            editText.becomeFirstResponder()
            genderView.isHidden = true
        }
        
    }
    
    
    @IBAction func choosePic(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                createUserDir(phone: self.userDatas["phone"] as! String, self)
                if let image = photo.modifiedImage {
                    self.uploadImage(image: image, phone: self.userDatas["phone"] as! String)
                }
                else {
                    self.uploadImage(image: photo.image, phone: self.userDatas["phone"] as! String)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func skipImageChoosing(_ sender: Any) {
        DispatchQueue.main.async  {
            
            self.chatBotTable.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        self.editText.text = ""
        textMessages.append(MessageModel(messages: NSLocalizedString("RegistrationPro.GreatAsAFinalStep", comment: ""), isBot: true, image: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chatBotTable.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
            self.imagePicker.isHidden = true
        }
        
        textMessages.append(MessageModel(messages: "", isBot: true, image: UIImage(named: "agreementPic"), isAgreement: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chatBotTable.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    var indexNumber = 0
    func sendFunctionCode() {
        editText.text = (editText.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        switch self.position {
        case 3:
            if editText.text!.count > 0 {
                let name = editText.text!
                
                if position != actualPose {
                    textMessages[indexNumber] = MessageModel(messages: name, isBot: false, image: nil, caseNumber: 3)
                    self.position = actualPose
                }
                else {
                    textMessages.append(MessageModel(messages: name, isBot: false, image: nil, caseNumber: 3))
                    DispatchQueue.main.async {
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                    
                    self.actualPose = 4
                    self.position = 4
                    
                    textMessages.append(MessageModel(messages: NSLocalizedString("botRegProFour", comment: "one"), isBot: true, image: nil))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
                userDatas["name"] = name
                self.editText.textContentType = .familyName
                self.editText.text = ""
            }
            else {
                editText.resignFirstResponder()
                editText.text = ""
            }
            
            break
            
        case 4:
            if editText.text!.count > 0 {
                let lastName = editText.text!

                if position != actualPose {
                    DispatchQueue.main.async {
                        self.chatBotTable.reloadData()
                        self.chatHolder.isHidden = false
                        self.genderView.isHidden = true
                        self.datePickerTextField.isHidden = true
                        self.editText.isHidden = false
                    }
                    self.position = actualPose
                    textMessages[indexNumber] = MessageModel(messages: lastName, isBot: false, image: nil, caseNumber:4)
                }
                else {
                    textMessages.append(MessageModel(messages: lastName, isBot: false, image: nil, caseNumber:4))
                    self.actualPose = 5
                    self.position = 5
                    
                    
                    DispatchQueue.main.async { [self] in
                        
                        chatBotTable.reloadData()
                        chatHolder.isHidden = false
                        genderView.isHidden = true
                        datePickerTextField.isHidden = false
                        editText.isHidden = true
                        datePickerTextField.becomeFirstResponder()
                        let indexPath = IndexPath(row: textMessages.count - 1, section: 0)
                        chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    let botText = NSLocalizedString("botRegProFive", comment: "fifthStep")
                    let finalBotText = String.localizedStringWithFormat(botText, userDatas["name"] as! String)
                    textMessages.append(MessageModel(messages: finalBotText, isBot: true, image: nil))

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    
                }
                
                userDatas["lastName"] = lastName
                self.editText.text = ""
            }
            else {
                editText.resignFirstResponder()
                editText.text = ""
            }
            break
        case 5:
            
            if true {
                if let bdTemp = datePickerTextField.date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    
                    let dd = dateFormatter.string(from: bdTemp)
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    userDatas["birthday"] = dateFormatter.string(from: bdTemp)
                    
                    textMessages.append(MessageModel(messages: dd, isBot: false, image: nil, caseNumber: 5))
                    self.editText.text = ""
                    DispatchQueue.main.async  {
                        self.datePickerTextField.isHidden = true
                        self.editText.isHidden = false
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    datePickerTextField.resignFirstResponder()
                    let botText = NSLocalizedString("botRegProSix", comment: "sixth")
                    let finalBotText = String.localizedStringWithFormat(botText, userDatas["name"] as! String)
                    
                    textMessages.append(MessageModel(messages: finalBotText, isBot: true, image: nil))
                    if position != actualPose {
                        self.position = actualPose
                    }
                    else {
                        self.actualPose = 6
                        self.position = 6
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.chatHolder.isHidden = true
                        self.genderView.isHidden = false
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            }
            break
        case 7:
            if editText.text!.count > 0 {
                
                let email = editText.text!
                textMessages.append(MessageModel(messages: email, isBot: false, image: nil, caseNumber:7))
                
                if !email.isValidEmail(){
                    textMessages.append(MessageModel(messages: NSLocalizedString("RegistrationPro.NotAValidEmail", comment: "sixth"), isBot: true, image: nil))
                    self.editText.text = ""
                    textMessages.append(MessageModel(messages: NSLocalizedString("botRegProSeven", comment: "one"), isBot: true, image: nil))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.chatBotTable.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    break
                }
                userDatas["email"] = email
                DispatchQueue.main.async {
                    
                    self.chatBotTable.reloadData()
                    let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                    self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                self.editText.text = ""
                editText.resignFirstResponder()
                
                DispatchQueue.main.async  {
                    self.chatHolder.isHidden = true
                    self.imagePicker.isHidden = false
                }
                let botText = NSLocalizedString("botRegProEight", comment: "Eigths")
                let finalBotText = String.localizedStringWithFormat(botText, userDatas["name"] as! String)
                
                textMessages.append(MessageModel(messages: finalBotText, isBot: true, image: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.chatBotTable.reloadData()
                    let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                    self.chatBotTable.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
            else {
                editText.resignFirstResponder()
                editText.text = ""
            }
            break
        default:
            break
        }
    }
    @IBAction func send(_ sender: Any) {
        sendFunctionCode()
    }
    
    func callStageOne(){
        textMessages.append(MessageModel(messages:NSLocalizedString("botRegProOne", comment: "one"), isBot:true, image: nil))
        DispatchQueue.main.async {
            self.chatBotTable.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.textMessages.append(MessageModel(messages:NSLocalizedString("botRegProTwo", comment: "one"), isBot:true, image: nil))
            self.chatBotTable.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.textMessages.append(MessageModel(messages:NSLocalizedString("botRegProThree", comment: "one"), isBot:true, image: nil))
            self.chatHolder.isHidden = false
            self.chatBotTable.reloadData()
        }
        position = 3
        actualPose = 3
        
        
    }
    
    var actualPose = 1
}


extension RegistrationPro:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textMessages.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idYair", for: indexPath) as! YairPrototypeCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
            cell.parentReg = self
            cell.chatMessage = textMessages[indexPath.row-1]
            return cell
            
            
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if indexPath.row == 0 {
            return nil
        }
        let index = indexPath.row-1
        let chatMessageBubble = textMessages[index]
        let identifier = "\(index)" as NSString
        
        if chatMessageBubble.isBot {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("Promotions.Action.Edit", comment: "Edit"),
                image: UIImage(systemName: "pencil.slash")) { _ in
                self.editText.becomeFirstResponder()
                
            }
                return UIMenu(title: "", image: nil, children: [editAction])
        }
    }
}
