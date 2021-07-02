//
//  ContactHelper.swift
//  Leapper
//
//  Created by Kratos on 9/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

class ContactHelper {
    class func getContacts() -> [CNContact]{
        let contactStore = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactPhoneNumbersKey,
                           CNContactThumbnailImageDataKey,
                            CNContactImageDataKey,
                            CNContactImageDataAvailableKey] as [Any]
    
        var allContainers: [CNContainer] = []
        do{
            allContainers = try contactStore.containers(matching: nil)
        }catch{
        }
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResult = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResult)
            }catch{
            }
        }
        return results
    }
}
