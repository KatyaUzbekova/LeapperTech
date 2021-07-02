//
//  LeadInformationController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 30.11.2020.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import ContactsUI
import SwiftyMenu
import AddressBook
import Contacts
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire
import EventKit

class LeadInformationController: UIViewController, CNContactViewControllerDelegate{
    @IBOutlet private weak var dropDownMenu1: SwiftyMenu!
    @IBOutlet private weak var dropDownMenu2: SwiftyMenu!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLeads()
    }
    
    @IBOutlet weak var addToContactsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDownMenu1.delegate = self
        dropDownMenu2.delegate = self
        
        dropDownMenu1.items = leadStatusOptions
        dropDownMenu2.items = picker2Options

        dropDownMenu2.hideOptionsWhenSelect = true
        dropDownMenu1.hideOptionsWhenSelect = true

        dropDownMenu1.rowHeight = 35
        dropDownMenu1.borderWidth = 1.0
        
        if isContacted {
            contactedWithLeadButton.isUserInteractionEnabled = false
            contactedWithLeadButton.text(NSLocalizedString("LeadInformationController.Action.isContactedWithLead", comment: ""))
            contactedWithLeadButton.backgroundColor = UIColor.gray
        }
        
        fullnameLabel.text = fullname
        phoneNumberLabel.text = "+\(phoneNumber)"
        self.navTitle.title = NSLocalizedString("LeadInformationController.Label.LeadsFrom", comment: "") + " \(leadsFromFullname)"
        
        if leadStatus.lowercased() == "not a client" {
            dropDownMenu1.selectedIndex = 0
            dropDownMenu1.placeHolderText = dropDownMenu1.items[0].displayableValue
        }
        else if leadStatus.lowercased() == "client" {
            dropDownMenu1.selectedIndex = 1
            dropDownMenu1.placeHolderText = dropDownMenu1.items[1].displayableValue
        }
        else {
            dropDownMenu1.placeHolderText = NSLocalizedString("LeadInformationController.Label.SelectionLeadStatus", comment: "")
        }
        
        if recall {
            dropDownMenu2.selectedIndex = 0
            dropDownMenu2.placeHolderText = dropDownMenu2.items[0].displayableValue
        }
        else if recall == false {
            dropDownMenu2.selectedIndex = 1
            dropDownMenu2.placeHolderText = dropDownMenu2.items[1].displayableValue

        }
        else {
            dropDownMenu2.placeHolderText = NSLocalizedString("LeadInformationController.Label.SelectionOfCallBackOption", comment: "")
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        postApiLeads()
    }
    var _id = ""
    var recall = false
    var timeToRecall = ""
    var leadStatus = ""
    var email = ""
    var chatId = ""
    
    
    func getLeads() {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        let url = URL(string: "https://api.leapper.com/api/mobi/getLeadInfo/\(_id)")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
                        let decodedData = JSON(safeData)
                        print(decodedData)
                        self.isContacted = decodedData["info"]["isContacted"].boolValue
                        self.timeToRecall = decodedData["info"]["recieveTime"].stringValue
                        self.leadStatus = decodedData["info"]["leadStatus"].stringValue
                        self.recall = decodedData["info"]["recall"].boolValue
                        if self.isContacted {
                            DispatchQueue.main.async {
                                self.contactedWithLeadButton.isUserInteractionEnabled = false
                                self.contactedWithLeadButton.text(NSLocalizedString("LeadInformationController.Action.isContactedWithLead", comment: ""))
                                self.contactedWithLeadButton.backgroundColor = UIColor.gray
                            }
                        }
                        
                        if self.leadStatus.lowercased() == "not a client" {
                            DispatchQueue.main.async {
                                self.dropDownMenu1.selectedIndex = 0
                                self.dropDownMenu1.placeHolderText = self.dropDownMenu1.items[0].displayableValue
                            }

                        }
                        else if self.leadStatus.lowercased() == "client" {
                            DispatchQueue.main.async {

                            self.dropDownMenu1.selectedIndex = 1
                                self.dropDownMenu1.placeHolderText = self.dropDownMenu1.items[1].displayableValue
                            }
                        }
                        else {
                            DispatchQueue.main.async {

                            self.dropDownMenu1.placeHolderText = NSLocalizedString("LeadInformationController.Label.SelectionLeadStatus", comment: "")
                            }
                        }
                        
                        if self.recall {
                            DispatchQueue.main.async {

                            self.dropDownMenu2.selectedIndex = 0
                                self.dropDownMenu2.placeHolderText = self.dropDownMenu2.items[0].displayableValue
                            }
                        }
                        else if self.recall == false {
                            DispatchQueue.main.async {

                            self.dropDownMenu2.selectedIndex = 1
                                self.dropDownMenu2.placeHolderText = self.dropDownMenu2.items[1].displayableValue
                            }

                        }
                        else {
                            DispatchQueue.main.async {

                            self.dropDownMenu2.placeHolderText = NSLocalizedString("LeadInformationController.Label.SelectionOfCallBackOption", comment: "")
                            }
                        }
                    }
                    
            }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getLeads()
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

    
    func postApiLeads() {
        leadStatus = "\(dropDownMenu1.items[dropDownMenu1.selectedIndex ?? 0].displayableValue)"
        if dropDownMenu2.items[dropDownMenu2.selectedIndex ?? 1].displayableValue == "Yes" {
            recall = true
        }
        else {
            recall = false
        }
        if recall {
            let description = NSLocalizedString("LeadInformationController.TextBody.CallBackReminderBody", comment: "")
            let finalDescipription = String.localizedStringWithFormat(description, fullname, phoneNumber)
            
            addEventToCalendar(title:NSLocalizedString("LeadInformationController.TextTitle.CallBackReminder", comment: "") , description: finalDescipription, startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(86400))

            let tomorrow = Date().addingTimeInterval(86400)
                
            let iso8601DateFormatter = ISO8601DateFormatter()
            iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let string = iso8601DateFormatter.string(from: tomorrow)
            timeToRecall = string
        }
        else {
            let yesterday = Date().addingTimeInterval(-86400)
                
            let iso8601DateFormatter = ISO8601DateFormatter()
            iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let string = iso8601DateFormatter.string(from: yesterday)
            timeToRecall = string
        }
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        let parameters: [String:Any] = [
            "leadStatus": leadStatus,
            "recall": recall,
            "timeToRecall": timeToRecall,
            "isContacted": isContacted
        ]
        AF.request("https://api.leapper.com/api/mobi/setLeadInfo/\(_id)", method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
                    if let err = resp.error{
                        print(err)
                        return
                    }
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: self)
                self.postApiLeads()
            }
            else if resp.response?.statusCode == 200 {
            }
        
    }
    }
    @IBOutlet weak var navTitle: UINavigationItem!
    var phoneNumber:String = ""
    var fullname = ""
    var leadsFromFullname = ""
    var isContacted = false
    @IBOutlet weak var fullnameLabel: UILabel!

    private let leadStatusOptions = [NSLocalizedString("Leapper.NotAClient", comment: ""), NSLocalizedString("Leapper.Client", comment: "")]
    private let picker2Options = [NSLocalizedString("Yes", comment: ""), NSLocalizedString("No", comment: "")]
    @IBOutlet weak var phoneNumberLabel: UILabel!

    @IBOutlet weak var contactedWithLeadButton: UIButton!
    @IBAction func contactedWithLead(_ sender: Any) {
        contactedWithLeadButton.isUserInteractionEnabled = false
        contactedWithLeadButton.text(NSLocalizedString("LeadInformationController.Action.isContactedWithLead", comment: ""))
        contactedWithLeadButton.backgroundColor = UIColor.gray
        isContacted = true
    }
    @IBAction func addToContacts(_ sender: Any) {
        let newContact = CNMutableContact()
        newContact.givenName = fullnameLabel.text ?? NSLocalizedString("Leapper.LeapperUser", comment: "")
        newContact.phoneNumbers = [CNLabeledValue(
                                    label:CNLabelPhoneNumberiPhone,
                                    value:CNPhoneNumber(stringValue:phoneNumberLabel.text!))]
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            try AppDelegate.getAppDelegate().contactStore.execute(saveRequest)
        } catch {
            AppDelegate.getAppDelegate().showMessage(NSLocalizedString("LeadInformationController.Action.UnableToSaveNewContact", comment: ""))
        }
        addToContactsButton.text(NSLocalizedString("LeadInformationController.Action.AddedToContactList", comment: ""))
        addToContactsButton.isUserInteractionEnabled = false
    }
    
    @IBAction func sendInChat(_ sender: Any) {
       // fbHelper.openChat(parent: self, withWhome: phoneNumber)
    }
    @IBAction func sendMessage(_ sender: Any) {
    }
    @IBAction func callUser(_ sender: Any) {
        if let url = URL(string: "tel://\(phoneNumber)"),
        UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    }
}
extension LeadInformationController: SwiftyMenuDelegate {
    // Get selected option from SwiftyMenu
    func swiftyMenu(_ swiftyMenu: SwiftyMenu, didSelectItem item: SwiftyMenuDisplayable, atIndex index: Int) {
    }
    
    func swiftyMenu(willExpand swiftyMenu: SwiftyMenu) {
    }

    func swiftyMenu(didExpand swiftyMenu: SwiftyMenu) {
    }

    func swiftyMenu(willCollapse swiftyMenu: SwiftyMenu) {
    }

    func swiftyMenu(didCollapse swiftyMenu: SwiftyMenu) {
    }
}
extension String: SwiftyMenuDisplayable {
    public var displayableValue: String {
        return self
    }
    
    public var retrievableValue: Any {
        return self
    }
}


func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    let eventStore = EKEventStore()

    eventStore.requestAccess(to: .event, completion: { (granted, error) in
        if (granted) && (error == nil) {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = description
            event.calendar = eventStore.defaultCalendarForNewEvents
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch let e as NSError {
                completion?(false, e)
                return
            }
            completion?(true, nil)
        } else {
            completion?(false, error as NSError?)
        }
    })
}
