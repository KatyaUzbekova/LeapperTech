//
//  RegistrationClient.swift
//  Leapper
//
//  Created by Kratos on 3/5/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import YPImagePicker

class RegistrationClient: UIViewController, UITextViewDelegate {
    
    fileprivate var cellId = "id"

    @IBAction func approveButtonClicked(_ sender: Any) {
        approveButton.isEnabled = false
        textMessages.append(MessageModel(messages: NSLocalizedString("finishReg", comment: "Finished"), isBot: true, image: nil))
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.registrationTableView.reloadData()
        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        finishReg()
    }
    func isHiddenApprove() {
        approveButton.isHidden = false
    }
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak  var imagePicker: UIStackView!
    @IBOutlet weak  var imagePickerButton: UIButton!
    @IBOutlet weak  var skipButton: UIButton!
    
    var userDatas = [String : Any ]()
    var position = 1
    var bday = ""
    var PHONENUMBER = KeychainWrapper.standard.string(forKey: "phoneNumber")
    var textMessages = [MessageModel]()
    
    @IBOutlet weak var registrationTableView: UITableView!
    @IBOutlet weak var genderSelection: UIStackView!
    
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var chatFolder: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editText.textContentType = .name

        registrationTableView.register(YairPrototypeCell.self, forCellReuseIdentifier: "idYair")
        registrationTableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        editText.textContainer.maximumNumberOfLines = 1
        editText.delegate = self
        
        editText!.layer.borderWidth = 1
        editText!.layer.cornerRadius = 10
        
        registrationTableView.delegate = self
        registrationTableView.dataSource = self
        
