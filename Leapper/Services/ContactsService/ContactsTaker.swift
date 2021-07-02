//
//  ContactsTaker.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 24.05.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation
import Contacts


class ContactsTaker {
    static var shared = ContactsTaker()

    func contactsTakerRequest() {
        ApiServices.shared.synchContactsRequest(with: [])
    }
    var contactsToPost = [CLong]()
    func takeContactsFromThePhone() {
        let contacts = ContactHelper.getContacts()
        for cont in contacts {
            for ctcNum: CNLabeledValue in cont.phoneNumbers {
                if let fulPhone = ctcNum.value as? CNPhoneNumber {
                    if let ph = fulPhone.value(forKey: "digits") as? String{
                        if let safeContact = CLong(ph) {
                            contactsToPost.append(safeContact)
                        }
                    }
                }
            }
        }
        ApiServices.shared.synchContactsRequest(with: Array(Set(contactsToPost)))
    }
}