        genderSelection.isHidden = true
        chatFolder.isHidden = true
        imagePicker.isHidden = true

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
                        return
                    }
                    let json = resp.data
                    if (json != nil)
                    {
                        do {
                        let jsonObject = try JSON(data: json!)
                        self.userDatas["avatar"] = jsonObject["hashedFilePathes"][0].stringValue
                            self.imagePickerButton.text("avatarImage.jpeg")
                            self.skipButton.isEnabled = true
                            self.skipButton.text(NSLocalizedString("Send", comment: "Send"))
                            self.imagePickerButton.isEnabled = true
                        }
                        catch {
                        }
                    }
            }
        
    }

    @IBAction func maleClicked(_ sender: Any) {
          self.genderChosen(true)
    }
    
    @IBAction func female(_ sender: Any) {
         self.genderChosen(false)
    }
    
    
    func genderChosen(_ isMale:Bool!, others: Bool = false){
        if isMale{
             userDatas["gender"] = "male"
        }else{
            if others {
                userDatas["gender"] = "skipped"
            }
            else  {
                userDatas["gender"] = "female"
            }
        }
    
        if !isInEditMode {
            position = 6
            textMessages.append(MessageModel(messages: NSLocalizedString(userDatas["gender"] as! String, comment: "gender selection"), isBot: false, image: nil, caseNumber: 5))
            DispatchQueue.main.async  {
                self.registrationTableView.reloadData()
                let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                
                self.genderSelection.isHidden = true
                self.chatFolder.isHidden = true
                self.imagePicker.isHidden = false
            }
            self.textMessages.append(MessageModel(messages: NSLocalizedString("RegistrationClient.Action.PhotoUpload", comment: "please, upload photo"),isBot: true, image: nil))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.registrationTableView.reloadData()
                let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
               }
        }
        else {
            textMessages[indexOfEdition] = MessageModel(messages: NSLocalizedString(userDatas["gender"] as! String, comment: "gender selection"), isBot: false, image: nil, caseNumber: 5)
            DispatchQueue.main.async  {
                self.registrationTableView.reloadData()
                let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            checkPosition(pos: positionEditing)
            position = positionEditing
            isInEditMode = false
        }
    }
    

    
    func sendFunctionCode() {
        editText.text = (editText.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if editText.text!.count > 0 {
            switch self.position {
            case 3:
                let name = editText.text!
                userDatas["name"] = name
                if !isInEditMode {
                    textMessages.append(MessageModel(messages: name, isBot: false, image: nil, caseNumber: 3))
                    self.editText.textContentType = .familyName
                    
                    DispatchQueue.main.async {
                        self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    
                    self.textMessages.append(MessageModel(messages: NSLocalizedString("botRegProFour", comment: "one"),isBot: true, image: nil))
                }
                else {
                    textMessages[indexOfEdition] = MessageModel(messages: name, isBot: false, image: nil, caseNumber: 3)
                    DispatchQueue.main.async {
                        self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    checkPosition(pos: positionEditing)
                    position = positionEditing
                    isInEditMode = false
                }
                self.editText.text = ""
         self.position = 4;
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.registrationTableView.reloadData()
                    let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                    self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                 }
                break
            case 4:
                let lastName = editText.text!
                userDatas["lastName"] = lastName
                if !isInEditMode {
                    textMessages.append(MessageModel(messages: lastName, isBot: false, image: nil, caseNumber: 4))
                    DispatchQueue.main.async {
                        self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                    let botText = NSLocalizedString("botRegProSix", comment: "one")
                    let finalBotText = String.localizedStringWithFormat(botText, userDatas["name"] as! String)
                    
                    textMessages.append(MessageModel(messages: finalBotText, isBot: true, image: nil))
                    
                    self.position = 5;
                    
                    self.editText.isHidden = true
                    self.chatFolder.isHidden = true
                    self.genderSelection.isHidden = false
                    
                    
                    self.editText.text = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        
                        self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
                else {
                    textMessages[indexOfEdition] = MessageModel(messages: lastName, isBot: false, image: nil, caseNumber: 4)
                    DispatchQueue.main.async {
                        self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        
                    }
                    isInEditMode = false
                    checkPosition(pos: positionEditing)
                    position = positionEditing
                }
                self.editText.text = ""

                
            
                break
            default:
                break
            }
        }
        else {
            editText.resignFirstResponder()
            editText.text = ""
        }
    }
    @IBAction func send(_ sender: Any) {
        sendFunctionCode()
    }

    @IBAction func choosePic(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                createUserDir(phone: self.PHONENUMBER!, self)
                if let image = photo.modifiedImage {
                    self.uploadImage(image: image, phone: self.PHONENUMBER!)
                }
                else {
                    self.uploadImage(image: photo.image, phone: self.PHONENUMBER!)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func skipImageChoosing(_ sender: Any) {
        DispatchQueue.main.async  {

        self.registrationTableView.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        self.editText.text = ""
        textMessages.append(MessageModel(messages: NSLocalizedString("RegistrationPro.GreatAsAFinalStep", comment: ""), isBot: true, image: nil))
                       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                  self.registrationTableView.reloadData()
                        let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
                        self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        self.imagePicker.isHidden = true
        }
        textMessages.append(MessageModel(messages: "", isBot: true, image: UIImage(named: "agreementPic")!, isAgreement: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.registrationTableView.reloadData()
            let indexPath = IndexPath(row: self.textMessages.count - 1, section: 0)
            self.registrationTableView.scrollToRow(at: indexPath, at: .top, animated: false)
}
}
    
    func callStageOne(){
        
        textMessages.append(MessageModel(messages: NSLocalizedString("botRegClientOne", comment: "one"),isBot: true, image: nil))
        registrationTableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.textMessages.append(MessageModel(messages: NSLocalizedString("botRegClientTwo", comment: "one"),isBot: true, image: nil))
            self.registrationTableView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.textMessages.append(MessageModel(messages:NSLocalizedString("botRegProThree", comment: "one"), isBot:true, image: nil))
            self.chatFolder.isHidden = false
            self.registrationTableView.reloadData()
        }
        position = 3
        
        
      
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
          //  textView.resignFirstResponder()
            sendFunctionCode()
        }
        return true
    }
    func finishReg(){
        let parameters = [
            "phone": PHONENUMBER!,
            "name": "\(userDatas["name"] ?? "")",
            "lastName": "\(userDatas["lastName"] ?? "")",
            "gender":  userDatas["gender"]!,
            "avatar": userDatas["avatar"] ?? ""
        ]
        
        let url = URL(string: "https://api.leapper.com/api/auth/register/mobi/client")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            Toast(error.localizedDescription).show(self)
        }
        let decoder = JSONDecoder()
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            struct MessageID: Decodable {
                let id: String
                let accessToken: String
                let refreshToken: String
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 201{
                    if let safeData = data {
                        do {
                            
                            //   let dataString = String(data: safeData, encoding: .utf8)
                            let decodedData = try decoder.decode(MessageID.self, from: safeData)
                            KeychainWrapper.standard.set(decodedData.id, forKey: "_id")
                            KeychainWrapper.standard.set(decodedData.accessToken, forKey: "accessToken")
                            KeychainWrapper.standard.set(decodedData.refreshToken, forKey: "refreshToken")
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
                    SessionManager.shared.loginUser(self, false)
                    
                }
                
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.CheckInternetConnection", comment: "")).show(self)
                    }
                }
                
            }
        })
        task.resume()
    }
    func checkPosition(pos: Int){
        if pos == 3 || pos == 4 {
            DispatchQueue.main.async {
                self.editText.isHidden = false
                self.chatFolder.isHidden = false
                self.genderSelection.isHidden = true
                self.imagePicker.isHidden = true

            }
        }
        else if pos == 5 {
            DispatchQueue.main.async {
                self.chatFolder.isHidden = true
                self.editText.isHidden = true
                self.genderSelection.isHidden = false
                self.imagePicker.isHidden = true

            }
        }
        else {
            DispatchQueue.main.async {
                self.chatFolder.isHidden = true
                self.genderSelection.isHidden = true
                self.imagePicker.isHidden = false
            }
        }
    }
    func editingMessage() {
        self.editText.becomeFirstResponder()
        isInEditMode = true
        checkPosition(pos: position)
    }
    
    var isInEditMode = false
    var indexOfEdition = 0
    var positionEditing = 0
    
    @IBAction func othersGenderSelection(_ sender: Any) {
        genderChosen(false, others: true)
    }
    
}




extension RegistrationClient:UITableViewDataSource,UITableViewDelegate{
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
            cell.chatMessage = textMessages[indexPath.row-1]
            cell.parentRegClient = self
            cell.regRole = "client"
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
                if !self.isInEditMode {
                    self.positionEditing = self.position
                }
                self.editText.text = chatMessageBubble.messages
                self.position = chatMessageBubble.caseNumber!
                self.editingMessage()
                self.indexOfEdition = index
            }
                return UIMenu(title: "", image: nil, children: [editAction])
        }
    }
}
